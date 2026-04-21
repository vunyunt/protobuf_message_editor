import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';

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

  const ProtoMapEditor({
    super.key,
    required this.message,
    this.typeRegistry,
    this.controller,
    this.onSave,
    this.provider,
  });

  @override
  State<ProtoMapEditor> createState() => _ProtoMapEditorState();
}

@Deprecated('Use ProtoMapEditor instead')
typedef ProtobufJsonEditor = ProtoMapEditor;

class _ProtoMapEditorState extends State<ProtoMapEditor> {
  ProtoMapController? _internalController;

  ProtoMapController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _initController();
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

  @override
  void didUpdateWidget(ProtoMapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller ||
        widget.message != oldWidget.message ||
        widget.typeRegistry != oldWidget.typeRegistry) {
      _internalController?.dispose();
      _initController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(extensions: [theme]),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: theme.contentPadding,
                    child: ProtoMapMessageEditor(
                      controller: _controller,
                      depth: 0,
                      provider: widget.provider,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
