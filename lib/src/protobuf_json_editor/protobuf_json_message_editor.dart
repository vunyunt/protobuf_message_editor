import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_add_field_button.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_editor.dart';

/// A widget that renders the fields of a protobuf message.
///
/// This widget iterates over the keys in the [controller]'s JSON map and
/// renders a [ProtobufJsonFieldEditor] for each key. It also appends a
/// [ProtobufJsonAddFieldButton] at the end.
class ProtobufJsonMessageEditor extends StatelessWidget {
  final ProtobufJsonEditingController controller;
  final int depth;
  final ProtobufJsonEditorProvider? provider;

  const ProtobufJsonMessageEditor({
    super.key,
    required this.controller,
    this.depth = 0,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final jsonMap = controller.jsonMap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...jsonMap.keys.map(
          (key) => ProtobufJsonFieldEditor(
            controller: controller,
            jsonKey: key,
            depth: depth,
            provider: provider,
          ),
        ),
        ProtobufJsonAddFieldButton(controller: controller, depth: depth),
      ],
    );
  }
}
