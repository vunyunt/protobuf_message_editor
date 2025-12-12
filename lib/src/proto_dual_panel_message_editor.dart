import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/custom_editor_registry.dart';
import 'package:protobuf_message_editor/src/proto_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_navigation_breadcrumb.dart';
import 'package:protobuf_message_editor/src/proto_navigation_state.dart';

/// A dual panel message editor that shows the parent message (if available)
/// on the left panel, the current message on the right panel, and a
/// breadcrumb on top for navigation.
///
/// If [rootMessage] is provided instead of [navigationState], an internal
/// [navigationState] will be created and managed
class ProtoDualPanelMessageEditor extends StatefulWidget {
  final ProtoNavigationState? navigationState;
  final GeneratedMessage? rootMessage;
  final CustomEditorRegistry? customEditorRegistry;

  const ProtoDualPanelMessageEditor({
    super.key,
    required this.navigationState,
    this.customEditorRegistry,
  }) : rootMessage = null;

  const ProtoDualPanelMessageEditor.withRootMessage({
    super.key,
    required this.rootMessage,
    this.customEditorRegistry,
  }) : navigationState = null;

  @override
  State<ProtoDualPanelMessageEditor> createState() =>
      _ProtoDualPanelMessageEditorState();
}

class _ProtoDualPanelMessageEditorState
    extends State<ProtoDualPanelMessageEditor> {
  late ProtoNavigationState _navigationState;

  @override
  void initState() {
    super.initState();

    assert(
      !(widget.navigationState == null && widget.rootMessage == null),
      'Either navigationState or rootMessage must be provided',
    );

    _navigationState =
        widget.navigationState ??
        ProtoNavigationState.fromRootMessage(widget.rootMessage!);
  }

  @override
  dispose() {
    if (_navigationState != widget.navigationState) {
      _navigationState.dispose();
    }

    super.dispose();
  }

  Widget _buildNavigableSubmessage(
    BuildContext context, {
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
    required bool useReplace,
    bool submessageSelected = false,
  }) {
    return GestureDetector(
      onTap: () => useReplace
          ? _navigationState.replace(submessage)
          : _navigationState.push(submessage),
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
      listenable: _navigationState,
      builder: (context, child) {
        final current = _navigationState.getCurrent();
        final parent = _navigationState.getParent();
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
            ProtoNavigationBreadcrumb(navigationState: _navigationState),
            Expanded(child: editor),
          ],
        );
      },
    );
  }
}
