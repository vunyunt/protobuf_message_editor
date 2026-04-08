import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';

/// A component that provides consistent indentation for nested message structures.
class YamlIndent extends StatelessWidget {
  final int depth;
  final Widget child;
  final double? indentWidth;

  const YamlIndent({
    super.key,
    required this.depth,
    required this.child,
    this.indentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtobufEditorTheme.of(context);
    final width = indentWidth ?? theme.indentWidth;
    if (depth <= 0) return child;

    return Padding(
      padding: EdgeInsets.only(left: depth * width),
      child: child,
    );
  }
}

/// A compact row representing a single field in the YAML-like layout.
class YamlFieldRow extends StatelessWidget {
  final String label;
  final Widget? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTapLabel;

  const YamlFieldRow({
    super.key,
    required this.label,
    this.value,
    this.leading,
    this.trailing,
    this.onTapLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtobufEditorTheme.of(context);

    return Padding(
      padding: theme.fieldRowPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          GestureDetector(
            onTap: onTapLabel,
            child: Text('$label:', style: theme.fieldLabelStyle),
          ),
          const SizedBox(width: 8),
          if (value != null) Expanded(child: value!),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}

/// A minimalist toggle for expanding/collapsing sections.
class YamlCollapseToggle extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const YamlCollapseToggle({
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
