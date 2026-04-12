import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/styled_widgets/protobuf_json_indent.dart';

/// A stylized action button used for "Add field" and "Add element" actions.
class ProtobufJsonActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? depth;

  const ProtobufJsonActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtobufEditorTheme.of(context);

    Widget button = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: theme.collapseIconSize,
              child: Center(
                child: Icon(
                  icon,
                  size: theme.smallIconSize,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: theme.actionButtonStyle),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    if (depth != null) {
      button = ProtobufJsonIndent(depth: depth!, child: button);
    }

    return button;
  }
}
