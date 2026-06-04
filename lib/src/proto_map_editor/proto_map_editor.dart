import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider_scope.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/proto_map_navigation_scope.dart';

/// A new approach to editing protobuf messages.
///
/// This editor converts the passed in message internally to a JSON object
/// and uses a [ProtoMapController] to manage state.
class ProtoMapEditor extends StatefulWidget {
  final GeneratedMessage message;
  final TypeRegistry? typeRegistry;
  final ProtoMapController? controller;
  final void Function(GeneratedMessage message)? onSave;
  final ProtoMapEditorProvider? provider;
  final List<Widget>? actions;

  const ProtoMapEditor({
    super.key,
    required this.message,
    this.typeRegistry,
    this.controller,
    this.onSave,
    this.provider,
    this.actions,
  });

  @override
  State<ProtoMapEditor> createState() => _ProtoMapEditorState();
}

@Deprecated('Use ProtoMapEditor instead')
typedef ProtobufJsonEditor = ProtoMapEditor;

class _ProtoMapEditorState extends State<ProtoMapEditor> {
  ProtoMapController? _internalController;
  final List<ProtoMapNavigationNode> _navigationStack = [];

  ProtoMapController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _initController();
    _initNavigationStack();
    _controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.markInitialLoadComplete();
    });
  }

  void _initController() {
    if (widget.controller == null) {
      _internalController = ProtoMapController(
        sourceMessage: widget.message,
        typeRegistry: widget.typeRegistry ?? const TypeRegistry.empty(),
      );
    } else {
      _internalController = null;
    }
  }

  void _initNavigationStack() {
    _navigationStack.clear();
    _navigationStack.add(
      ProtoMapNavigationNode(
        label: widget.message.info_.qualifiedMessageName.split('.').last,
        controller: _controller,
      ),
    );
  }

  void _onControllerChanged() {
    if (_controller.isInitialLoad && _navigationStack.length > 1) {
      setState(() {
        _initNavigationStack();
      });
    } else {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ProtoMapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _internalController;
    if (widget.controller != oldWidget.controller ||
        widget.message != oldWidget.message ||
        widget.typeRegistry != oldWidget.typeRegistry) {
      oldController?.removeListener(_onControllerChanged);
      _internalController?.dispose();
      _initController();
      _initNavigationStack();
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _push({
    required String label,
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    setState(() {
      _navigationStack.add(
        ProtoMapNavigationNode(
          label: label,
          controller: controller,
          fieldInfo: fieldInfo,
        ),
      );
    });
  }

  void _popUntilDepth(int depth) {
    if (depth < 0 || depth >= _navigationStack.length) return;
    setState(() {
      _navigationStack.removeRange(depth + 1, _navigationStack.length);
    });
  }

  Widget _buildNavigationBar(BuildContext context, ProtoMapEditorTheme theme) {
    if (_navigationStack.length <= 1) {
      return const SizedBox.shrink();
    }

    final breadcrumbs = <Widget>[];
    for (int i = 0; i < _navigationStack.length; i++) {
      final node = _navigationStack[i];
      final isLast = i == _navigationStack.length - 1;

      breadcrumbs.add(
        InkWell(
          onTap: isLast ? null : () => _popUntilDepth(i),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              node.label,
              style: theme.fieldLabelStyle.copyWith(
                color: isLast
                    ? theme.getLabelColor(i)
                    : theme.getLabelColor(i).withValues(alpha: 0.7),
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                decoration: isLast ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      );

      if (!isLast) {
        breadcrumbs.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right,
              size: 14,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    }

    return Container(
      color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: breadcrumbs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);
    final currentController = _navigationStack.last.controller;

    return Theme(
      data: Theme.of(context).copyWith(extensions: [theme]),
      child: ProtoMapEditorProviderScope(
        provider: widget.provider,
        child: ProtoMapNavigationScope(
          stack: _navigationStack,
          onPush: _push,
          onPopUntilDepth: _popUntilDepth,
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: theme.contentPadding,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Editing: ${widget.message.info_.qualifiedMessageName}',
                            style: theme.fieldLabelStyle,
                          ),
                        ),
                        if (_controller.isDirty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Unsaved Changes',
                              style: theme.unsavedChangesStyle,
                            ),
                          ),
                        if (widget.actions != null) ...[
                          ...widget.actions!,
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: _controller.isDirty
                              ? () {
                                  final savedMessage = _controller.save();
                                  widget.onSave?.call(savedMessage);
                                }
                              : null,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildNavigationBar(context, theme),
                  if (_navigationStack.length > 1) const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: theme.contentPadding,
                        child: ProtoMapMessageEditor(
                          key: ValueKey(_navigationStack.length),
                          controller: currentController,
                          depth: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

