import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for enum values.
class ProtobufJsonEnumFieldEditor extends StatelessWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;

  const ProtobufJsonEnumFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
  });

  @override
  Widget build(BuildContext context) {
    final jsonKey = fieldInfo.jsonKey!;
    final index = fieldInfo.index;
    final protoFieldInfo = fieldInfo.fieldInfo!;

    final rawValue = controller.jsonMap[jsonKey];
    final value = (index != null && rawValue is List)
        ? rawValue[index]
        : rawValue;
    final currentName = protoFieldInfo.getEnumName(value);

    final theme = ProtobufEditorTheme.of(context);

    return YamlIndent(
      depth: fieldInfo.depth,
      child: YamlFieldRow(
        label: fieldInfo.label!,
        value: SizedBox(
          height: theme.fieldValueHeight,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentName,
              isDense: true,
              style: theme.enumValueStyle,
              items: protoFieldInfo.enumValues!
                  .map(
                    (e) => DropdownMenuItem(value: e.name, child: Text(e.name)),
                  )
                  .toList(),
              onChanged: (newName) {
                if (newName != null) {
                  if (index != null) {
                    final list = List.from(controller.jsonMap[jsonKey] as List);
                    list[index] = newName;
                    controller.updateField(jsonKey, list);
                  } else {
                    controller.updateField(jsonKey, newName);
                  }
                }
              },
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
