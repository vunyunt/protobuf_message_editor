import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';

class EnumFieldEditor extends StatefulWidget {
  final FieldInfo fieldInfo;
  final GeneratedMessage message;
  final TextEditingController controller;
  final int? listIndex;

  const EnumFieldEditor(
      {super.key,
      required this.fieldInfo,
      required this.message,
      required this.controller,
      this.listIndex});

  @override
  State<EnumFieldEditor> createState() => _EnumFieldEditorState();
}

class _EnumFieldEditorState extends State<EnumFieldEditor> {
  @override
  void initState() {
    super.initState();
    final value = widget.message.getField(widget.fieldInfo.tagNumber);
    final listIndex = widget.listIndex;

    widget.controller.text =
        listIndex != null ? value[listIndex].toString() : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final availableValues = widget.fieldInfo.enumValues ?? [];

    return DropdownMenu(
      dropdownMenuEntries: availableValues
          .map((e) => DropdownMenuEntry(value: e, label: e.name))
          .toList(),
      controller: widget.controller,
      onSelected: (final value) {
        final listIndex = widget.listIndex;

        if (listIndex != null) {
          final list =
              widget.message.getField(widget.fieldInfo.tagNumber) as List;
          list[listIndex] = value;
        } else if (value == null) {
          widget.message.clearField(widget.fieldInfo.tagNumber);
        } else {
          widget.message.setField(widget.fieldInfo.tagNumber, value);
        }
      },
    );
  }
}
