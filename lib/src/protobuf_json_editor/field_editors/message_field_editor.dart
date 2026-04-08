import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_message_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A field editor for message values (nested objects).
class ProtobufJsonMessageFieldEditor extends StatefulWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonMessageFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    this.provider,
  });

  @override
  State<ProtobufJsonMessageFieldEditor> createState() =>
      _ProtobufJsonMessageFieldEditorState();
}

class _ProtobufJsonMessageFieldEditorState
    extends State<ProtobufJsonMessageFieldEditor> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final jsonKey = widget.fieldInfo.jsonKey!;
    final index = widget.fieldInfo.index;

    final rawValue = widget.controller.jsonMap[jsonKey];
    final value = (index != null && rawValue is List)
        ? (index < rawValue.length ? rawValue[index] : null)
                  as Map<String, dynamic>? ??
              <String, dynamic>{}
        : rawValue as Map<String, dynamic>? ?? <String, dynamic>{};

    final theme = ProtobufEditorTheme.of(context);

    final parentMessageName = widget
        .fieldInfo
        .parentBuilderInfo
        ?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (widget.fieldInfo.parentFieldName != null)
        'Field: ${widget.fieldInfo.parentFieldName}',
    ].join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamlIndent(
          depth: widget.fieldInfo.depth,
          child: YamlFieldRow(
            label: widget.fieldInfo.label ?? jsonKey,
            labelColor: theme.getLabelColor(widget.fieldInfo.depth),
            tooltip: parentContext.isEmpty ? null : parentContext,
            leading: YamlCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            value: Text(
              widget.fieldInfo.submessageBuilderInfo?.qualifiedMessageName
                      .split('.')
                      .last ??
                  '',
              style: theme.fieldValueStyle.copyWith(
                color: theme.getLabelColor(widget.fieldInfo.depth),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: ProtobufJsonRemoveButton(
              controller: widget.controller,
              jsonKey: jsonKey,
              index: index,
            ),
          ),
        ),
        if (!_isCollapsed) ...[_buildSubmessageContent(value)],
      ],
    );
  }

  Widget _buildSubmessageContent(Map<String, dynamic> value) {
    final jsonKey = widget.fieldInfo.jsonKey!;
    final controller = widget.controller;
    final subBuilderInfo = widget.fieldInfo.submessageBuilderInfo;

    if (subBuilderInfo == null) return const SizedBox.shrink();

    final subController = ProtobufJsonSubmessageController(
      initialValue: value,
      builderInfo: subBuilderInfo,
      typeRegistry: controller.typeRegistry,
      onChanged: (newMap) {
        if (widget.fieldInfo.index != null) {
          final raw = controller.jsonMap[jsonKey];
          final list = raw is List ? List.from(raw) : <dynamic>[];
          if (widget.fieldInfo.index! < list.length) {
            list[widget.fieldInfo.index!] = newMap;
          } else {
            list.add(newMap);
          }
          controller.updateField(jsonKey, list);
        } else {
          controller.updateField(jsonKey, newMap);
        }
      },
    );

    return ProtobufJsonMessageEditor(
      controller: subController,
      depth: widget.fieldInfo.depth + 1,
      parentFieldName: widget.fieldInfo.label ?? widget.fieldInfo.jsonKey,
      provider: widget.provider,
    );
  }
}
