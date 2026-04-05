import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/default_editors/well_known/any/any_editor_registry.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/field_editors/remove_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for repeated fields (lists).
class ProtobufJsonRepeatedFieldEditor extends StatefulWidget {
  final ProtobufJsonEditingController controller;
  final String jsonKey;
  final int depth;
  final String label;
  final FieldInfo fieldInfo;

  const ProtobufJsonRepeatedFieldEditor({
    super.key,
    required this.controller,
    required this.jsonKey,
    required this.depth,
    required this.label,
    required this.fieldInfo,
  });

  @override
  State<ProtobufJsonRepeatedFieldEditor> createState() =>
      _ProtobufJsonRepeatedFieldEditorState();
}

class _ProtobufJsonRepeatedFieldEditorState
    extends State<ProtobufJsonRepeatedFieldEditor> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.jsonMap[widget.jsonKey] as List;

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
            trailing: ProtobufJsonRemoveButton(
              controller: widget.controller,
              jsonKey: widget.jsonKey,
            ),
          ),
        ),
        if (!_isCollapsed)
          ...value.asMap().entries.map((entry) {
            final index = entry.key;
            return ProtobufJsonFieldEditor(
              controller: widget.controller,
              jsonKey: widget.jsonKey,
              index: index,
              depth: widget.depth + 1,
            );
          }),
        if (!_isCollapsed)
          YamlIndent(
            depth: widget.depth + 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: InkWell(
                onTap: () async {
                  final newList = List.from(value);
                  dynamic defaultValue = widget.fieldInfo.getDefaultValue(
                    forElement: true,
                  );

                  if (widget.fieldInfo.isAnyField) {
                    final registry = widget.controller.typeRegistry;
                    if (registry is AnyEditorRegistry) {
                      final typeNames = registry.availableMessageNames.toList();
                      final selectedType = await showMenu<String>(
                        context: context,
                        position: _getMenuPosition(context),
                        items: typeNames.map((name) {
                          return PopupMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                      if (selectedType == null) return;

                      defaultValue = <String, dynamic>{
                        '@type': 'type.googleapis.com/$selectedType',
                      };
                    }
                  }

                  newList.add(defaultValue);
                  widget.controller.updateField(widget.jsonKey, newList);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add element',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
