import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/field_editors.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

class ProtoMapFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final String jsonKey;
  final int? index;
  final String? mapKey;
  final int depth;
  final String? parentFieldName;
  final ProtoMapEditorProvider? provider;

  final bool enabled;

  const ProtoMapFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    this.mapKey,
    this.depth = 0,
    this.parentFieldName,
    this.provider,
    this.enabled = true,
  });

  @override
  State<ProtoMapFieldEditor> createState() => _ProtoMapFieldEditorState();
}

@Deprecated('Use ProtoMapFieldEditor instead')
typedef ProtobufJsonFieldEditor = ProtoMapFieldEditor;

class _ProtoMapFieldEditorState extends State<ProtoMapFieldEditor> {
  @override
  Widget build(BuildContext context) {
    final fieldInfo = widget.controller.getFieldInfo(widget.jsonKey);

    if (fieldInfo == null) {
      final fieldMetadata = ProtoMapFieldInfo(
        jsonKey: widget.jsonKey,
        depth: widget.depth,
      );
      // Fallback for keys that don't match FieldInfo (e.g., @type in Any)
      return ProtoMapFallbackFieldEditor(
        controller: widget.controller,
        fieldInfo: fieldMetadata,
        enabled: widget.enabled,
      );
    }

    final fieldMetadata = _createFieldMetadata(fieldInfo);

    if (widget.provider?.shouldExcludeField(
          controller: widget.controller,
          fieldInfo: fieldMetadata,
        ) ??
        false) {
      return const SizedBox.shrink();
    }

    final customFieldEditor = widget.provider?.getFieldEditor(
      controller: widget.controller,
      fieldInfo: fieldMetadata,
    );
    if (customFieldEditor != null) return customFieldEditor;

    // 1. It's a map entry value and that value is a message type.
    final isEntryMessage = widget.mapKey != null &&
        fieldInfo.isMapField &&
        fieldInfo.mapValueFieldType != null &&
        (fieldInfo.mapValueFieldType! & PbFieldType.M) != 0;


    // 2. It's a regular message field (singular or an element of a list).
    // Note: We exclude Map fields here because they are handled by ProtoMapMapFieldEditor
    // unless we are specifically editing an entry value (handled by isEntryMessage above).
    final isRegularMessage = !fieldInfo.isMapField &&
        fieldInfo.isMessageField &&
        !fieldInfo.isScalarMessage &&
        (!fieldInfo.isRepeated || widget.index != null);

    if (isEntryMessage || isRegularMessage) {
      final subBuilderInfo = widget.mapKey != null
          ? (fieldInfo as dynamic).valueCreator?.call().info_
          : fieldInfo.subBuilder?.call().info_;
      
      if (subBuilderInfo != null) {
        final rawValue = widget.controller.jsonMap[widget.jsonKey];
        final subValue = (widget.index != null && rawValue is List)
            ? (widget.index! < rawValue.length ? rawValue[widget.index!] : null)
            : (widget.mapKey != null && rawValue is Map)
            ? rawValue[widget.mapKey!]
            : rawValue;
        

        final subController = ProtoMapSubmessageController(
          initialValue: (subValue is Map<String, dynamic>) ? subValue : {},
          builderInfo: subBuilderInfo,
          typeRegistry: widget.controller.typeRegistry,
          isInitialLoad: widget.controller.isInitialLoad,
          onChanged: (newMap) {
            if (widget.index != null) {
              final list = List.from(
                widget.controller.jsonMap[widget.jsonKey] as List,
              );
              list[widget.index!] = newMap;
              widget.controller.updateField(widget.jsonKey, list);
            } else if (widget.mapKey != null) {
              widget.controller.updateMapValue(
                widget.jsonKey,
                widget.mapKey!,
                newMap,
              );
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
    }

    final enabled =
        widget.enabled &&
        !(widget.provider?.isFieldUneditable(
              controller: widget.controller,
              fieldInfo: fieldMetadata,
            ) ??
            false);

    return ProtoMapDefaultFieldEditor(
      controller: widget.controller,
      jsonKey: widget.jsonKey,
      index: widget.index,
      mapKey: widget.mapKey,
      depth: widget.depth,
      parentFieldName: widget.parentFieldName,
      provider: widget.provider,
      enabled: enabled,
    );
  }

  ProtoMapFieldInfo _createFieldMetadata(FieldInfo fieldInfo) {
    final oneofIndex =
        widget.controller.builderInfo.oneofs[fieldInfo.tagNumber];

    final label = widget.index != null
        ? '[${widget.index}]'
        : (widget.mapKey != null
            ? widget.mapKey!
            : (oneofIndex != null ? '${widget.jsonKey} (oneof)' : widget.jsonKey));

    return ProtoMapFieldInfo(
      fieldInfo: fieldInfo,
      jsonKey: widget.jsonKey,
      index: widget.index,
      mapKey: widget.mapKey,
      depth: widget.depth,
      label: label,
      parentFieldName: widget.parentFieldName,
      parentBuilderInfo: widget.controller.builderInfo,
      submessageBuilderInfo: (widget.mapKey != null)
          ? (fieldInfo as dynamic).valueCreator?.call().info_
          : (fieldInfo.isMessageField && !fieldInfo.isScalarMessage)
              ? fieldInfo.subBuilder?.call().info_
              : null,
      isMapField: fieldInfo.isMapField,
      mapKeyFieldType: fieldInfo.mapKeyFieldType,
      mapValueFieldType: fieldInfo.mapValueFieldType,
    );
  }
}

/// The built-in default editor implementation for protobuf fields.
///
/// This widget is called by [ProtobufJsonFieldEditor] as a fallback when no
/// custom editor is provided. It avoids infinite recursion by not calling
/// back into the [ProtoMapEditorProvider] for the same field.
class ProtoMapDefaultFieldEditor extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final String jsonKey;
  final int? index;
  final String? mapKey;
  final int depth;
  final String? parentFieldName;
  final ProtoMapEditorProvider? provider;
  final bool enabled;

  const ProtoMapDefaultFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    this.mapKey,
    this.depth = 0,
    this.parentFieldName,
    this.provider,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final fieldInfo = controller.getFieldInfo(jsonKey);
    if (fieldInfo == null) return const SizedBox.shrink();

    final oneofIndex = controller.builderInfo.oneofs[fieldInfo.tagNumber];
    final label = index != null
        ? '[$index]'
        : (mapKey != null
            ? mapKey!
            : (oneofIndex != null ? '$jsonKey (oneof)' : jsonKey));

    final fieldMetadata = ProtoMapFieldInfo(
      fieldInfo: fieldInfo,
      jsonKey: jsonKey,
      index: index,
      mapKey: mapKey,
      depth: depth,
      label: label,
      parentFieldName: parentFieldName,
      parentBuilderInfo: controller.builderInfo,
      submessageBuilderInfo: (mapKey != null)
          ? (fieldInfo as dynamic).valueCreator?.call().info_
          : (fieldInfo.isMessageField && !fieldInfo.isScalarMessage)
              ? fieldInfo.subBuilder?.call().info_
              : null,
      isMapField: fieldInfo.isMapField,
      mapKeyFieldType: fieldInfo.mapKeyFieldType,
      mapValueFieldType: fieldInfo.mapValueFieldType,
    );

    // If index != null, we are editing an element of a repeated field.
    // We should skip the isRepeated check and go straight to the type's editor.
    if (fieldInfo.isMapField && mapKey == null) {
      return ProtoMapMapFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        provider: provider,
        enabled: enabled,
      );
    }

    if (fieldInfo.isRepeated && index == null) {
      return ProtoMapRepeatedFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        provider: provider,
        enabled: enabled,
      );
    }

    if (fieldInfo.isBoolField) {
      return ProtoMapBooleanFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        enabled: enabled,
      );
    }

    if (fieldInfo.isMessageField && !fieldInfo.isScalarMessage) {
      if (fieldInfo.isAnyField) {
        return ProtoMapAnyFieldEditor(
          controller: controller,
          fieldInfo: fieldMetadata,
          provider: provider,
          enabled: enabled,
        );
      }

      return ProtoMapMessageFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        provider: provider,
        enabled: enabled,
      );
    }

    if (fieldInfo.isEnumField) {
      return ProtoMapEnumFieldEditor(
        controller: controller,
        fieldInfo: fieldMetadata,
        enabled: enabled,
      );
    }

    return ProtoMapScalarFieldEditor(
      controller: controller,
      fieldInfo: fieldMetadata,
      enabled: enabled,
    );
  }
}

@Deprecated('Use ProtoMapDefaultFieldEditor instead')
typedef ProtobufJsonDefaultFieldEditor = ProtoMapDefaultFieldEditor;
