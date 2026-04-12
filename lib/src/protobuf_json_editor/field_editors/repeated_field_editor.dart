import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for repeated fields (lists).
class ProtobufJsonRepeatedFieldEditor extends StatefulWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonRepeatedFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    this.provider,
  });

  @override
  State<ProtobufJsonRepeatedFieldEditor> createState() =>
      _ProtobufJsonRepeatedFieldEditorState();
}

class _ProtobufJsonRepeatedFieldEditorState
    extends State<ProtobufJsonRepeatedFieldEditor> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final fieldInfo = widget.fieldInfo;
    final jsonKey = fieldInfo.jsonKey!;
    final depth = fieldInfo.depth;
    final protoFieldInfo = fieldInfo.fieldInfo!;

    final value = controller.jsonMap[jsonKey] as List;

    final theme = ProtobufEditorTheme.of(context);
    final parentMessageName = fieldInfo.parentBuilderInfo?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (fieldInfo.parentFieldName != null)
        'Field: ${fieldInfo.parentFieldName}',
    ].join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProtobufJsonIndent(
          depth: depth,
          child: ProtobufJsonFieldRow(
            label: fieldInfo.label!,
            labelColor: theme.getLabelColor(depth),
            tooltip: parentContext.isEmpty ? null : parentContext,
            leading: ProtobufJsonCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            trailing: ProtobufJsonRemoveButton(
              controller: controller,
              jsonKey: jsonKey,
            ),
          ),
        ),
        if (!_isCollapsed)
          ...value.asMap().entries.map((entry) {
            final index = entry.key;
            return ProtobufJsonFieldEditor(
              controller: controller,
              jsonKey: jsonKey,
              index: index,
              depth: depth + 1,
              parentFieldName: fieldInfo.label ?? jsonKey,
              provider: widget.provider,
            );
          }),
        if (!_isCollapsed)
          ProtobufJsonActionButton(
            label: 'Add element',
            icon: Icons.add,
            depth: depth + 1,
            tooltip: 'Add element to ${fieldInfo.label}',
            onTap: () async {
              final newList = List.from(value);
              dynamic defaultValue = protoFieldInfo.getDefaultValue(
                forElement: true,
              );

              newList.add(defaultValue);
              controller.updateField(jsonKey, newList);
            },
          ),
      ],
    );
  }
}
