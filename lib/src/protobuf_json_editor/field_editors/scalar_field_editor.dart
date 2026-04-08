import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for scalar values (int, string, double, bytes).
class ProtobufJsonScalarFieldEditor extends StatefulWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;

  const ProtobufJsonScalarFieldEditor({
    super.key,
    required this.controller,
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
    final rawValue = widget.controller.jsonMap[widget.fieldInfo.jsonKey];
    if (widget.fieldInfo.index != null && rawValue is List) {
      return rawValue[widget.fieldInfo.index!];
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
    final theme = ProtobufEditorTheme.of(context);

    return YamlIndent(
      depth: widget.fieldInfo.depth,
      child: YamlFieldRow(
        label: widget.fieldInfo.label!,
        value: SizedBox(
          height: theme.fieldValueHeight,
          child: TextField(
            controller: _textController,
            style: theme.fieldValueStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'null',
              hintStyle: theme.hintTextStyle,
            ),
            onChanged: (newValue) {
              final typedValue = widget.fieldInfo.fieldInfo!.castString(
                newValue,
              );
              final jsonKey = widget.fieldInfo.jsonKey!;

              if (widget.fieldInfo.index != null) {
                final list = List.from(
                  widget.controller.jsonMap[jsonKey] as List,
                );
                list[widget.fieldInfo.index!] = typedValue;
                widget.controller.updateField(jsonKey, list);
              } else {
                widget.controller.updateField(jsonKey, typedValue);
              }
            },
          ),
        ),
        trailing: ProtobufJsonRemoveButton(
          controller: widget.controller,
          jsonKey: widget.fieldInfo.jsonKey!,
          index: widget.fieldInfo.index,
        ),
      ),
    );
  }
}
