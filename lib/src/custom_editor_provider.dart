import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

@Deprecated('Use ProtobufJsonEditorProvider instead')
abstract class CustomEditorProvider {
  CustomFieldEditorBuilder? getCustomFieldBuilder(FieldIdentifier identifier) =>
      null;

  WidgetBuilder? getSubmessageEditorBuilder(
    GeneratedMessage submessage,
    GeneratedMessage? parentMessage,
    FieldInfo? fieldInfo,
  ) => null;

  dynamic Function({
    required FieldIdentifier identifier,
    required FieldInfo fieldInfo,
  })?
  getRepeatedFieldAddBuilder() => null;
}
