import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_editor_theme.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_message_editor.dart';

/// A new approach to editing protobuf messages.
///
/// This editor converts the passed in message internally to a JSON object
/// and uses a [ProtobufJsonEditingController] to manage state.
class ProtobufJsonEditor extends StatefulWidget {
  final GeneratedMessage message;
  final TypeRegistry? typeRegistry;
  final ProtobufJsonEditingController? controller;
  final void Function(GeneratedMessage message)? onSave;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonEditor({
    super.key,
    required this.message,
    this.typeRegistry,
    this.controller,
    this.onSave,
    this.provider,
  });

  @override
  State<ProtobufJsonEditor> createState() => _ProtobufJsonEditorState();
}

class _ProtobufJsonEditorState extends State<ProtobufJsonEditor> {
  ProtobufJsonEditingController? _internalController;

  ProtobufJsonEditingController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = ProtobufJsonEditingController(
        sourceMessage: widget.message,
        typeRegistry: widget.typeRegistry ?? const TypeRegistry.empty(),
      );
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtobufEditorTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(extensions: [theme]),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
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
                Padding(
                  padding: theme.contentPadding,
                  child: ProtobufJsonMessageEditor(
                    controller: _controller,
                    depth: 0,
                    provider: widget.provider,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
