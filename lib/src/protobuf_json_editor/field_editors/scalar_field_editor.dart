import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for scalar values (int, string, double, bytes).
class ProtobufJsonScalarFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;

  const ProtobufJsonScalarFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    required this.depth,
    required this.label,
    required this.fieldInfo,
  });

  @override
  State<ProtobufJsonScalarFieldEditor> createState() =>
      _ProtobufJsonScalarFieldEditorState();
}

class _ProtobufJsonScalarFieldEditorState
    extends State<ProtobufJsonScalarFieldEditor> {
  late final TextEditingController _textController;

  dynamic _getValue() {
    final rawValue = widget.controller.jsonMap[widget.jsonKey];
    if (widget.index != null && rawValue is List) {
      return rawValue[widget.index!];
    }
    return rawValue;
  }

  @override
  void initState() {
    super.initState();
    final value = _getValue();
    _textController = TextEditingController(text: value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(ProtobufJsonScalarFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = _getValue();
    final text = value?.toString() ?? '';
    if (_textController.text != text) {
      _textController.text = text;
      _textController.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YamlIndent(
      depth: widget.depth,
      child: YamlFieldRow(
        label: widget.label,
        value: SizedBox(
          height: 24,
          child: TextField(
            controller: _textController,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'null',
            ),
            onChanged: (newValue) {
              final typedValue = widget.fieldInfo.castString(newValue);
              if (widget.index != null) {
                final list = List.from(
                  widget.controller.jsonMap[widget.jsonKey] as List,
                );
                list[widget.index!] = typedValue;
                widget.controller.updateField(widget.jsonKey, list);
              } else {
                widget.controller.updateField(widget.jsonKey, typedValue);
              }
            },
          ),
        ),
        trailing: ProtobufJsonRemoveButton(
          controller: widget.controller,
          jsonKey: widget.jsonKey,
          index: widget.index,
        ),
      ),
    );
  }
}
