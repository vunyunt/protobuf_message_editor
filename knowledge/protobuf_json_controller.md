# ProtobufJsonEditingController

The `ProtobufJsonEditingController` is the core state management layer of the `protobuf_message_editor` package. It bridges Flutter's editing model with Protobuf's Proto3 JSON serialization format.

## Overview

Instead of directly editing a `GeneratedMessage`, the controller converts the message to a `Map<String, dynamic>` (Proto3 JSON) and manages all edits on that map. On save, it converts the map back to a `GeneratedMessage` via `mergeFromProto3Json`.

```
                           toProto3Json
  GeneratedMessage  ─────────────────────►  Map<String, dynamic>
       (source)                                  (_jsonMap)
                                                    │
                                           UI edits via
                                         updateField / addField / removeField
                                                    │
                           mergeFromProto3Json       ▼
  GeneratedMessage  ◄─────────────────────  Map<String, dynamic>
     (saved output)                              (edited _jsonMap)
```

## Construction

### Root Controller

Created with a `GeneratedMessage` (the source message). Converts it to JSON immediately:

```dart
ProtobufJsonEditingController(
  sourceMessage: myMessage,
  typeRegistry: myTypeRegistry,
);
```

- `sourceMessage` is never mutated.
- `_jsonMap` is a mutable copy of `sourceMessage.toProto3Json(...)`.
- `typeRegistry` is required for resolving `Any` fields during both serialization and deserialization.

### Sub-Controller

Created for nested messages. Receives a pre-extracted `Map<String, dynamic>` fragment and uses an `onChanged` callback to propagate edits back to the parent controller:

```dart
ProtobufJsonEditingController.submessage(
  initialValue: nestedMap,
  builderInfo: nestedBuilderInfo,
  typeRegistry: parentController.typeRegistry,
  onChanged: (newMap) {
    parentController.updateField(jsonKey, newMap);
  },
);
```

## Field Operations

| Method                      | Description                                                                                      |
| --------------------------- | ------------------------------------------------------------------------------------------------ |
| `updateField(key, value)`   | Sets or replaces a field value. Handles `oneof` clearing automatically.                          |
| `addField(key, {typeUrl?})` | Adds a previously-unset field with a default value. For `Any` fields, sets `{'@type': typeUrl}`. |
| `removeField(key)`          | Removes a field from the JSON map.                                                               |
| `updateFullJson(newJson)`   | Replaces the entire JSON map (used by sub-controllers for bulk updates).                         |

All mutation methods set `_isDirty = true`, invoke the `onChanged` callback (for sub-controllers), and call `notifyListeners()`.

## Save & Reset

- **`getSavedMessage()`**: Sanitizes the JSON map via `_sanitizeForSave` (removing incomplete `Any` fields), creates a fresh `GeneratedMessage` from `builderInfo.createEmptyInstance()`, and calls `mergeFromProto3Json(sanitized)` on it.
- **`save()`**: Calls `getSavedMessage()`, then resets the dirty flag.
- **`reset()`**: Re-serializes the original `sourceMessage` to JSON, discarding all edits. Only works on root controllers.

### Save Sanitization (`_sanitizeForSave`)

Before deserializing, `getSavedMessage()` runs the JSON map through `_sanitizeForSave`, which:

1. **Strips incomplete `Any` fields** — Any singular `Any` field whose value is a map without `@type` is removed entirely.
2. **Filters repeated `Any` entries** — In repeated `Any` fields, individual entries missing `@type` are filtered out.
3. **Recurses into nested messages** — Nested singular and repeated message fields are sanitized recursively.
4. **Preserves unknown keys** — Keys not in the `BuilderInfo` (e.g., `@type` inside a resolved `Any` sub-controller) are kept as-is.

## Field Lookup

On construction, the controller builds a `_jsonKeyToFieldInfo` map from `builderInfo.fieldInfo`. This allows quick lookup of the `FieldInfo` for any JSON key, which is used by the UI widgets to determine what kind of editor to render (scalar, enum, message, Any, etc.).

---

# Any Message Handling

`google.protobuf.Any` is a well-known type that wraps an arbitrary message. In Proto3 JSON, it is represented as:

```json
{
  "@type": "type.googleapis.com/package.MessageName",
  "field1": "value1",
  "field2": 42
}
```

The `@type` field is **mandatory** — it tells the deserializer which message type is packed inside. The remaining keys are the JSON-serialized fields of that inner message, flattened directly into the same map (not nested under a separate `value` key).

## How the Controller Handles Any

### BuilderInfo Resolution (`_resolveBuilderInfo`)

When a **sub-controller** is created for an `Any` field, the constructor calls `_resolveBuilderInfo`. If the `builderInfo` is `google.protobuf.Any` and the initial JSON contains `@type`, it uses the `TypeRegistry` to look up the actual message type and returns that type's `BuilderInfo` instead. This allows the editor to render the real inner message's fields rather than the raw `Any` fields (`typeUrl` and `value`).

