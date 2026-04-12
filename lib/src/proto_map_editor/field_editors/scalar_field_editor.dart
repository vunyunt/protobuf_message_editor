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

    return ProtoMapIndent(
      depth: fieldInfo.depth,
      child: ProtoMapFieldRow(
        label: fieldInfo.label ?? fieldInfo.jsonKey ?? '',
        labelColor: theme.getLabelColor(fieldInfo.depth),
        tooltip: parentContext.isEmpty ? null : parentContext,
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
              final typedValue = fieldInfo.fieldInfo!.castString(newValue);
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
        trailing: ProtoMapRemoveButton(
          controller: controller,
          jsonKey: fieldInfo.jsonKey!,
          index: fieldInfo.index,
        ),
      ),
    );
  }
}
