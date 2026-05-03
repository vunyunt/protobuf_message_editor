## 0.2.2

- Refactored `ProtoMapController` to simplify initialization and improve message serialization.
- Standardized field editor interfaces using `ProtoMapFieldInfo` and unified value normalization.
- Added support for **disabling and excluding fields** via `ProtoMapEditorProvider`.
- Enhanced **`google.protobuf.Any`** editing with a new searchable type selector.
- Added **custom builder support** for initializing new submessage fields and elements.
- Improved UX with **auto-expansion** of newly added fields and **collapsed-by-default** expandable fields.
- Pinned the save header in `ProtoMapEditor` and updated bytes fields to hide the text input by default.
- Fixed initialization issues for repeated message fields in the map editor.

## 0.2.1


- Extracted reusable UI components into `styled_widgets` to support custom decorators.
- Migrated internal naming from `ProtobufJson` to `ProtoMap` for consistency.
- Provided deprecated aliases for all renamed classes to maintain backward compatibility.

## 0.2.0

- Added **`ProtobufJsonEditor`** using internal JSON state management.
- Implemented **`ProtobufJsonController`** hierarchy for message state.
- Added **depth-weighted label colors** and matching **vertical indentation guides**.
- Added **context-aware tooltips** for fields and add buttons.
- Introduced **`ProtobufEditorTheme`** for centralized styling.
- Global support for **limiting numerical precision** (3 significant figures) during serialization.
- Fixed **`google.protobuf.Any`** serialization for uninitialized fields.
- Improved custom provider support for nested `Any` fields.
- Added visual **"Unsaved Changes" indicator**.
- Standardized Protobuf package naming.
- **Deprecated legacy editors** (`ProtoMessageEditor`, `ProtoDualPanelMessageEditor`, etc.) and associated types in favor of `ProtobufJsonEditor`.

## 0.1.0

- Refactored custom message editors to decouple the editor content widget from field expansion or navigation logic.
- Provided `CustomEditorProvider` and `SubmessageBuilder` down the widget tree via `Provider` to simplify propagation.

### Breaking changes:

- `CustomEditorRegistry` has been largely abstracted into the `CustomEditorProvider` interface.
- `customEditorRegistry` properties has been renamed to `customEditorProvider` and accepts the new interface.
- `submessageBuilder` property now receives a content widget instead of just the submessage itself.
- `ProtoNavigationState` and its nodes now track `fieldInfo` alongside messages in their stack.

## 0.0.5

- Add `AnyEditor` for editing `google.protobuf.Any` messages
- Add `AnyEditorRegistry` for managing available message types for `AnyEditor`

### Breaking changes:

- `SubmessageBuilder` typedef has been updated to include `parentMessage` and `onRebuildRequested` parameters.
- Add copy-to-edit button for frozen submessages

## 0.0.4

Added support for `google.protobuf.BoolValue` via a default custom editor registry

## 0.0.3

Added missing exports relevant to custom field editors

## 0.0.2

`ProtoDualPanelMessageEditor` can now accept a root message instead of a `ProtoNavigationState`.
When used this way, the widget will create an internally managed `ProtoNavigationState`.

## 0.0.1

Initial release
