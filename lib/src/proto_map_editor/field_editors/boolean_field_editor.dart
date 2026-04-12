import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';

/// A field editor for boolean values.
class ProtoMapBooleanFieldEditor extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  const ProtoMapBooleanFieldEditor({
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

    final theme = ProtoMapEditorTheme.of(context);

    final parentMessageName = fieldInfo.parentBuilderInfo?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (fieldInfo.parentFieldName != null)
        'Field: ${fieldInfo.parentFieldName}',
    ].join('\n');

    return ProtoMapIndent(
      depth: fieldInfo.depth,
      child: ProtoMapFieldRow(
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
        trailing: ProtoMapRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
          index: index,
        ),
      ),
    );
  }
}

@Deprecated('Use ProtoMapBooleanFieldEditor instead')
typedef ProtobufJsonBooleanFieldEditor = ProtoMapBooleanFieldEditor;
