import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';

/// A fallback editor for fields without [FieldInfo].
class ProtoMapFallbackFieldEditor extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  const ProtoMapFallbackFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
  });

  @override
  Widget build(BuildContext context) {
    final jsonKey = fieldInfo.jsonKey!;
    final value = controller.jsonMap[jsonKey];

    return ProtoMapIndent(
      depth: fieldInfo.depth,
      child: ProtoMapFieldRow(
        label: jsonKey,
        value: Text(
          value.toString(),
          style: ProtoMapEditorTheme.of(context).hintTextStyle,
        ),
        trailing: ProtoMapRemoveButton(
          controller: controller,
          jsonKey: jsonKey,
        ),
      ),
    );
  }
}

@Deprecated('Use ProtoMapFallbackFieldEditor instead')
typedef ProtobufJsonFallbackFieldEditor = ProtoMapFallbackFieldEditor;
