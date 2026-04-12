import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';

/// A component that provides consistent indentation for nested message structures.
///
/// NOTE: This component is intended to provide a YAML-like visual layout with
/// vertical indentation guides, but it does not strictly follow YAML formatting
/// rules.
class ProtoMapIndent extends StatelessWidget {
  final int depth;
  final Widget child;
  final double? indentWidth;

  const ProtoMapIndent({
    super.key,
    required this.depth,
    required this.child,
    this.indentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);
    final width = indentWidth ?? theme.indentWidth;
    if (depth <= 0) return child;

    return Stack(
      children: [
        for (int i = 0; i < depth; i++)
          Positioned(
            left: i * width + width / 2,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: theme.getLabelColor(i).withValues(alpha: 0.3),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(left: depth * width),
          child: child,
        ),
      ],
    );
  }
}

@Deprecated('Use ProtoMapIndent instead')
typedef ProtobufJsonIndent = ProtoMapIndent;
