import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/default_editors/well_known/any/any_editor_registry.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_message_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A specialized field editor for `google.protobuf.Any` fields.
///
/// This editor allows selecting the message type and recursively editing
/// the resolved submessage.
class ProtobufJsonAnyFieldEditor extends StatefulWidget {
  final ProtobufJsonController controller;
  final ProtobufJsonFieldInfo fieldInfo;
  final ProtobufJsonEditorProvider? provider;
  final TypeRegistry? customTypeRegistry;

  const ProtobufJsonAnyFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    this.provider,
    this.customTypeRegistry,
  });

  @override
  State<ProtobufJsonAnyFieldEditor> createState() =>
      _ProtobufJsonAnyFieldEditorState();
}

class _ProtobufJsonAnyFieldEditorState
    extends State<ProtobufJsonAnyFieldEditor> {
  bool _isCollapsed = false;

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

    final theme = ProtobufEditorTheme.of(context);
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
          YamlIndent(
            depth: widget.fieldInfo.depth,
            child: YamlFieldRow(
              label: widget.fieldInfo.label ?? jsonKey,
              labelColor: theme.getLabelColor(widget.fieldInfo.depth),
              tooltip: parentContext.isEmpty ? null : parentContext,
              leading: YamlCollapseToggle(
                isCollapsed: _isCollapsed,
                onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
              ),
              onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
              value: _buildTypeSelector(context, typeUrl, registry, theme),
              trailing: ProtobufJsonRemoveButton(
                controller: controller,
                jsonKey: jsonKey,
                index: index,
              ),
            ),
          )
        else
          _buildTypeSelector(
            context,
            typeUrl,
            registry,
            ProtobufEditorTheme.of(context),
          ),
        if (!_isCollapsed) ...[_buildSubmessageContent(value)],
        if (!_isCollapsed && typeUrl == null)
          YamlIndent(
            depth: widget.fieldInfo.depth + 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No type selected. Use the selector above to choose a message type.',
                style: ProtobufEditorTheme.of(context).hintTextStyle,
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
    ProtobufEditorTheme theme,
  ) {
    final currentType = typeUrl?.split('/').last ?? 'Select type...';

    return InkWell(
      onTap: () async {
        if (registry is AnyEditorRegistry) {
          final typeNames = registry.availableMessageNames.toList();
          final selected = await showMenu<String>(
            context: context,
            position: _getMenuPosition(context),
            items: typeNames.map((name) {
              return PopupMenuItem(
                value: name,
                child: Text(name, style: theme.fieldValueStyle),
              );
            }).toList(),
          );

          if (selected != null) {
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
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: theme.typeBadgeDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                currentType,
                style: theme.typeBadgeStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: theme.smallIconSize,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmessageContent(Map<String, dynamic> value) {
    final controller = widget.controller;
    final jsonKey = widget.fieldInfo.jsonKey ?? '';
    final protoFieldInfo = widget.fieldInfo.fieldInfo;
    if (protoFieldInfo == null) return const SizedBox.shrink();

    final subBuilderInfo = protoFieldInfo.subBuilder?.call().info_;
    if (subBuilderInfo == null) return const SizedBox.shrink();
    final subController = ProtobufJsonSubmessageController(
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

    return ProtobufJsonMessageEditor(
      controller: subController,
      depth: widget.fieldInfo.depth + 1,
      parentFieldName: widget.fieldInfo.label ?? widget.fieldInfo.jsonKey,
      provider: widget.provider,
    );
  }

  RelativeRect _getMenuPosition(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    return RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
  }
}
