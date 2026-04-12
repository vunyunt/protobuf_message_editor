import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';

/// A compact row representing a single field in the YAML-like layout.
///
/// NOTE: This component is intended to provide a YAML-like visual layout,
/// but it does not strictly follow YAML formatting rules.
class ProtoMapFieldRow extends StatelessWidget {
  final String label;
  final Widget? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTapLabel;
  final String? tooltip;
  final Color? labelColor;

  const ProtoMapFieldRow({
    super.key,
    required this.label,
    this.value,
    this.leading,
    this.trailing,
    this.onTapLabel,
    this.tooltip,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

    Widget labelWidget = Text(
      '$label:',
      style: theme.fieldLabelStyle.copyWith(color: labelColor),
    );

    if (tooltip != null) {
      labelWidget = Tooltip(message: tooltip!, child: labelWidget);
    }

    return Padding(
      padding: theme.fieldRowPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: theme.collapseIconSize, child: leading),
          const SizedBox(width: 4),
          GestureDetector(onTap: onTapLabel, child: labelWidget),
          const SizedBox(width: 8),
          if (value != null) Expanded(child: value!),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    );
  }
}

@Deprecated('Use ProtoMapFieldRow instead')
typedef ProtobufJsonFieldRow = ProtoMapFieldRow;
