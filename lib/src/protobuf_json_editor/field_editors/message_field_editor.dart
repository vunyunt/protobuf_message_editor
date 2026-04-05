import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_add_field_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A field editor for message values (nested objects).
class ProtobufJsonMessageFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonMessageFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    required this.depth,
    required this.label,
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
    final rawValue = widget.controller.jsonMap[widget.jsonKey];
    final value = (widget.index != null && rawValue is List)
        ? rawValue[widget.index!] as Map<String, dynamic>
        : rawValue as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamlIndent(
          depth: widget.depth,
          child: YamlFieldRow(
            label: widget.label,
            leading: YamlCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            trailing: ProtobufJsonRemoveButton(
              controller: widget.controller,
              jsonKey: widget.jsonKey,
              index: widget.index,
            ),
          ),
        ),
        if (!_isCollapsed) ...[_buildSubmessageContent(value)],
      ],
    );
  }

  Widget _buildSubmessageContent(Map<String, dynamic> value) {
    final subBuilderInfo = widget.fieldInfo.subBuilder!().info_;
    final subController = ProtobufJsonEditingController.submessage(
      initialValue: value,
      builderInfo: subBuilderInfo,
      typeRegistry: widget.controller.typeRegistry,
      onChanged: (newMap) {
        if (widget.index != null) {
          final list = List.from(
            widget.controller.jsonMap[widget.jsonKey] as List,
          );
          list[widget.index!] = newMap;
          widget.controller.updateField(widget.jsonKey, list);
        } else {
          widget.controller.updateField(widget.jsonKey, newMap);
        }
      },
    );

    final customEditor = widget.provider?.getSubmessageEditor(
      messageType: subController.builderInfo.qualifiedMessageName,
      parentMessageType: widget.controller.builderInfo.qualifiedMessageName,
      fieldInfo: widget.fieldInfo,
      controller: subController,
    );

    if (customEditor != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: customEditor,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...value.keys.map(
          (key) => ProtobufJsonFieldEditor(
            controller: subController,
            jsonKey: key,
            depth: widget.depth + 1,
            provider: widget.provider,
          ),
        ),
        ProtobufJsonAddFieldButton(
          controller: subController,
          depth: widget.depth + 1,
        ),
      ],
    );
  }
}
