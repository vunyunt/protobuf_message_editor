import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/field_editors/enum_field_editor.dart';
import 'package:protobuf_message_editor/src/field_editors/proto_list_field_editor.dart';
import 'package:protobuf_message_editor/src/proto_message_editor.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';
import 'package:protobuf_message_editor/src/utils/proto_message_extensions.dart';

class ProtoFieldEditor extends StatefulWidget {
  final GeneratedMessage message;
  final FieldInfo fieldInfo;

  /// The index of the item in the list if the field is a repeated field.
  /// If field is a repeated field but listIndex is null, the field will be
  /// displayed as a list of editable fields. If specified, the field will be
  /// displayed as a single editable field that modifies the item at the given
  /// index.
  final int? listIndex;
  final dynamic Function({
    required FieldIdentifier identifier,
    required FieldInfo fieldInfo,
  })?
  repeatedFieldAddBuilder;
  final Widget Function({
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
  })
  submessageBuilder;

  const ProtoFieldEditor({
    super.key,
    required this.message,
    required this.fieldInfo,
    this.listIndex,
    this.repeatedFieldAddBuilder,
    this.submessageBuilder = defaultSubmessageBuilder,
  });

  @override
  State<ProtoFieldEditor> createState() => _ProtoFieldEditorState();

  static Widget defaultSubmessageBuilder({
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
  }) => Padding(
    padding: EdgeInsets.only(left: 12),
    child: ProtoMessageEditor(
      message: submessage,
      expansionsTileTitle: fieldInfo.name,
    ),
  );
}

class _ProtoFieldEditorState extends State<ProtoFieldEditor> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    final field = widget.message.getField(widget.fieldInfo.tagNumber);

    final initialValue = widget.fieldInfo.isRepeated && widget.listIndex != null
        ? field[widget.listIndex].toString()
        : field.toString();
    _textEditingController = TextEditingController(text: initialValue);

    assert(
      widget.listIndex == null || widget.fieldInfo.isRepeated,
      'listIndex must be null if the field is not a repeated field',
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _buildUneditableField(BuildContext context) {
    return Text(widget.message.getField(widget.fieldInfo.tagNumber).toString());
  }

  void _updateProto(String value) {
    if (value.trim().isEmpty) {
      widget.message.clearField(widget.fieldInfo.tagNumber);
    }

    widget.message.setFieldFromString(
      field: widget.fieldInfo,
      value: value,
      indexInList: widget.listIndex,
    );
  }

  Widget _buildEditableField(BuildContext context) {
    final repeatedFieldAddBuilder = widget.repeatedFieldAddBuilder;

    if (widget.fieldInfo.isRepeated && widget.listIndex == null) {
      return ProtoListFieldEditor(
        message: widget.message,
        fieldInfo: widget.fieldInfo,
        submessageBuilder: widget.submessageBuilder,
        repeatedFieldAddBuilder:
            repeatedFieldAddBuilder ??
            ProtoListFieldEditor.defaultRepeatedFieldAddBuilder,
      );
    } else if (widget.fieldInfo.isGroupOrMessage) {
      var submessage =
          widget.message.getField(widget.fieldInfo.tagNumber)
              as GeneratedMessage;

      // We automatically deep copy the submessage if it's frozen.
      // Might wanna consider letting the user decide/control this.
      if (submessage.isFrozen) {
        submessage = submessage.deepCopy();
        widget.message.setField(widget.fieldInfo.tagNumber, submessage);
      }

      return widget.submessageBuilder(
        submessage: submessage,
        fieldInfo: widget.fieldInfo,
      );
    } else if (widget.fieldInfo.containsString()) {
      return TextField(
        controller: _textEditingController,
        onChanged: _updateProto,
      );
    } else if (widget.fieldInfo.containsNumber()) {
      return TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
        ],
        onChanged: _updateProto,
      );
    } else if (widget.fieldInfo.isEnum) {
      return EnumFieldEditor(
        fieldInfo: widget.fieldInfo,
        message: widget.message,
        controller: _textEditingController,
        listIndex: widget.listIndex,
      );
    }

    return _buildUneditableField(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.fieldInfo.name, style: theme.textTheme.bodySmall),
        _buildEditableField(context),
      ],
    );
  }
}
