import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';

/// Metadata for a protobuf-json field being edited.
class ProtobufJsonFieldInfo {
  /// The [FieldInfo] for the field (from package:protobuf).
  final FieldInfo? fieldInfo;

  /// The JSON key of the field.
  final String? jsonKey;

  /// The index of the element if this is a repeated field.
  final int? index;

  /// The indentation depth.
  final int depth;

  /// The display label for the field.
  final String? label;

  /// The metadata of the parent message.
  final BuilderInfo? parentBuilderInfo;

  /// The metadata of the submessage if this is a message field.
  final BuilderInfo? submessageBuilderInfo;

  const ProtobufJsonFieldInfo({
    this.fieldInfo,
    this.jsonKey,
    this.index,
    this.depth = 0,
    this.label,
    this.parentBuilderInfo,
    this.submessageBuilderInfo,
  });

  /// Creates a copy of this [ProtobufJsonFieldInfo] with some fields replaced.
  ProtobufJsonFieldInfo copyWith({
    FieldInfo? fieldInfo,
    String? jsonKey,
    int? index,
    int? depth,
    String? label,
    BuilderInfo? parentBuilderInfo,
    BuilderInfo? submessageBuilderInfo,
  }) {
    return ProtobufJsonFieldInfo(
      fieldInfo: fieldInfo ?? this.fieldInfo,
      jsonKey: jsonKey ?? this.jsonKey,
      index: index ?? this.index,
      depth: depth ?? this.depth,
      label: label ?? this.label,
      parentBuilderInfo: parentBuilderInfo ?? this.parentBuilderInfo,
      submessageBuilderInfo:
          submessageBuilderInfo ?? this.submessageBuilderInfo,
    );
  }
}
