import 'package:flutter/widgets.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';

/// A provider for custom editors in the [ProtobufJsonEditor].
abstract class ProtobufJsonEditorProvider {
  /// Provides a custom editor for a submessage.
  ///
  /// [controller] is the [ProtobufJsonEditingController] for the submessage.
  /// [fieldInfo] contains metadata about the field.
  ///
  /// Returns a [Widget] if a custom editor is provided, otherwise `null`.
  Widget? getSubmessageEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) => null;
}
