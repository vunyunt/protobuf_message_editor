import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/custom_editor_registry.dart';
import 'package:protobuf_message_editor/src/proto_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_navigation_breadcrumb.dart';
import 'package:protobuf_message_editor/src/proto_navigation_state.dart';

class ProtoDualPanelMessageEditor extends StatefulWidget {
  final ProtoNavigationState navigationState;
  final CustomEditorRegistry? customEditorRegistry;

  const ProtoDualPanelMessageEditor({
    super.key,
    required this.navigationState,
    this.customEditorRegistry,
  });

  @override
  State<ProtoDualPanelMessageEditor> createState() =>
      _ProtoDualPanelMessageEditorState();
}

class _ProtoDualPanelMessageEditorState
    extends State<ProtoDualPanelMessageEditor> {
  Widget _buildNavigableSubmessage(
    BuildContext context, {
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
    required bool useReplace,
    bool submessageSelected = false,
  }) {
    return GestureDetector(
      onTap: () => useReplace
          ? widget.navigationState.replace(submessage)
          : widget.navigationState.push(submessage),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: submessageSelected ? Theme.of(context).highlightColor : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${fieldInfo.name}: ${submessage.info_.qualifiedMessageName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentEditor(
    BuildContext context, {
    required ProtoNavigationNode node,
  }) {
    return SingleChildScrollView(
      child: ProtoMessageEditor(
        key: ValueKey(identityHashCode(node.message)),
        customEditorRegistry: widget.customEditorRegistry,
        message: node.message,
        submessageBuilder:
            ({
              required GeneratedMessage submessage,
              required FieldInfo fieldInfo,
            }) {
              return _buildNavigableSubmessage(
                context,
                submessage: submessage,
                fieldInfo: fieldInfo,
                useReplace: false,
              );
            },
      ),
    );
  }

  Widget _buildParentEditor(
    BuildContext context, {
    required ProtoNavigationNode node,
    required GeneratedMessage currentSubmessage,
  }) {
    return SingleChildScrollView(
      child: ProtoMessageEditor(
        key: ValueKey(identityHashCode(node.message)),
        customEditorRegistry: widget.customEditorRegistry,
        message: node.message,
        submessageBuilder:
            ({
              required GeneratedMessage submessage,
              required FieldInfo fieldInfo,
            }) {
              final isSelected = identical(submessage, currentSubmessage);

              return _buildNavigableSubmessage(
                context,
                submessage: submessage,
                fieldInfo: fieldInfo,
                useReplace: true,
                submessageSelected: isSelected,
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.navigationState,
      builder: (context, child) {
        final current = widget.navigationState.getCurrent();
        final parent = widget.navigationState.getParent();
        final editor = Row(
          spacing: 6,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: parent == null
                  ? const Center(child: Text("No Parent"))
                  : _buildParentEditor(
                      context,
                      node: parent,
                      currentSubmessage: current.message,
                    ),
            ),
            const VerticalDivider(),
            Expanded(child: _buildCurrentEditor(context, node: current)),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProtoNavigationBreadcrumb(navigationState: widget.navigationState),
            Expanded(child: editor),
          ],
        );
      },
    );
  }
}
