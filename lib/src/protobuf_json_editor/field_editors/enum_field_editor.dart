import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for enum values.
class ProtobufJsonEnumFieldEditor extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;

  const ProtobufJsonEnumFieldEditor({
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
    final currentName = fieldInfo.getEnumName(value);

    return YamlIndent(
      depth: depth,
      child: YamlFieldRow(
        label: label,
        value: SizedBox(
          height: 24,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentName,
              isDense: true,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.blue,
              ),
              items: fieldInfo.enumValues!
                  .map(
                    (e) => DropdownMenuItem(value: e.name, child: Text(e.name)),
                  )
                  .toList(),
              onChanged: (newName) {
                if (newName != null) {
                  controller.updateField(jsonKey, newName);
                }
              },
            ),
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
