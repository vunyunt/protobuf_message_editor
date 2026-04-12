import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for scalar values (int, string, double, bytes).
class ProtoMapScalarFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  const ProtoMapScalarFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
  });

  @override
  State<ProtoMapScalarFieldEditor> createState() =>
      _ProtoMapScalarFieldEditorState();
}

@Deprecated('Use ProtoMapScalarFieldEditor instead')
typedef ProtobufJsonScalarFieldEditor = ProtoMapScalarFieldEditor;

class _ProtoMapScalarFieldEditorState extends State<ProtoMapScalarFieldEditor> {
  late final TextEditingController _textController;
  bool _showBase64 = false;

  dynamic _getValue() {
    final rawValue = widget.controller.jsonMap[widget.fieldInfo.jsonKey];
    if (widget.fieldInfo.index != null && rawValue is List) {
      if (widget.fieldInfo.index! < rawValue.length) {
        return rawValue[widget.fieldInfo.index!];
      }
      return null;
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
  void didUpdateWidget(ProtoMapScalarFieldEditor oldWidget) {
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
    final controller = widget.controller;
    final fieldInfo = widget.fieldInfo;
    final theme = ProtoMapEditorTheme.of(context);

    final parentMessageName = fieldInfo.parentBuilderInfo?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (fieldInfo.parentFieldName != null)
        'Field: ${fieldInfo.parentFieldName}',
    ].join('\n');

    final isBytes = fieldInfo.fieldInfo?.isBytesField ?? false;
    final value = _getValue();
    final String labelSuffix;
    if (isBytes && !_showBase64) {
      final bytesCount = value is String
          ? base64.decode(value).length
          : (value is List<int> ? value.length : 0);
      labelSuffix = ' ($bytesCount bytes)';
    } else {
      labelSuffix = '';
    }

    return ProtoMapIndent(
      depth: fieldInfo.depth,
      child: ProtoMapFieldRow(
        label: '${fieldInfo.label ?? fieldInfo.jsonKey ?? ''}$labelSuffix',
        labelColor: theme.getLabelColor(fieldInfo.depth),
        tooltip: parentContext.isEmpty ? null : parentContext,
        value: SizedBox(
          height: theme.fieldValueHeight,
          child: (isBytes && !_showBase64)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Base64 hidden', style: theme.hintTextStyle),
                )
              : TextField(
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
                    final typedValue = fieldInfo.fieldInfo!.castString(
                      newValue,
                    );
                    final jsonKey = fieldInfo.jsonKey!;

                    if (fieldInfo.index != null) {
                      final raw = controller.jsonMap[jsonKey];
                      final list = raw is List ? List.from(raw) : <dynamic>[];
                      if (fieldInfo.index! < list.length) {
                        list[fieldInfo.index!] = typedValue;
                      } else {
                        list.add(typedValue);
                      }
                      controller.updateField(jsonKey, list);
                    } else {
                      controller.updateField(jsonKey, typedValue);
                    }
                  },
                ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBytes)
              IconButton(
                icon: Icon(
                  _showBase64 ? Icons.visibility_off : Icons.edit,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _showBase64 = !_showBase64;
                  });
                },
              ),
            ProtoMapRemoveButton(
              controller: controller,
              jsonKey: fieldInfo.jsonKey!,
              index: fieldInfo.index,
            ),
          ],
        ),
      ),
    );
  }
}
