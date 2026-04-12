import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/styled_widgets.dart';

/// A fallback editor for fields without [FieldInfo].
class ProtobufJsonFallbackFieldEditor extends StatelessWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;

  const ProtobufJsonFallbackFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
  });

  @override
  Widget build(BuildContext context) {
    final jsonKey = fieldInfo.jsonKey!;
    final value = controller.jsonMap[jsonKey];

    return ProtobufJsonIndent(
      depth: fieldInfo.depth,
      child: ProtobufJsonFieldRow(
        label: jsonKey,
        value: Text(
          value.toString(),
          style: ProtobufEditorTheme.of(context).hintTextStyle,
        ),
        trailing: ProtobufJsonRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
        ),
      ),
    );
  }
}
