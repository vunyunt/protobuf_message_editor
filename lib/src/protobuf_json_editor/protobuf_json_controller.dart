import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A controller that manages the JSON representation of a [GeneratedMessage].
///
/// This controller leverages [toProto3Json] and [mergeFromProto3Json] to provide
/// a simplified editing model where the message is represented as a
/// [Map<String, dynamic>].
class ProtobufJsonEditingController extends ChangeNotifier {
  final GeneratedMessage? sourceMessage;
  final BuilderInfo builderInfo;
  final TypeRegistry typeRegistry;
  final void Function(Map<String, dynamic>)? onChanged;

  late Map<String, dynamic> _jsonMap;
  late final Map<String, FieldInfo> _jsonKeyToFieldInfo;

  bool _isDirty = false;

  /// Creates a root controller for a [GeneratedMessage].
  ProtobufJsonEditingController({
    required this.sourceMessage,
    this.typeRegistry = const TypeRegistry.empty(),
  }) : builderInfo = sourceMessage!.info_,
       onChanged = null {
    _jsonMap = Map<String, dynamic>.from(
      sourceMessage!.toProto3Json(typeRegistry: typeRegistry)
          as Map<String, dynamic>,
    );
    _initializeFieldLookup();
  }

  /// Creates a sub-controller for a nested message fragment.
  ProtobufJsonEditingController.submessage({
    required Map<String, dynamic> initialValue,
    required BuilderInfo builderInfo,
    this.typeRegistry = const TypeRegistry.empty(),
    this.onChanged,
  }) : sourceMessage = null,
       builderInfo = _resolveBuilderInfo(
         builderInfo,
         initialValue,
         typeRegistry,
       ),
       _jsonMap = Map<String, dynamic>.from(initialValue) {
    _initializeFieldLookup();
  }

  static BuilderInfo _resolveBuilderInfo(
    BuilderInfo info,
    Map<String, dynamic> json,
    TypeRegistry registry,
  ) {
    if (info.qualifiedMessageName == 'google.protobuf.Any' &&
        json.containsKey('@type')) {
      final typeUrl = json['@type'] as String;
      // typeUrl is usually "type.googleapis.com/package.Message"
      final qualifiedName = typeUrl.split('/').last;
      final resolved = registry.lookup(qualifiedName);
      if (resolved != null) {
        return resolved;
      }
    }
    return info;
  }

  void _initializeFieldLookup() {
    // Build mapping from JSON key (FieldInfo.name) to FieldInfo
    _jsonKeyToFieldInfo = {
      for (final field in builderInfo.fieldInfo.values) field.name: field,
    };
  }

  /// The current JSON representation of the message.
  Map<String, dynamic> get jsonMap => _jsonMap;

  /// Whether the JSON representation has been modified since initialization or the last save.
  bool get isDirty => _isDirty;

  /// Retrieves the [FieldInfo] for a given JSON key.
  FieldInfo? getFieldInfo(String jsonKey) => _jsonKeyToFieldInfo[jsonKey];

  /// Updates a field in the JSON map.
  ///
  /// For nested fields, the [key] should be the top-level key in this controller's map.
  /// Use recursive controllers or deep-update logic for nested messages.
  void updateField(String key, dynamic value) {
    if (_jsonMap[key] == value) return;

    _onBeforeFieldUpdate(key);

    _jsonMap[key] = value;
    _isDirty = true;
    onChanged?.call(_jsonMap);
    notifyListeners();
  }

  /// Adds a previously unset field with a default value.
  ///
  /// For `google.protobuf.Any` fields, an optional [typeUrl] can be provided
  /// to automatically set the `@type` field.
  void addField(String key, {String? typeUrl}) {
    if (_jsonMap.containsKey(key)) return;

    final fieldInfo = _jsonKeyToFieldInfo[key];
    if (fieldInfo == null) return;

    _onBeforeFieldUpdate(key);

    if (fieldInfo.isAnyField && typeUrl != null) {
      _jsonMap[key] = <String, dynamic>{'@type': typeUrl};
    } else {
      _jsonMap[key] = fieldInfo.getDefaultValue();
    }

    _isDirty = true;
    onChanged?.call(_jsonMap);
    notifyListeners();
  }

  /// Removes a field from the JSON map.
  void removeField(String key) {
    if (!_jsonMap.containsKey(key)) return;

    _jsonMap.remove(key);
    _isDirty = true;
    onChanged?.call(_jsonMap);
    notifyListeners();
  }