```dart
static BuilderInfo _resolveBuilderInfo(
  BuilderInfo info,
  Map<String, dynamic> json,
  TypeRegistry registry,
) {
  if (info.qualifiedMessageName == 'google.protobuf.Any' &&
      json.containsKey('@type')) {
    final typeUrl = json['@type'] as String;
    final qualifiedName = typeUrl.split('/').last;
    final resolved = registry.lookup(qualifiedName);
    if (resolved != null) return resolved;
  }
  return info;
}
```

### Adding an Any Field (`addField`)

When `addField` is called with a `typeUrl`, the field is initialized as `{'@type': typeUrl}`. When called **without** a `typeUrl`, it falls through to `getDefaultValue()`, which returns an empty map `{}` for message fields.

### AnyFieldEditor Widget

`ProtobufJsonAnyFieldEditor` handles the UI for `Any` fields:

1. **Type Selection** — Renders a dropdown that lists available types from the `TypeRegistry` (specifically `AnyEditorRegistry`). When a type is selected, it writes `{'@type': 'type.googleapis.com/...'}` to the controller.

2. **Level Detection** — Determines whether it is at the "parent level" (the controller has the `Any` field in its field map) or at the "sub-controller level" (the controller is already focused on the `Any` message's resolved content). This distinction prevents double-nesting issues.

3. **Sub-Controller for Inner Message** — Creates a sub-controller via `ProtobufJsonEditingController.submessage(...)` using the `Any`'s `subBuilder` (which is `Any.create`). The sub-controller's `_resolveBuilderInfo` then resolves the actual inner type using `@type`.

4. **Propagation** — The `onChanged` callback writes the edited inner map back to the parent controller under the original JSON key.

---

# Interaction with Protobuf Serialization

## `toProto3Json` (Message → JSON)

Called during root controller construction. The Protobuf library serializes the `GeneratedMessage` into a `Map<String, dynamic>`. For `Any` fields, this produces the flattened `{@type: ..., field1: ..., ...}` format.

Key detail: the `typeRegistry` must be provided so the library can look up the inner type and serialize its fields. Without it, `Any` fields serialize as `{typeUrl: ..., value: <base64>}` (binary format), which is not what the editor expects.

## `mergeFromProto3Json` (JSON → Message)

Called during `getSavedMessage()`. The Protobuf library reads the JSON map and populates a fresh `GeneratedMessage`. For `Any` fields it:

1. Reads the `@type` key.
2. Looks up the type in the `TypeRegistry`.
3. Creates an instance of the inner message and populates it from the remaining keys.
4. Packs it into an `Any`.

### Failure Modes

| Scenario                                                        | Error                                                                              |
| --------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `Any` field value is an empty map `{}` (no `@type`)             | `FormatException: Expected a string` — the library tries to read `@type` and fails |
| `Any` field `@type` references a type not in the `TypeRegistry` | `FormatException: Decoding Any of type ... not in TypeRegistry`                    |
| `Any` field value is a bare string instead of a map             | `FormatException: Expected a map`                                                  |

> [!NOTE]
> The most common failure scenario — an empty-map `Any` field — is handled by `_sanitizeForSave`, which strips incomplete `Any` entries before calling `mergeFromProto3Json`. See [Save Sanitization](#save-sanitization-_sanitizeforsave) above.

## TypeRegistry

The `TypeRegistry` is the lookup mechanism that maps qualified message names (e.g., `frogsoup.game.item.ItemProto`) to their `BuilderInfo`. It is essential for:

- **Serialization**: `toProto3Json` uses it to unpack `Any` fields into their JSON representation.
- **Deserialization**: `mergeFromProto3Json` uses it to reconstruct `Any` fields from JSON.
- **Editor Resolution**: The controller uses it in `_resolveBuilderInfo` to determine what fields to render for an `Any` value.

If the `TypeRegistry` does not contain the type referenced by an `Any` field's `@type`, both serialization and deserialization will fail.

---

# Widget Architecture

```
ProtobufJsonEditor                    (top-level widget, owns root controller)
  └─ ProtobufJsonMessageEditor        (iterates over JSON keys)
       └─ ProtobufJsonFieldEditor     (per-field routing, checks provider)
            ├─ ProtobufJsonScalarFieldEditor
            ├─ ProtobufJsonBooleanFieldEditor
            ├─ ProtobufJsonEnumFieldEditor
            ├─ ProtobufJsonRepeatedFieldEditor
            ├─ ProtobufJsonMessageFieldEditor    (generic submessage)
            └─ ProtobufJsonAnyFieldEditor        (Any-specific handling)
                 └─ ProtobufJsonMessageEditor    (renders resolved inner type)
```

`ProtobufJsonEditorProvider` is an optional customization point: before rendering the default editor for a submessage, `ProtobufJsonFieldEditor` asks the provider if it wants to supply a custom widget. This is how consuming apps (like FrogSoup) can replace specific `Any` field editors with domain-specific UIs.
