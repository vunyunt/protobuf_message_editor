import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/custom_editor_registry.dart';
import 'package:protobuf_message_editor/src/field_editors/proto_field_editor.dart';
import 'package:protobuf_message_editor/src/utils/proto_message_extensions.dart';
import 'package:provider/provider.dart';

class ProtoMessageEditor extends StatefulWidget {
  final GeneratedMessage message;
  final String? expansionsTileTitle;
  final CustomEditorRegistry? customEditorRegistry;
  final Widget Function({
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
  })
  submessageBuilder;

  const ProtoMessageEditor({
    super.key,
    required this.message,
    this.expansionsTileTitle,
    this.customEditorRegistry,
    this.submessageBuilder = ProtoFieldEditor.defaultSubmessageBuilder,
  });

  factory ProtoMessageEditor.withCustomEditors({
    required GeneratedMessage message,
    String? expansionsTileTitle,
    Iterable<CustomFieldEditorBuilder> customFieldBuilders = const [],
    Iterable<CustomMessageEditorBuilder> customMessageEditors = const [],
    dynamic Function({
      required FieldIdentifier identifier,
      required FieldInfo fieldInfo,
    })?
    repeatedFieldAddBuilder,
  }) {
    final customEditorRegistry = CustomEditorRegistry.fromIterable(
      customFieldBuilders: customFieldBuilders,
      customMessageEditors: customMessageEditors,
      repeatedFieldAddBuilder: repeatedFieldAddBuilder,
    );

    return ProtoMessageEditor(
      message: message,
      expansionsTileTitle: expansionsTileTitle,
      customEditorRegistry: customEditorRegistry,
    );
  }

  @override
  State<StatefulWidget> createState() => _ProtoMessageEditorState();
}

class _ProtoMessageEditorState extends State<ProtoMessageEditor> {
  late final CustomEditorRegistry customEditorRegistry;

  @override
  void initState() {
    super.initState();
    customEditorRegistry =
        widget.customEditorRegistry ??
        Provider.of<CustomEditorRegistry?>(context, listen: false) ??
        const CustomEditorRegistry();
  }

  Widget _buildField(BuildContext context, FieldInfo fieldInfo) {
    return ProtoFieldEditor(
      key: ValueKey((widget.message, fieldInfo.tagNumber)),
      message: widget.message,
      fieldInfo: fieldInfo,
      repeatedFieldAddBuilder: customEditorRegistry.repeatedFieldAddBuilder,
      submessageBuilder: widget.submessageBuilder,
    );
  }

  Widget _buildContent(BuildContext context) {
    final customMessageEditor = customEditorRegistry.getCustomMessageEditor(
      widget.message.info_.qualifiedMessageName,
    );
    if (customMessageEditor != null) {
      return customMessageEditor.build(context, data: widget.message);
    }

    final fields = widget.message.info_.fieldInfo;
    final fieldWidgets = fields.values.map((fieldInfo) {
      final fieldIdentifier = widget.message.getFieldIdentifierByTag(
        fieldInfo.tagNumber,
      );

      final customFieldBuilder = customEditorRegistry.getCustomFieldBuilder(
        fieldIdentifier,
      );
      if (customFieldBuilder != null) {
        return customFieldBuilder.build(context);
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: _buildField(context, fieldInfo),
      );
    }).toList();

    final expansionsTileTitle = widget.expansionsTileTitle;

    if (expansionsTileTitle != null) {
      return ExpansionTile(
        dense: true,
        title: Text(widget.message.info_.qualifiedMessageName),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: fieldWidgets,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fieldWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgetCustom = widget.customEditorRegistry;
    if (widgetCustom != null) {
      return Provider.value(value: widgetCustom, child: _buildContent(context));
    }

    return _buildContent(context);
  }
}
