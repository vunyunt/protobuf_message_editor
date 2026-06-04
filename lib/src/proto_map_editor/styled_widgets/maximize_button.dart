import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';

/// A button displayed next to message fields to maximize/drill down into them.
class ProtoMapMaximizeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;

  const ProtoMapMaximizeButton({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Maximize message',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Icon(
            Icons.open_in_full,
            size: ProtoMapEditorTheme.of(context).smallIconSize,
            color: ProtoMapEditorTheme.of(context).removeButtonColor,
          ),
        ),
      ),
    );
  }
}
