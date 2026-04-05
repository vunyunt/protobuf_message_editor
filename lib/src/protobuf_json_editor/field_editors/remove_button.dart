import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';

class ProtobufJsonRemoveButton extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;

  const ProtobufJsonRemoveButton({
    super.key,
    required this.controller,
    required this.jsonKey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.removeField(jsonKey),
      child: const Icon(Icons.close, size: 14, color: Colors.grey),
    );
  }
}
