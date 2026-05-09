import 'package:protobuf/protobuf.dart';

/// Metadata for a protobuf-json field being edited.
class ProtoMapFieldInfo {
  /// The [FieldInfo] for the field (from package:protobuf).
  final FieldInfo? fieldInfo;

  /// The JSON key of the field.
  final String? jsonKey;

  /// The index of the element if this is a repeated field.
  final int? index;

  /// The key of the element if this is a map field.
  final String? mapKey;

  /// The indentation depth.
  final int depth;

  /// The display label for the field.
  final String? label;

  /// The name of the parent field that contains this message/list.
  final String? parentFieldName;

  /// The metadata of the parent message.
  final BuilderInfo? parentBuilderInfo;

  /// The metadata of the submessage if this is a message field.
  final BuilderInfo? submessageBuilderInfo;

  /// Whether this is a map field.
  final bool isMapField;

  /// The [PbFieldType] of the keys if this is a map field.
  final int? mapKeyFieldType;

  /// The [PbFieldType] of the values if this is a map field.
  final int? mapValueFieldType;

  const ProtoMapFieldInfo({
    this.fieldInfo,
    this.jsonKey,
    this.index,
    this.mapKey,
    this.depth = 0,
    this.label,
    this.parentFieldName,
    this.parentBuilderInfo,
    this.submessageBuilderInfo,
    this.isMapField = false,
    this.mapKeyFieldType,
    this.mapValueFieldType,
  });

  /// Creates a copy of this [ProtoMapFieldInfo] with some fields replaced.
  ProtoMapFieldInfo copyWith({
    FieldInfo? fieldInfo,
    String? jsonKey,
    int? index,
    String? mapKey,
    int? depth,
    String? label,
    String? parentFieldName,
    BuilderInfo? parentBuilderInfo,
    BuilderInfo? submessageBuilderInfo,
    bool? isMapField,
    int? mapKeyFieldType,
    int? mapValueFieldType,
  }) {
    return ProtoMapFieldInfo(
      fieldInfo: fieldInfo ?? this.fieldInfo,
      jsonKey: jsonKey ?? this.jsonKey,
      index: index ?? this.index,
      mapKey: mapKey ?? this.mapKey,
      depth: depth ?? this.depth,
      label: label ?? this.label,
      parentFieldName: parentFieldName ?? this.parentFieldName,
      parentBuilderInfo: parentBuilderInfo ?? this.parentBuilderInfo,
      submessageBuilderInfo:
          submessageBuilderInfo ?? this.submessageBuilderInfo,
      isMapField: isMapField ?? this.isMapField,
      mapKeyFieldType: mapKeyFieldType ?? this.mapKeyFieldType,
      mapValueFieldType: mapValueFieldType ?? this.mapValueFieldType,
    );
  }
}

@Deprecated('Use ProtoMapFieldInfo instead')
typedef ProtobufJsonFieldInfo = ProtoMapFieldInfo;
