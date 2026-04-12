import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';

class ProtoMapRemoveButton extends StatelessWidget {
  final ProtoMapControllerBase controller;
  final String jsonKey;
  final int? index;

  const ProtoMapRemoveButton({
    super.key,
    required this.controller,
    required this.jsonKey,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (index != null) {
          final list = List.from(controller.jsonMap[jsonKey] as List);
          list.removeAt(index!);
          controller.updateField(jsonKey, list);
        } else {
          controller.removeField(jsonKey);
        }
      },
      child: Icon(
        Icons.close,
        size: ProtoMapEditorTheme.of(context).smallIconSize,
        color: ProtoMapEditorTheme.of(context).removeButtonColor,
      ),
    );
  }
}

@Deprecated('Use ProtoMapRemoveButton instead')
typedef ProtobufJsonRemoveButton = ProtoMapRemoveButton;
