import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';

/// A base controller that manages the JSON representation of a [GeneratedMessage] fragment.
abstract class ProtoMapControllerBase {
  final BuilderInfo builderInfo;
  final TypeRegistry typeRegistry;
  final void Function(Map<String, dynamic>)? onChanged;
  bool isInitialLoad;

  late Map<String, dynamic> _jsonMap;
  late final Map<String, FieldInfo> _jsonKeyToFieldInfo;

  ProtoMapControllerBase({
    required Map<String, dynamic> initialValue,
    required this.builderInfo,
    this.typeRegistry = const TypeRegistry.empty(),
    this.onChanged,
    this.isInitialLoad = true,
  }) : _jsonMap = Map<String, dynamic>.from(initialValue) {
    _initializeFieldLookup();
  }

  void _initializeFieldLookup() {
    // Build mapping from JSON key (FieldInfo.name) to FieldInfo
    _jsonKeyToFieldInfo = {
      for (final field in builderInfo.fieldInfo.values) field.name: field,
    };
  }

  /// The current JSON representation of the message fragment.
  Map<String, dynamic> get jsonMap => _jsonMap;

  /// Retrieves the [FieldInfo] for a given JSON key.
  FieldInfo? getFieldInfo(String jsonKey) => _jsonKeyToFieldInfo[jsonKey];