  void _onBeforeFieldUpdate(String key) {
    final fieldInfo = _jsonKeyToFieldInfo[key];
    final oneofIndex = fieldInfo != null
        ? builderInfo.oneofs[fieldInfo.tagNumber]
        : null;

    if (oneofIndex != null) {
      // Clear other fields in the same oneof group
      final oneofFields = builderInfo.fieldInfo.values.where(
        (f) => builderInfo.oneofs[f.tagNumber] == oneofIndex && f.name != key,
      );
      for (final other in oneofFields) {
        _jsonMap.remove(other.name);
      }
    }
  }

  /// Replaces the entire JSON map. Useful for bulk updates or resets.
  void updateFullJson(Map<String, dynamic> newJson) {
    _jsonMap = Map.from(newJson);
    _isDirty = true;
    onChanged?.call(_jsonMap);
    notifyListeners();
  }

  /// Returns a fresh [GeneratedMessage] populated with the current JSON state.
  ///
  /// The returned message is always mutable (not frozen) and represents the
  /// current contents of the editor.
  ///
  /// Any `google.protobuf.Any` fields that are missing their required `@type`
  /// key are stripped before deserialization to prevent [FormatException]s.
  GeneratedMessage getSavedMessage() {
    final sanitized = _sanitizeForSave(_jsonMap, builderInfo);
    final message = builderInfo.createEmptyInstance!();
    message.mergeFromProto3Json(sanitized, typeRegistry: typeRegistry);
    return message;
  }

  /// Recursively sanitizes a JSON map for safe deserialization.
  ///
  /// Removes entries for `google.protobuf.Any` fields whose value is a map
  /// missing the required `@type` key, which would otherwise cause
  /// `mergeFromProto3Json` to throw a [FormatException].
  ///
  /// Also recurses into nested message and repeated message fields.
  static Map<String, dynamic> _sanitizeForSave(
    Map<String, dynamic> json,
    BuilderInfo builderInfo,
  ) {
    final fieldsByName = {
      for (final field in builderInfo.fieldInfo.values) field.name: field,
    };

    final sanitized = <String, dynamic>{};

    for (final entry in json.entries) {
      final fieldInfo = fieldsByName[entry.key];

      if (fieldInfo == null) {
        // Unknown key (e.g. @type in a resolved Any) — keep as-is.
        sanitized[entry.key] = entry.value;
        continue;
      }

      if (fieldInfo.isAnyField) {
        if (fieldInfo.isRepeated && entry.value is List) {
          // Filter out empty Any entries from repeated fields.
          final filtered = (entry.value as List)
              .where((e) => e is Map<String, dynamic> && e.containsKey('@type'))
              .toList();
          if (filtered.isNotEmpty) {
            sanitized[entry.key] = filtered;
          }
        } else if (entry.value is Map<String, dynamic>) {
          final map = entry.value as Map<String, dynamic>;
          if (map.containsKey('@type')) {
            sanitized[entry.key] = map;
          }
          // else: skip — empty Any field without @type
        } else {
          sanitized[entry.key] = entry.value;
        }
      } else if (fieldInfo.isGroupOrMessage &&
          !fieldInfo.isRepeated &&
          entry.value is Map<String, dynamic>) {
        // Recurse into nested messages.
        final subBuilderInfo = fieldInfo.subBuilder?.call().info_;
        if (subBuilderInfo != null) {
          sanitized[entry.key] = _sanitizeForSave(
            entry.value as Map<String, dynamic>,
            subBuilderInfo,
          );
        } else {
          sanitized[entry.key] = entry.value;
        }
      } else if (fieldInfo.isGroupOrMessage &&
          fieldInfo.isRepeated &&
          entry.value is List) {
        // Recurse into repeated message fields.
        final subBuilderInfo = fieldInfo.subBuilder?.call().info_;
        if (subBuilderInfo != null) {
          sanitized[entry.key] = (entry.value as List).map((e) {
            if (e is Map<String, dynamic>) {
              return _sanitizeForSave(e, subBuilderInfo);
            }
            return e;
          }).toList();
        } else {
          sanitized[entry.key] = entry.value;
        }
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Saves the current JSON state.
  ///
  /// Returns a fresh [GeneratedMessage] populated with the edited content.
  /// Note: The original [sourceMessage] is NEVER mutated by this method.
  GeneratedMessage save() {
    final savedMessage = getSavedMessage();

    _isDirty = false;
    notifyListeners();
    return savedMessage;
  }

  /// Resets the JSON map to the current state of [sourceMessage].
  /// Only applicable for root controllers.
  void reset() {
    final message = sourceMessage;
    if (message != null) {
      _jsonMap = Map.from(
        message.toProto3Json(typeRegistry: typeRegistry)
            as Map<String, dynamic>,
      );
      _isDirty = false;
      notifyListeners();
    }
  }
}
