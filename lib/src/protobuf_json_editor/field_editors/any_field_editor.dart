import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/default_editors/well_known/any/any_editor_registry.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_add_field_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

/// A specialized field editor for `google.protobuf.Any` fields.
///
/// This editor allows selecting the message type and recursively editing
/// the resolved submessage.
class ProtobufJsonAnyFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int? index;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;
  final ProtobufJsonEditorProvider? provider;
  final TypeRegistry? customTypeRegistry;

  const ProtobufJsonAnyFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
    required this.depth,
    required this.label,
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
    final rawValue = widget.controller.jsonMap[widget.jsonKey];
    final value = (widget.index != null && rawValue is List)
        ? rawValue[widget.index!] as Map<String, dynamic>
        : rawValue as Map<String, dynamic>;

    final typeUrl = value['@type'] as String?;
    final registry =
        widget.customTypeRegistry ?? widget.controller.typeRegistry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamlIndent(
          depth: widget.depth,
          child: YamlFieldRow(
            label: widget.label,
            leading: YamlCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            value: _buildTypeSelector(context, typeUrl, registry),
            trailing: ProtobufJsonRemoveButton(
              controller: widget.controller,
              jsonKey: widget.jsonKey,
              index: widget.index,
            ),
          ),
        ),
        if (!_isCollapsed && typeUrl != null) ...[
          _buildSubmessageContent(value, registry),
        ],
        if (!_isCollapsed && typeUrl == null)
          YamlIndent(
            depth: widget.depth + 1,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No type selected. Use the selector above to choose a message type.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
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
                child: Text(
                  name,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              );
            }).toList(),
          );

          if (selected != null) {
            final newTypeUrl = 'type.googleapis.com/$selected';
            final newValue = <String, dynamic>{'@type': newTypeUrl};

            if (widget.index != null) {
              final list = List.from(
                widget.controller.jsonMap[widget.jsonKey] as List,
              );
              list[widget.index!] = newValue;
              widget.controller.updateField(widget.jsonKey, list);
            } else {
              widget.controller.updateField(widget.jsonKey, newValue);
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                currentType,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmessageContent(
    Map<String, dynamic> value,
    TypeRegistry registry,
  ) {
    final subBuilderInfo = widget.fieldInfo.subBuilder!().info_;
    final subController = ProtobufJsonEditingController.submessage(
      initialValue: value,
      builderInfo: subBuilderInfo,
      typeRegistry: registry,
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
      messageType: subController.builderInfo.qualifiedMessageName,
      parentMessageType: widget.controller.builderInfo.qualifiedMessageName,
      fieldInfo: widget.fieldInfo,
      controller: subController,
    );

    if (customEditor != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: customEditor,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...value.keys
            .where((k) => k != '@type')
            .map(
              (key) => ProtobufJsonFieldEditor(
                controller: subController,
                jsonKey: key,
                depth: widget.depth + 1,
                provider: widget.provider,
              ),
            ),
        ProtobufJsonAddFieldButton(
          controller: subController,
          depth: widget.depth + 1,
        ),
      ],
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