  /// Normalizes a value, converting [GeneratedMessage] to its JSON representation.
  static dynamic normalizeValue(dynamic value, TypeRegistry typeRegistry) {
    if (value is GeneratedMessage) {
      return value.toProto3Json(typeRegistry: typeRegistry);
    } else if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) =>
              MapEntry(e.key.toString(), normalizeValue(e.value, typeRegistry)),
        ),
      );
    } else if (value is List) {
      return value.map((e) => normalizeValue(e, typeRegistry)).toList();
    }
    return value;
  }

  /// Updates a field in the JSON map.
  void updateField(String key, dynamic value) {
    final normalizedValue = ProtoMapControllerBase.normalizeValue(
      value,
      typeRegistry,
    );
    if (_jsonMap[key] == normalizedValue) return;

    _onBeforeFieldUpdate(key);

    _jsonMap[key] = normalizedValue;
    _notifyChange();
  }

  /// Adds a previously unset field with a default value.
  void addField(String key, {String? typeUrl, dynamic initialValue}) {
    if (_jsonMap.containsKey(key)) return;

    final fieldInfo = _jsonKeyToFieldInfo[key];
    if (fieldInfo == null) return;

    _onBeforeFieldUpdate(key);

    if (initialValue != null) {
      _jsonMap[key] = ProtoMapControllerBase.normalizeValue(
        initialValue,
        typeRegistry,
      );
    } else if (fieldInfo.isAnyField && typeUrl != null) {
      _jsonMap[key] = <String, dynamic>{'@type': typeUrl};
    } else {
      _jsonMap[key] = fieldInfo.getDefaultValue();
    }

    _notifyChange();
  }

  /// Removes a field from the JSON map.
  void removeField(String key) {
    if (!_jsonMap.containsKey(key)) return;

    _jsonMap.remove(key);
    _notifyChange();
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

  /// Renames a key in a map field.
  void renameMapKey(String fieldKey, String oldKey, String newKey) {
    if (oldKey == newKey) return;
    final map = _jsonMap[fieldKey];
    if (map is! Map<String, dynamic>) return;
    if (map.containsKey(newKey)) return; // Don't overwrite existing keys

    _onBeforeFieldUpdate(fieldKey);

    final value = map.remove(oldKey);
    map[newKey] = value;

    _notifyChange();
  }

  /// Updates a value in a map field.
  void updateMapValue(String fieldKey, String mapKey, dynamic value) {
    final rawMap = _jsonMap[fieldKey];
    if (rawMap is! Map) return;

    final map = rawMap is Map<String, dynamic>
        ? rawMap
        : Map<String, dynamic>.from(rawMap);
    _jsonMap[fieldKey] = map;

    final normalizedValue = ProtoMapControllerBase.normalizeValue(
      value,
      typeRegistry,
    );
    if (map[mapKey] == normalizedValue) return;

    _onBeforeFieldUpdate(fieldKey);

    map[mapKey] = normalizedValue;
    _notifyChange();
  }

  /// Removes a value from a map field.
  void removeMapValue(String fieldKey, String mapKey) {
    final rawMap = _jsonMap[fieldKey];
    if (rawMap is! Map) return;

    final map = rawMap is Map<String, dynamic>
        ? rawMap
        : Map<String, dynamic>.from(rawMap);
    _jsonMap[fieldKey] = map;

    _onBeforeFieldUpdate(fieldKey);

    map.remove(mapKey);
    _notifyChange();
  }

  /// Replaces the entire JSON map.
  void updateFullJson(Map<String, dynamic> newJson) {
    _jsonMap = Map<String, dynamic>.from(newJson);
    _notifyChange();
  }

  /// Internal hook called whenever the JSON map is modified.
  void _notifyChange();

  /// Returns a fresh [GeneratedMessage] populated with the current JSON state.
  GeneratedMessage getSavedMessage() {
    final sanitized = _sanitizeForSave(_jsonMap, builderInfo);
    final message = builderInfo.createEmptyInstance!();
    message.mergeFromProto3Json(sanitized, typeRegistry: typeRegistry);
    return message;
  }

  /// Recursively sanitizes a JSON map for safe deserialization.
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
        sanitized[entry.key] = entry.value;
        continue;
      }

      if (fieldInfo.isAnyField) {
        if (fieldInfo.isRepeated && entry.value is List) {
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
        } else {
          sanitized[entry.key] = entry.value;
        }
      } else if (fieldInfo.isGroupOrMessage &&
          !fieldInfo.isRepeated &&
          entry.value is Map<String, dynamic>) {
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
      } else if (fieldInfo.isMapField && entry.value is Map<String, dynamic>) {
        final valueType = fieldInfo.mapValueFieldType;
        final isMessageValue = (valueType != null &&
            (valueType & PbFieldType.MESSAGE_BIT) != 0);

        if (isMessageValue) {
          final subBuilderInfo = fieldInfo.subBuilder?.call().info_;
          if (subBuilderInfo != null) {
            final map = entry.value as Map<String, dynamic>;
            sanitized[entry.key] = map.map(
              (k, v) => MapEntry(
                k,
                (v is Map<String, dynamic>)
                    ? _sanitizeForSave(v, subBuilderInfo)
                    : v,
              ),
            );
          } else {
            sanitized[entry.key] = entry.value;
          }
        } else {
          sanitized[entry.key] = entry.value;
        }
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Safely reads the value representing [fieldInfo] from the JSON state.
  dynamic getFieldValue(ProtoMapFieldInfo fieldInfo) {
    final key = fieldInfo.jsonKey;
    if (key == null) return null;
    final raw = _jsonMap[key];
    if (fieldInfo.index != null && raw is List) {
      if (fieldInfo.index! >= 0 && fieldInfo.index! < raw.length) {
        return raw[fieldInfo.index!];
      }
      return null;
    }
    if (fieldInfo.mapKey != null && raw is Map) {
      return raw[fieldInfo.mapKey!];
    }
    return raw;
  }

  /// Safely updates the value representing [fieldInfo] in the JSON state.
  void updateFieldValue(ProtoMapFieldInfo fieldInfo, dynamic newValue) {
    final key = fieldInfo.jsonKey;
    if (key == null) return;
    if (fieldInfo.index != null) {
      final raw = _jsonMap[key];
      final list = raw is List ? List.from(raw) : <dynamic>[];
      if (fieldInfo.index! >= 0 && fieldInfo.index! < list.length) {
        list[fieldInfo.index!] = newValue;
      } else {
        list.add(newValue);
      }
      updateField(key, list);
    } else if (fieldInfo.mapKey != null) {
      updateMapValue(key, fieldInfo.mapKey!, newValue);
    } else {
      updateField(key, newValue);
    }
  }

  /// Creates and links a sub-controller for a submessage field.
  ProtoMapSubmessageController createSubmessageController(ProtoMapFieldInfo fieldInfo) {
    final key = fieldInfo.jsonKey;
    final subBuilderInfo = fieldInfo.submessageBuilderInfo;
    if (key == null || subBuilderInfo == null) {
      throw ArgumentError('jsonKey and submessageBuilderInfo must not be null');
    }

    final raw = _jsonMap[key];
    final subValue = (fieldInfo.index != null && raw is List)
        ? (fieldInfo.index! < raw.length ? raw[fieldInfo.index!] : null)
        : (fieldInfo.mapKey != null && raw is Map)
            ? raw[fieldInfo.mapKey!]
            : raw;

    return ProtoMapSubmessageController(
      initialValue: subValue is Map ? Map<String, dynamic>.from(subValue) : <String, dynamic>{},
      builderInfo: subBuilderInfo,
      typeRegistry: typeRegistry,
      isInitialLoad: isInitialLoad,
      normalize: false,
      onChanged: (newMap) {
        updateFieldValue(fieldInfo, newMap);
      },
    );
  }
}

