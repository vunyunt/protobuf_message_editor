import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_add_field_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

class ProtobufJsonFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int depth;

  const ProtobufJsonFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.depth = 0,
  });

  @override
  State<ProtobufJsonFieldEditor> createState() =>
      _ProtobufJsonFieldEditorState();
}

class _ProtobufJsonFieldEditorState extends State<ProtobufJsonFieldEditor> {
  @override
  Widget build(BuildContext context) {
    if (widget.jsonKey.isEmpty) {
      // Special case: Render all fields of the controller's map (naked message)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.controller.jsonMap.keys.map(
            (key) => ProtobufJsonFieldEditor(
              controller: widget.controller,
              jsonKey: key,
              depth: widget.depth,
            ),
          ),
          ProtobufJsonAddFieldButton(
            controller: widget.controller,
            depth: widget.depth,
          ),
        ],
      );
    }

    final fieldInfo = widget.controller.getFieldInfo(widget.jsonKey);

    if (fieldInfo == null) {
      // Fallback for keys that don't match FieldInfo (e.g., @type in Any)
      return ProtobufJsonFallbackFieldEditor(
        controller: widget.controller,
        jsonKey: widget.jsonKey,
        depth: widget.depth,
      );
    }

    final oneofIndex =
        widget.controller.builderInfo.oneofs[fieldInfo.tagNumber];
    final label = oneofIndex != null
        ? '${widget.jsonKey} (oneof)'
        : widget.jsonKey;

    if (fieldInfo.isRepeated) {
      return ProtobufJsonRepeatedFieldEditor(
        controller: widget.controller,
        jsonKey: widget.jsonKey,
        depth: widget.depth,
        label: label,
        fieldInfo: fieldInfo,
      );
    }

    if (fieldInfo.isBoolField) {
      return ProtobufJsonBooleanFieldEditor(
        controller: widget.controller,
        jsonKey: widget.jsonKey,
        depth: widget.depth,
        label: label,
      );
    }

    if (fieldInfo.isMessageField && !fieldInfo.isScalarMessage) {
      return ProtobufJsonMessageFieldEditor(
        controller: widget.controller,
        jsonKey: widget.jsonKey,
        depth: widget.depth,
        label: label,
        fieldInfo: fieldInfo,
      );
    }

    if (fieldInfo.isEnumField) {
      return ProtobufJsonEnumFieldEditor(
        controller: widget.controller,
        jsonKey: widget.jsonKey,
        depth: widget.depth,
        label: label,
        fieldInfo: fieldInfo,
      );
    }

    return ProtobufJsonScalarFieldEditor(
      controller: widget.controller,
      jsonKey: widget.jsonKey,
      depth: widget.depth,
      label: label,
      fieldInfo: fieldInfo,
    );
  }
}
