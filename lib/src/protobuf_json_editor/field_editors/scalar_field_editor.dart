import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for scalar values (int, string, double, bytes).
class ProtobufJsonScalarFieldEditor extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;

  const ProtobufJsonScalarFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    required this.depth,
    required this.label,
    required this.fieldInfo,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.jsonMap[jsonKey];

    return YamlIndent(
      depth: depth,
      child: YamlFieldRow(
        label: label,
        value: SizedBox(
          height: 24,
          child: TextField(
            controller: TextEditingController(text: value?.toString() ?? '')
              ..selection = TextSelection.collapsed(
                offset: value?.toString().length ?? 0,
              ),
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'null',
            ),
            onChanged: (newValue) {
              final typedValue = fieldInfo.castString(newValue);
              controller.updateField(jsonKey, typedValue);
            },
          ),
        ),
        trailing: ProtobufJsonRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
        ),
      ),
    );
  }
}
