import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for enum values.
class ProtoMapEnumFieldEditor extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  const ProtoMapEnumFieldEditor({
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
        trailing: ProtoMapRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
          index: index,
        ),
      ),
    );
  }
}

@Deprecated('Use ProtoMapEnumFieldEditor instead')
typedef ProtobufJsonEnumFieldEditor = ProtoMapEnumFieldEditor;
