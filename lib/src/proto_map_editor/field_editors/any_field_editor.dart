import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/default_editors/well_known/any/any_editor_registry.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A specialized field editor for `google.protobuf.Any` fields.
///
/// This editor allows selecting the message type and recursively editing
/// the resolved submessage.
class ProtoMapAnyFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;
  final ProtoMapEditorProvider? provider;
  final TypeRegistry? customTypeRegistry;

  final bool enabled;

  const ProtoMapAnyFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    this.provider,
    this.customTypeRegistry,
    this.enabled = true,
  });

  @override
  State<ProtoMapAnyFieldEditor> createState() => _ProtoMapAnyFieldEditorState();
}

@Deprecated('Use ProtoMapAnyFieldEditor instead')
typedef ProtobufJsonAnyFieldEditor = ProtoMapAnyFieldEditor;

class _ProtoMapAnyFieldEditorState extends State<ProtoMapAnyFieldEditor> {
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final jsonKey = widget.fieldInfo.jsonKey ?? '';
    final index = widget.fieldInfo.index;

    final rawValue = controller.jsonMap[jsonKey];
    final fieldInController = controller.getFieldInfo(jsonKey);
    // If the controller has the expected Any field, we are at the parent message level.
    // If not, we assume this is a sub-controller already focused on the Any message itself.
    final isAtParentLevel =
        fieldInController != null && fieldInController.isAnyField;

    final Map<String, dynamic> value;
    if (jsonKey.isEmpty || !isAtParentLevel) {
      value = controller.jsonMap;
    } else if (index != null && rawValue is List) {
      value =
          (index < rawValue.length ? rawValue[index] : null)
              as Map<String, dynamic>? ??
          <String, dynamic>{};
    } else {
      value = rawValue as Map<String, dynamic>? ?? <String, dynamic>{};
    }

    final typeUrl = value['@type'] as String?;
    final registry = widget.customTypeRegistry ?? controller.typeRegistry;
    // Actually looking at the file view earlier:
    // final registry = widget.customTypeRegistry ?? controller.typeRegistry;
    // Let me check any_field_editor.dart again.

    final theme = ProtoMapEditorTheme.of(context);
    final parentMessageName = widget
        .fieldInfo
        .parentBuilderInfo
        ?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (widget.fieldInfo.parentFieldName != null)
        'Field: ${widget.fieldInfo.parentFieldName}',
    ].join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (jsonKey.isNotEmpty)
          ProtoMapIndent(
            depth: widget.fieldInfo.depth,
            child: ProtoMapFieldRow(
              label: widget.fieldInfo.label ?? jsonKey,
              labelColor: theme.getLabelColor(widget.fieldInfo.depth),
              tooltip: parentContext.isEmpty ? null : parentContext,
              leading: ProtoMapCollapseToggle(
                isCollapsed: _isCollapsed,
                onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
              ),
              onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
              value: _buildTypeSelector(
                context,
                typeUrl,
                registry,
                theme,
                widget.enabled,
              ),
              trailing: ProtoMapRemoveButton(
                controller: controller,
                jsonKey: jsonKey,
                index: index,
                enabled: widget.enabled,
              ),
            ),
          )
        else
          _buildTypeSelector(
            context,
            typeUrl,
            registry,
            ProtoMapEditorTheme.of(context),
            widget.enabled,
          ),
        if (!_isCollapsed) ...[_buildSubmessageContent(value)],
        if (!_isCollapsed && typeUrl == null)
          ProtoMapIndent(
            depth: widget.fieldInfo.depth + 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No type selected. Use the selector above to choose a message type.',
                style: ProtoMapEditorTheme.of(context).hintTextStyle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    String? typeUrl,
    TypeRegistry registry,
    ProtoMapEditorTheme theme,
    bool enabled,
  ) {
    final currentType = typeUrl?.split('/').last ?? 'Select type...';
    final typeNames = registry is AnyEditorRegistry
        ? registry.availableMessageNames.toList()
        : <String>[];

    return ProtoMapBadgeDropdown(
      label: currentType,
      items: typeNames,
      enabled: enabled,
      onSelected: (selected) {
        final newTypeUrl = 'type.googleapis.com/$selected';
        final newValue = <String, dynamic>{'@type': newTypeUrl};
        final controller = widget.controller;
        final jsonKey = widget.fieldInfo.jsonKey!;

        final fieldInController = controller.getFieldInfo(jsonKey);
        final isParentController =
            fieldInController != null && fieldInController.isAnyField;

        if (isParentController) {
          if (widget.fieldInfo.index != null) {
            final raw = controller.jsonMap[jsonKey];
            final list = raw is List ? List.from(raw) : <dynamic>[];
            if (widget.fieldInfo.index! < list.length) {
              list[widget.fieldInfo.index!] = newValue;
            } else {
              list.add(newValue);
            }
            controller.updateField(jsonKey, list);
          } else {
            controller.updateField(jsonKey, newValue);
          }
        } else {
          controller.updateFullJson(newValue);
        }
      },
    );
  }

  Widget _buildSubmessageContent(Map<String, dynamic> value) {
    final controller = widget.controller;
    final jsonKey = widget.fieldInfo.jsonKey ?? '';
    final protoFieldInfo = widget.fieldInfo.fieldInfo;
    if (protoFieldInfo == null) return const SizedBox.shrink();

    final subBuilderInfo = protoFieldInfo.subBuilder?.call().info_;
    if (subBuilderInfo == null) return const SizedBox.shrink();
    final subController = ProtoMapSubmessageController(
      initialValue: value,
      builderInfo: subBuilderInfo,
      typeRegistry: widget.customTypeRegistry ?? controller.typeRegistry,
      onChanged: (newMap) {
        final fieldInController = controller.getFieldInfo(jsonKey);
        final isParentController =
            fieldInController != null && fieldInController.isAnyField;

        if (jsonKey.isEmpty || !isParentController) {
          controller.updateFullJson(newMap);
        } else if (widget.fieldInfo.index != null) {
          final raw = controller.jsonMap[jsonKey];
          final list = raw is List ? List.from(raw) : <dynamic>[];
          if (widget.fieldInfo.index! < list.length) {
            list[widget.fieldInfo.index!] = newMap;
          } else {
            list.add(newMap);
          }
          controller.updateField(jsonKey, list);
        } else {
          controller.updateField(jsonKey, newMap);
        }
      },
    );

    return ProtoMapMessageEditor(
      controller: subController,
      depth: widget.fieldInfo.depth + 1,
      parentFieldName: widget.fieldInfo.label ?? widget.fieldInfo.jsonKey,
      provider: widget.provider,
      enabled: widget.enabled,
    );
  }
}
