import 'package:flutter/widgets.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';

/// A provider for custom editors in the [ProtoMapEditor].
abstract class ProtoMapEditorProvider {
  /// Provides a custom builder for a new submessage.
  ///
  /// [submessageBuilderInfo] is the [BuilderInfo] of the message being created.
  /// [fieldInfo] is the [FieldInfo] of the field being added (if available).
  ///
  /// Returns a [GeneratedMessage] if a custom builder is provided, otherwise `null`.
  GeneratedMessage? getSubmessageBuilder({
    required BuilderInfo submessageBuilderInfo,
    FieldInfo? fieldInfo,
  }) => null;

  /// Provides a custom editor for a submessage.
  ///
  /// [controller] is the [ProtoMapControllerBase] for the submessage.
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

  /// Provides a custom initial value for a field when it is added.
  ///
  /// [controller] is the [ProtoMapControllerBase] managing the field.
  /// [fieldInfo] is the [FieldInfo] of the field being added.
  ///
  /// Returns a value if a custom initial value is provided, otherwise `null`.
  dynamic getFieldInitialValue({
    required ProtoMapControllerBase controller,
    required FieldInfo fieldInfo,
  }) => null;

  /// Returns `true` if the field should be excluded from rendering.
  ///
  /// [controller] is the [ProtoMapControllerBase] managing the field.
  /// [fieldInfo] contains metadata about the field.
  bool shouldExcludeField({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) => false;

  /// Returns `true` if the field should be uneditable.
  ///
  /// [controller] is the [ProtoMapControllerBase] managing the field.
  /// [fieldInfo] contains metadata about the field.
  bool isFieldUneditable({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) => false;

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
  GeneratedMessage? getSubmessageBuilder({
    required BuilderInfo submessageBuilderInfo,
    FieldInfo? fieldInfo,
  }) {
    for (final provider in providers) {
      final builder = provider.getSubmessageBuilder(
        submessageBuilderInfo: submessageBuilderInfo,
        fieldInfo: fieldInfo,
      );
      if (builder != null) return builder;
    }
    return null;
  }

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

  @override
  dynamic getFieldInitialValue({
    required ProtoMapControllerBase controller,
    required FieldInfo fieldInfo,
  }) {
    for (final provider in providers) {
      final value = provider.getFieldInitialValue(
        controller: controller,
        fieldInfo: fieldInfo,
      );
      if (value != null) return value;
    }
    return null;
  }

  @override
  bool shouldExcludeField({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    for (final provider in providers) {
      if (provider.shouldExcludeField(
        controller: controller,
        fieldInfo: fieldInfo,
      )) {
        return true;
      }
    }
    return false;
  }

  @override
  bool isFieldUneditable({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    for (final provider in providers) {
      if (provider.isFieldUneditable(
        controller: controller,
        fieldInfo: fieldInfo,
      )) {
        return true;
      }
    }
    return false;
  }
}