@Deprecated('Use ProtoMapControllerBase instead')
typedef ProtobufJsonController = ProtoMapControllerBase;

/// A root controller that manages the JSON representation of a [GeneratedMessage].
///
/// This controller leverages [toProto3Json] and [mergeFromProto3Json] to provide
/// a simplified editing model where the message is represented as a
/// [Map<String, dynamic>].
class ProtoMapController extends ProtoMapControllerBase with ChangeNotifier {
  final GeneratedMessage sourceMessage;
  bool _isDirty = false;

  /// Creates a root controller for a [GeneratedMessage].
  ProtoMapController({required this.sourceMessage, super.typeRegistry})
    : super(
        initialValue:
            sourceMessage.toProto3Json(typeRegistry: typeRegistry)
                as Map<String, dynamic>,
        builderInfo: ProtoMapSubmessageController.resolveBuilderInfo(
          sourceMessage.info_,
          sourceMessage.toProto3Json(typeRegistry: typeRegistry)
              as Map<String, dynamic>,
          typeRegistry,
        ),
      );

  /// Whether the JSON representation has been modified since initialization or the last save.
  bool get isDirty => _isDirty;

  @override
  void _notifyChange() {
    _isDirty = true;
    onChanged?.call(_jsonMap);
    notifyListeners();
  }

  @override
  GeneratedMessage getSavedMessage() {
    final sanitized = ProtoMapControllerBase._sanitizeForSave(
      _jsonMap,
      builderInfo,
    );
    if (sourceMessage.info_ != builderInfo) {
      // It was resolved (e.g. from Any)
      final wrapper = sourceMessage.info_.createEmptyInstance!();
      wrapper.mergeFromProto3Json(sanitized, typeRegistry: typeRegistry);
      return wrapper;
    }
    return super.getSavedMessage();
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
  void reset() {
    _jsonMap = Map<String, dynamic>.from(
      sourceMessage.toProto3Json(typeRegistry: typeRegistry)
          as Map<String, dynamic>,
    );
    _isDirty = false;
    isInitialLoad = true;
    notifyListeners();
  }

  /// Marks the initial load as complete.
  void markInitialLoadComplete() {
    isInitialLoad = false;
  }
}

@Deprecated('Use ProtoMapController instead')
typedef ProtobufJsonEditingController = ProtoMapController;

/// A lightweight sub-controller for a nested message fragment.
///
/// Unlike [ProtoMapController], this class is not a [Listenable]
/// and does not need to be disposed. It propagates changes back to its parent
/// via the [onChanged] callback.
class ProtoMapSubmessageController extends ProtoMapControllerBase {
  ProtoMapSubmessageController({
    required dynamic initialValue,
    required BuilderInfo builderInfo,
    TypeRegistry typeRegistry = const TypeRegistry.empty(),
    void Function(Map<String, dynamic>)? onChanged,
    bool isInitialLoad = true,
    bool normalize = true,
  }) : this._internal(
         normalizedValue: normalize
             ? (ProtoMapControllerBase.normalizeValue(initialValue, typeRegistry)
                 as Map<String, dynamic>)
             : (initialValue is Map<String, dynamic>
                 ? initialValue
                 : (initialValue is Map
                     ? Map<String, dynamic>.from(initialValue)
                     : <String, dynamic>{})),
         builderInfo: builderInfo,
         typeRegistry: typeRegistry,
         onChanged: onChanged,
         isInitialLoad: isInitialLoad,
       );

  ProtoMapSubmessageController._internal({
    required Map<String, dynamic> normalizedValue,
    required BuilderInfo builderInfo,
    required super.typeRegistry,
    super.onChanged,
    required super.isInitialLoad,
  }) : super(
         initialValue: normalizedValue,
         builderInfo: resolveBuilderInfo(builderInfo, normalizedValue, typeRegistry),
       );

  @override
  void _notifyChange() {
    onChanged?.call(_jsonMap);
  }

  static BuilderInfo resolveBuilderInfo(
    BuilderInfo info,
    Map<String, dynamic> json,
    TypeRegistry registry,
  ) {
    if (info.qualifiedMessageName == 'google.protobuf.Any' &&
        json.containsKey('@type')) {
      final typeUrl = json['@type'] as String;
      final qualifiedName = typeUrl.split('/').last;
      final resolved = registry.lookup(qualifiedName);
      if (resolved != null) {
        return resolved;
      }
    }
    return info;
  }
}

@Deprecated('Use ProtoMapSubmessageController instead')
typedef ProtobufJsonSubmessageController = ProtoMapSubmessageController;
