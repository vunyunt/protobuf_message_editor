import 'package:flutter/widgets.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';

/// A provider for custom editors in the [ProtoMapEditor].
abstract class ProtoMapEditorProvider {
  /// Provides a custom editor for a submessage.
  ///
  /// [controller] is the [ProtoMapController] for the submessage.
  /// [fieldInfo] contains metadata about the field.
  ///
  /// Returns a [Widget] if a custom editor is provided, otherwise `null`.
  Widget? getSubmessageEditor({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) => null;

  /// Provides a custom editor for a specific field.
  ///
  /// [controller] is the [ProtoMapControllerBase] managing the field.
  /// [fieldInfo] contains metadata about the field.
  ///
  /// Returns a [Widget] if a custom editor is provided, otherwise `null`.
  Widget? getFieldEditor({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) => null;

  /// Merges multiple providers into one.
  ///
  /// The resulting provider will check each provider in order and return
  /// the first non-null editor found.
  static ProtoMapEditorProvider merge(List<ProtoMapEditorProvider> providers) {
    return _MergedProtoMapEditorProvider(providers);
  }
}

@Deprecated('Use ProtoMapEditorProvider instead')
typedef ProtobufJsonEditorProvider = ProtoMapEditorProvider;

class _MergedProtoMapEditorProvider extends ProtoMapEditorProvider {
  final List<ProtoMapEditorProvider> providers;

  _MergedProtoMapEditorProvider(this.providers);

  @override
  Widget? getSubmessageEditor({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
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
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
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
