import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';

class ProtoMapAddFieldButton extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final int depth;
  final String? parentFieldName;

  const ProtoMapAddFieldButton({
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

    final parentMessageName = controller.builderInfo.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      'Message: $parentMessageName',
      if (parentFieldName != null) 'Field: $parentFieldName',
    ].join('\n');

    return ProtoMapActionButton(
      label: 'Add field...',
      icon: Icons.add,
      depth: depth,
      tooltip: 'Add field to $parentContext',
      onTap: () async {
        final selected = await showMenu<String>(
          context: context,
          position: _getMenuPosition(context),
          items: unsetFields.map((f) {
            final oneofIndex = controller.builderInfo.oneofs[f.tagNumber];
            final label = oneofIndex != null ? '${f.name} (oneof)' : f.name;
            return PopupMenuItem(
              value: f.name,
              child: Text(
                label,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            );
          }).toList(),
        );

        if (selected != null) {
          controller.addField(selected);
        }
      },
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

@Deprecated('Use ProtoMapAddFieldButton instead')
typedef ProtobufJsonAddFieldButton = ProtoMapAddFieldButton;
