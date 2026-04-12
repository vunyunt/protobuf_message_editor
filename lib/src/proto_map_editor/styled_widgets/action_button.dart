import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets/proto_map_indent.dart';

/// A stylized action button used for "Add field" and "Add element" actions.
class ProtoMapActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? depth;

  const ProtoMapActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

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
      button = ProtoMapIndent(depth: depth!, child: button);
    }

    return button;
  }
}

@Deprecated('Use ProtoMapActionButton instead')
typedef ProtobufJsonActionButton = ProtoMapActionButton;
