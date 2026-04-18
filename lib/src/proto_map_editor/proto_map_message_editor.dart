import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_add_field_button.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_editor.dart';

/// A widget that renders the fields of a protobuf message.
///
/// This widget iterates over the keys in the [controller]'s JSON map and
/// renders a [ProtoMapFieldEditor] for each key. It also appends a
/// [ProtoMapAddFieldButton] at the end.
class ProtoMapMessageEditor extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final int depth;
  final String? parentFieldName;
  final ProtoMapEditorProvider? provider;

  final bool enabled;

  const ProtoMapMessageEditor({
    super.key,
    required this.controller,
    this.depth = 0,
    this.parentFieldName,
    this.provider,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final jsonMap = controller.jsonMap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...jsonMap.keys.map(
          (key) => ProtoMapFieldEditor(
            controller: controller,
            jsonKey: key,
            depth: depth,
            parentFieldName: parentFieldName,
            provider: provider,
          ),
        ),
        if (enabled)
          ProtoMapAddFieldButton(
            controller: controller,
            depth: depth,
            parentFieldName: parentFieldName,
          ),
      ],
    );
  }
}

@Deprecated('Use ProtoMapMessageEditor instead')
typedef ProtobufJsonMessageEditor = ProtoMapMessageEditor;
