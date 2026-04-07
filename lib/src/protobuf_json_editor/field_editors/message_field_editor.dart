import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_message_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A field editor for message values (nested objects).
class ProtobufJsonMessageFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
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
        ? rawValue[index] as Map<String, dynamic>
        : rawValue as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamlIndent(
          depth: widget.fieldInfo.depth,
          child: YamlFieldRow(
            label: widget.fieldInfo.label!,
            leading: YamlCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
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
    final protoFieldInfo = widget.fieldInfo.fieldInfo!;

    final subBuilderInfo = protoFieldInfo.subBuilder!().info_;
    final subController = ProtobufJsonEditingController.submessage(
      initialValue: value,
      builderInfo: subBuilderInfo,
      typeRegistry: controller.typeRegistry,
      onChanged: (newMap) {
        if (widget.fieldInfo.index != null) {
          final list = List.from(controller.jsonMap[jsonKey] as List);
          list[widget.fieldInfo.index!] = newMap;
          controller.updateField(jsonKey, list);
        } else {
          controller.updateField(jsonKey, newMap);
        }
      },
    );

    // final customEditor = widget.provider?.getSubmessageEditor(
    //   controller: subController,
    //   fieldInfo: subFieldInfo,
    // );

    // if (customEditor != null) {
    //   return Padding(
    //     padding: const EdgeInsets.only(left: 16.0),
    //     child: customEditor,
    //   );
    // }

    return ProtobufJsonMessageEditor(
      controller: subController,
      depth: widget.fieldInfo.depth + 1,
      provider: widget.provider,
    );
  }
}
