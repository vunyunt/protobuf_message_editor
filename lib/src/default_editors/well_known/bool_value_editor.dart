import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

class BoolValueEditor extends CustomMessageEditorBuilder {
  @override
  Widget build(BuildContext context, {required GeneratedMessage data}) =>
      _BoolValueEditorWidget(data: data as BoolValue);

  @override
  String get qualifiedMessageName =>
      BoolValue.getDefault().info_.qualifiedMessageName;
}

class _BoolValueEditorWidget extends StatefulWidget {
  final BoolValue data;

  const _BoolValueEditorWidget({Key? key, required this.data})
    : super(key: key);

  @override
  State<_BoolValueEditorWidget> createState() => _BoolValueEditorWidgetState();
}

class _BoolValueEditorWidgetState extends State<_BoolValueEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.data.value,
      onChanged: (value) {
        if (value != null) {
          widget.data.value = value;
          setState(() {});
        }
      },
    );
  }
}
