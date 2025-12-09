import 'package:flutter/widgets.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/utils/proto_message_extensions.dart';

abstract class CustomFieldEditorBuilder {
  FieldIdentifier get identifier;

  Widget build(BuildContext context);
}

abstract class CustomMessageEditorBuilder<T extends GeneratedMessage> {
  String get qualifiedMessageName;

  Widget build(BuildContext context, {required T data});
}

class CustomEditorRegistry {
  final Map<FieldIdentifier, CustomFieldEditorBuilder> customFieldBuilders;
  final Map<String, CustomMessageEditorBuilder> customMessageEditors;
  final dynamic Function({
    required FieldIdentifier identifier,
    required FieldInfo fieldInfo,
  })?
  repeatedFieldAddBuilder;

  const CustomEditorRegistry({
    this.customFieldBuilders = const {},
    this.customMessageEditors = const {},
    this.repeatedFieldAddBuilder,
  });

  factory CustomEditorRegistry.fromIterable({
    Iterable<CustomFieldEditorBuilder> customFieldBuilders = const [],
    Iterable<CustomMessageEditorBuilder> customMessageEditors = const [],
    dynamic Function({
      required FieldIdentifier identifier,
      required FieldInfo fieldInfo,
    })?
    repeatedFieldAddBuilder,
  }) {
    return CustomEditorRegistry(
      customFieldBuilders: Map.fromEntries(
        customFieldBuilders.map(
          (editor) => MapEntry(editor.identifier, editor),
        ),
      ),
      customMessageEditors: Map.fromEntries(
        customMessageEditors.map(
          (editor) => MapEntry(editor.qualifiedMessageName, editor),
        ),
      ),
      repeatedFieldAddBuilder: repeatedFieldAddBuilder,
    );
  }

  CustomEditorRegistry shallowCopyWith({
    Map<FieldIdentifier, CustomFieldEditorBuilder>? customFieldBuilders,
    Map<String, CustomMessageEditorBuilder>? customMessageEditors,
    dynamic Function({
      required FieldIdentifier identifier,
      required FieldInfo fieldInfo,
    })?
    repeatedFieldAddBuilder,
  }) {
    return CustomEditorRegistry(
      customFieldBuilders: customFieldBuilders ?? this.customFieldBuilders,
      customMessageEditors: customMessageEditors ?? this.customMessageEditors,
      repeatedFieldAddBuilder:
          repeatedFieldAddBuilder ?? this.repeatedFieldAddBuilder,
    );
  }

  CustomFieldEditorBuilder? getCustomFieldBuilder(FieldIdentifier identifier) {
    return customFieldBuilders[identifier];
  }

  CustomMessageEditorBuilder? getCustomMessageEditor(
    String qualifiedMessageName,
  ) {
    return customMessageEditors[qualifiedMessageName];
  }
}
