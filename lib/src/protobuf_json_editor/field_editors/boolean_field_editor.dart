import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A field editor for boolean values.
class ProtobufJsonBooleanFieldEditor extends StatelessWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;

  const ProtobufJsonBooleanFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
  });

  @override
  Widget build(BuildContext context) {
    final jsonKey = fieldInfo.jsonKey!;
    final index = fieldInfo.index;

    final rawValue = controller.jsonMap[jsonKey];
    final value = (index != null && rawValue is List)
        ? rawValue[index] as bool? ?? false
        : rawValue as bool? ?? false;

    final theme = ProtobufEditorTheme.of(context);

    final parentMessageName = fieldInfo.parentBuilderInfo?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (fieldInfo.parentFieldName != null)
        'Field: ${fieldInfo.parentFieldName}',
    ].join('\n');

    return YamlIndent(
      depth: fieldInfo.depth,
      child: YamlFieldRow(
        label: fieldInfo.label ?? fieldInfo.jsonKey ?? '',
        labelColor: theme.getLabelColor(fieldInfo.depth),
        tooltip: parentContext.isEmpty ? null : parentContext,
        value: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: theme.fieldValueHeight,
            child: Switch(
              value: value,
              onChanged: (newValue) {
                if (index != null) {
                  final list = List.from(controller.jsonMap[jsonKey] as List);
                  list[index] = newValue;
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
