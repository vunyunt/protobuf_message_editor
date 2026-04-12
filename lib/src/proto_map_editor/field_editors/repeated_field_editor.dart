import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for repeated fields (lists).
class ProtoMapRepeatedFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;
  final ProtoMapEditorProvider? provider;

  const ProtoMapRepeatedFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    this.provider,
  });

  @override
  State<ProtoMapRepeatedFieldEditor> createState() =>
      _ProtoMapRepeatedFieldEditorState();
}

@Deprecated('Use ProtoMapRepeatedFieldEditor instead')
typedef ProtobufJsonRepeatedFieldEditor = ProtoMapRepeatedFieldEditor;

class _ProtoMapRepeatedFieldEditorState
    extends State<ProtoMapRepeatedFieldEditor> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final fieldInfo = widget.fieldInfo;
    final jsonKey = fieldInfo.jsonKey!;
    final depth = fieldInfo.depth;
    final protoFieldInfo = fieldInfo.fieldInfo!;

    final value = controller.jsonMap[jsonKey] as List;

    final theme = ProtoMapEditorTheme.of(context);
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
        ProtoMapIndent(
          depth: depth,
          child: ProtoMapFieldRow(
            label: fieldInfo.label!,
            labelColor: theme.getLabelColor(depth),
            tooltip: parentContext.isEmpty ? null : parentContext,
            leading: ProtoMapCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            trailing: ProtoMapRemoveButton(
              controller: controller,
              jsonKey: jsonKey,
            ),
          ),
        ),
        if (!_isCollapsed)
          ...value.asMap().entries.map((entry) {
            final index = entry.key;
            return ProtoMapFieldEditor(
              controller: controller,
              jsonKey: jsonKey,
              index: index,
              depth: depth + 1,
              parentFieldName: fieldInfo.label ?? jsonKey,
              provider: widget.provider,
            );
          }),
        if (!_isCollapsed)
          ProtoMapActionButton(
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
