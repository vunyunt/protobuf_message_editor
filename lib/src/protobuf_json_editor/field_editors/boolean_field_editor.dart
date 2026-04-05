import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A field editor for boolean values.
class ProtobufJsonBooleanFieldEditor extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String label;

  const ProtobufJsonBooleanFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    required this.depth,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final rawValue = controller.jsonMap[jsonKey];
    final value = (index != null && rawValue is List)
        ? rawValue[index!] as bool? ?? false
        : rawValue as bool? ?? false;

    return YamlIndent(
      depth: depth,
      child: YamlFieldRow(
        label: label,
        value: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: (newValue) {
                if (index != null) {
                  final list = List.from(controller.jsonMap[jsonKey] as List);
                  list[index!] = newValue;
                  controller.updateField(jsonKey, list);
                } else {
                  controller.updateField(jsonKey, newValue);
                }
              },
              activeThumbColor: Theme.of(context).primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        trailing: ProtobufJsonRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
          index: index,
        ),
      ),
    );
  }
}
