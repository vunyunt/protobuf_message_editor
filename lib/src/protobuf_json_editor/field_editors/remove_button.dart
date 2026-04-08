import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';

class ProtobufJsonRemoveButton extends StatelessWidget {
  final ProtobufJsonController controller;
  final String jsonKey;
  final int? index;

  const ProtobufJsonRemoveButton({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (index != null) {
          final list = List.from(controller.jsonMap[jsonKey] as List);
          list.removeAt(index!);
          controller.updateField(jsonKey, list);
        } else {
          controller.removeField(jsonKey);
        }
      },
      child: Icon(
        Icons.close,
        size: ProtobufEditorTheme.of(context).smallIconSize,
        color: ProtobufEditorTheme.of(context).removeButtonColor,
      ),
    );
  }
}
