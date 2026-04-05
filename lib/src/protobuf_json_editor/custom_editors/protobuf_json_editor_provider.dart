import 'package:flutter/widgets.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';

/// A provider for custom editors in the [ProtobufJsonEditor].
abstract class ProtobufJsonEditorProvider {
  /// Provides a custom editor for a submessage.
  ///
  /// [messageType] is the qualified name of the submessage being edited.
  /// [parentMessageType] is the qualified name of the parent message.
  /// [fieldInfo] is the [FieldInfo] of the field containing the submessage.
  /// [controller] is the [ProtobufJsonEditingController] for the submessage.
  ///
  /// Returns a [Widget] if a custom editor is provided, otherwise `null`.
  Widget? getSubmessageEditor({
    required String messageType,
    required String? parentMessageType,
    required FieldInfo? fieldInfo,
    required ProtobufJsonEditingController controller,
  }) => null;
}
