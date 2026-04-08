import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/yaml_layout_components.dart';

class ProtobufJsonAddFieldButton extends StatelessWidget {
  final ProtobufJsonController controller;
  final int depth;
  final String? parentFieldName;

  const ProtobufJsonAddFieldButton({
    super.key,
    required this.controller,
    required this.depth,
    this.parentFieldName,
  });

  @override
  Widget build(BuildContext context) {
    final unsetFields =
        controller.builderInfo.fieldInfo.values
            .where((f) => !controller.jsonMap.containsKey(f.name))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    if (unsetFields.isEmpty) return const SizedBox.shrink();

    final theme = ProtobufEditorTheme.of(context);

    final parentMessageName = controller.builderInfo.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      'Message: $parentMessageName',
      if (parentFieldName != null) 'Field: $parentFieldName',
    ].join('\n');

    return YamlIndent(
      depth: depth,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Tooltip(
          message: 'Add field to $parentContext',
          child: InkWell(
            onTap: () async {
              final selected = await showMenu<String>(
                context: context,
                position: _getMenuPosition(context),
                items: unsetFields.map((f) {
                  final oneofIndex = controller.builderInfo.oneofs[f.tagNumber];
                  final label = oneofIndex != null
                      ? '${f.name} (oneof)'
                      : f.name;
                  return PopupMenuItem(
                    value: f.name,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              );

              if (selected != null) {
                controller.addField(selected);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: theme.collapseIconSize,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: theme.smallIconSize,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text('Add field...', style: theme.actionButtonStyle),
              ],
            ),
          ),
        ),
      ),
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
