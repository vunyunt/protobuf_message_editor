import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:protobuf_message_editor/src/proto_navigation_state.dart';

class ProtoNavigationBreadcrumb extends StatelessWidget {
  final ProtoNavigationState navigationState;

  const ProtoNavigationBreadcrumb({required this.navigationState, super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: navigationState,
      builder: (context, child) {
        final Iterable<Widget> crumbs = navigationState.getStack().map(
          (e) => _buildCrumb(context, node: e),
        );
        final elements = crumbs.intersperse(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('>', style: TextStyle(fontFamily: 'monospace')),
          ),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: elements.toList(),
          ),
        );
      },
    );
  }

  Widget _buildCrumb(
    BuildContext context, {
    required ProtoNavigationNode node,
  }) {
    return TextButton(
      onPressed: () {
        navigationState.popUntilDepth(node.depth);
      },
      child: Text(node.message.runtimeType.toString()),
    );
  }
}
