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

  /// Provides a custom editor for a specific field.
  ///
  /// [controller] is the [ProtobufJsonController] managing the field.
  /// [fieldInfo] contains metadata about the field.
  ///
  /// Returns a [Widget] if a custom editor is provided, otherwise `null`.
  Widget? getFieldEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) => null;

  /// Merges multiple providers into one.
  ///
  /// The resulting provider will check each provider in order and return
  /// the first non-null editor found.
  static ProtobufJsonEditorProvider merge(
    List<ProtobufJsonEditorProvider> providers,
  ) {
    return _MergedProtobufJsonEditorProvider(providers);
  }
}

class _MergedProtobufJsonEditorProvider extends ProtobufJsonEditorProvider {
  final List<ProtobufJsonEditorProvider> providers;

  _MergedProtobufJsonEditorProvider(this.providers);

  @override
  Widget? getSubmessageEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) {
    for (final provider in providers) {
      final editor = provider.getSubmessageEditor(
        controller: controller,
        fieldInfo: fieldInfo,
      );
      if (editor != null) return editor;
    }
    return null;
  }

  @override
  Widget? getFieldEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) {
    for (final provider in providers) {
      final editor = provider.getFieldEditor(
        controller: controller,
        fieldInfo: fieldInfo,
      );
      if (editor != null) return editor;
    }
    return null;
  }
}
