import 'package:flutter/material.dart';
import '../proto_map_editor_theme.dart';

/// A styled dropdown that looks like a badge, used for selecting types or options.
class ProtoMapBadgeDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const ProtoMapBadgeDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);
    return InkWell(
      onTap: () async {
        final selected = await showMenu<String>(
          context: context,
          position: _getMenuPosition(context),
          items: items.map((name) {
            return PopupMenuItem(
              value: name,
              child: Text(name, style: theme.fieldValueStyle),
            );
          }).toList(),
        );

        if (selected != null) {
          onSelected(selected);
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
                label,
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
