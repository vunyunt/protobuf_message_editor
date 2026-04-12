import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

class ProtobufJsonFieldEditor extends StatefulWidget {
  final ProtobufJsonController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String? parentFieldName;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    this.depth = 0,
    this.parentFieldName,
    this.provider,
  });

  @override
  State<ProtobufJsonFieldEditor> createState() =>
      _ProtobufJsonFieldEditorState();
}

class _ProtobufJsonFieldEditorState extends State<ProtobufJsonFieldEditor> {
  @override
  Widget build(BuildContext context) {
    final fieldInfo = widget.controller.getFieldInfo(widget.jsonKey);

    if (fieldInfo == null) {
      final fieldMetadata = ProtobufJsonFieldInfo(
        jsonKey: widget.jsonKey,
        depth: widget.depth,
      );
      // Fallback for keys that don't match FieldInfo (e.g., @type in Any)
      return ProtobufJsonFallbackFieldEditor(
        controller: widget.controller,
        fieldInfo: fieldMetadata,
      );
    }

    final fieldMetadata = _createFieldMetadata(fieldInfo);

    final customFieldEditor = widget.provider?.getFieldEditor(
      controller: widget.controller,
      fieldInfo: fieldMetadata,
    );
    if (customFieldEditor != null) return customFieldEditor;

    if (fieldInfo.isMessageField &&
        !fieldInfo.isScalarMessage &&
        !fieldInfo.isRepeated) {
      final subBuilderInfo = fieldInfo.subBuilder!().info_;
      final rawValue = widget.controller.jsonMap[widget.jsonKey];
      final subValue = (widget.index != null && rawValue is List)
          ? (widget.index! < rawValue.length ? rawValue[widget.index!] : null)
          : rawValue;

      final subController = ProtobufJsonSubmessageController(
        initialValue: (subValue as Map<String, dynamic>?) ?? {},
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
        controller: subController,
        fieldInfo: fieldMetadata,
      );
      if (customEditor != null) return customEditor;
    }

    return ProtobufJsonDefaultFieldEditor(
      controller: widget.controller,
      jsonKey: widget.jsonKey,
      index: widget.index,
      depth: widget.depth,
      parentFieldName: widget.parentFieldName,
      provider: widget.provider,
    );
  }

  ProtobufJsonFieldInfo _createFieldMetadata(FieldInfo fieldInfo) {
    final oneofIndex =
        widget.controller.builderInfo.oneofs[fieldInfo.tagNumber];

    final label = widget.index != null
        ? '[${widget.index}]'
        : (oneofIndex != null ? '${widget.jsonKey} (oneof)' : widget.jsonKey);

    return ProtobufJsonFieldInfo(
      fieldInfo: fieldInfo,
      jsonKey: widget.jsonKey,
      index: widget.index,
      depth: widget.depth,
      label: label,
      parentFieldName: widget.parentFieldName,
      parentBuilderInfo: widget.controller.builderInfo,
      submessageBuilderInfo:
          (fieldInfo.isMessageField && !fieldInfo.isScalarMessage)
          ? fieldInfo.subBuilder?.call().info_
          : null,
    );
  }
}

/// The built-in default editor implementation for protobuf fields.
///
/// This widget is called by [ProtobufJsonFieldEditor] as a fallback when no
/// custom editor is provided. It avoids infinite recursion by not calling
/// back into the [ProtobufJsonEditorProvider] for the same field.
class ProtobufJsonDefaultFieldEditor extends StatelessWidget {
  final ProtobufJsonController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String? parentFieldName;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonDefaultFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    this.depth = 0,
    this.parentFieldName,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final fieldInfo = controller.getFieldInfo(jsonKey);
    if (fieldInfo == null) return const SizedBox.shrink();

    final oneofIndex = controller.builderInfo.oneofs[fieldInfo.tagNumber];
    final label = index != null
        ? '[$index]'
        : (oneofIndex != null ? '$jsonKey (oneof)' : jsonKey);

    final fieldMetadata = ProtobufJsonFieldInfo(
      fieldInfo: fieldInfo,
      jsonKey: jsonKey,
      index: index,
      depth: depth,
      label: label,
      parentFieldName: parentFieldName,
      parentBuilderInfo: controller.builderInfo,
      submessageBuilderInfo:
          (fieldInfo.isMessageField && !fieldInfo.isScalarMessage)
          ? fieldInfo.subBuilder?.call().info_
          : null,
    );

    // If index != null, we are editing an element of a repeated field.
    // We should skip the isRepeated check and go straight to the type's editor.
    if (fieldInfo.isRepeated && index == null) {
      return ProtobufJsonRepeatedFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        provider: provider,
      );
    }

    if (fieldInfo.isBoolField) {
      return ProtobufJsonBooleanFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
      );
    }

    if (fieldInfo.isMessageField && !fieldInfo.isScalarMessage) {
      if (fieldInfo.isAnyField) {
        return ProtobufJsonAnyFieldEditor(
          controller: controller,
          fieldInfo: fieldMetadata,
          provider: provider,
        );
      }

      return ProtobufJsonMessageFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        provider: provider,
      );
    }

    if (fieldInfo.isEnumField) {
      return ProtobufJsonEnumFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
      );
    }

    return ProtobufJsonScalarFieldEditor(
      controller: controller,
      fieldInfo: fieldMetadata,
    );
  }
}
