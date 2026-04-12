import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';

/// A minimalist toggle for expanding/collapsing sections.
///
/// NOTE: This component is intended to provide a YAML-like visual layout,
/// but it does not strictly follow YAML formatting rules.
class ProtobufJsonCollapseToggle extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const ProtobufJsonCollapseToggle({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtobufEditorTheme.of(context);

    return GestureDetector(
      onTap: onToggle,
      child: Icon(
        isCollapsed ? Icons.chevron_right : Icons.expand_more,
        size: theme.collapseIconSize,
        color: theme.collapseToggleColor,
      ),
    );
  }
}
