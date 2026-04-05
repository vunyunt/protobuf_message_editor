import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A fallback editor for unknown keys.
class ProtobufJsonFallbackFieldEditor extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int depth;

  const ProtobufJsonFallbackFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.jsonMap[jsonKey];

    return YamlIndent(
      depth: depth,
      child: YamlFieldRow(
        label: jsonKey,
        value: Text(value?.toString() ?? 'null'),
        trailing: jsonKey == '@type'
            ? null
            : ProtobufJsonRemoveButton(
                controller: controller,
                jsonKey: jsonKey,
              ),
      ),
    );
  }
}
