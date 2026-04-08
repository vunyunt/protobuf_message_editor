import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/custom_editor_registry.dart';
import 'package:protobuf_message_editor/src/default_editors/default_editor_registry.dart';
import 'package:protobuf_message_editor/src/field_editors/proto_field_editor.dart';
import 'package:protobuf_message_editor/src/utils/proto_message_extensions.dart';
import 'package:provider/provider.dart';

typedef SubmessageBuilder =
    Widget Function({
      required GeneratedMessage submessage,
      required GeneratedMessage parentMessage,
      required FieldInfo fieldInfo,
      VoidCallback? onRebuildRequested,
    });

@Deprecated('Use ProtobufJsonEditor instead')
class ProtoMessageEditor extends StatefulWidget {
  final GeneratedMessage message;
  final GeneratedMessage? parentMessage;
  final FieldInfo? fieldInfo;

  @Deprecated(
    "Users should wrap the ProtoMessageEditor in an ExpansionTile instead",
  )
  final String? expansionsTileTitle;

  final CustomEditorProvider? customEditorProvider;
  final SubmessageBuilder? submessageBuilder;
  final VoidCallback? onRebuildRequested;

  const ProtoMessageEditor({
    super.key,
    required this.message,
    this.parentMessage,
    this.fieldInfo,
    this.expansionsTileTitle,
    this.customEditorProvider,
    this.submessageBuilder,
    this.onRebuildRequested,
  });

  factory ProtoMessageEditor.withCustomEditors({
    required GeneratedMessage message,
    GeneratedMessage? parentMessage,
    FieldInfo? fieldInfo,
    String? expansionsTileTitle,
    Iterable<CustomFieldEditorBuilder> customFieldBuilders = const [],
    Iterable<CustomMessageEditorBuilder> customMessageEditors = const [],
    dynamic Function({
      required FieldIdentifier identifier,
      required FieldInfo fieldInfo,
    })?
    repeatedFieldAddBuilder,
  }) {
    final customEditorProvider = CustomEditorRegistry.fromIterable(
      customFieldBuilders: customFieldBuilders,
      customMessageEditors: customMessageEditors,
      repeatedFieldAddBuilder: repeatedFieldAddBuilder,
    );

    return ProtoMessageEditor(
      message: message,
      parentMessage: parentMessage,
      fieldInfo: fieldInfo,
      expansionsTileTitle: expansionsTileTitle,
      customEditorProvider: customEditorProvider,
    );
  }

  @override
  State<StatefulWidget> createState() => _ProtoMessageEditorState();
}

class _ProtoMessageEditorState extends State<ProtoMessageEditor> {
  Widget _buildField(
    BuildContext context,
    FieldInfo fieldInfo,
    CustomEditorProvider customEditorProvider,
    SubmessageBuilder submessageBuilder,
  ) {
    return ProtoFieldEditor(
      key: ValueKey((widget.message, fieldInfo.tagNumber)),
      message: widget.message,
      fieldInfo: fieldInfo,
      repeatedFieldAddBuilder: customEditorProvider
          .getRepeatedFieldAddBuilder(),
      submessageBuilder: submessageBuilder,
      onRebuildRequested: widget.onRebuildRequested,
    );
  }

  Widget _buildContent(
    BuildContext context,
    CustomEditorProvider customEditorProvider,
    SubmessageBuilder submessageBuilder,
  ) {
    final customEditorBuilder =
        customEditorProvider.getSubmessageEditorBuilder(
          widget.message,
          widget.parentMessage,
          widget.fieldInfo,
        ) ??
        defaultEditorRegistry.getSubmessageEditorBuilder(
          widget.message,
          widget.parentMessage,
          widget.fieldInfo,
        );

    if (customEditorBuilder != null) {
      return customEditorBuilder(context);
    }

    final fields = widget.message.info_.fieldInfo;
    final fieldWidgets = fields.values.map((fieldInfo) {
      final fieldIdentifier = widget.message.getFieldIdentifierByTag(
        fieldInfo.tagNumber,
      );

      final customFieldBuilder =
          customEditorProvider.getCustomFieldBuilder(fieldIdentifier) ??
          defaultEditorRegistry.getCustomFieldBuilder(fieldIdentifier);
      if (customFieldBuilder != null) {
        return customFieldBuilder.build(context, parentMessage: widget.message);
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: _buildField(
          context,
          fieldInfo,
          customEditorProvider,
          submessageBuilder,
        ),
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
    final effectiveCustomEditorProvider =
        widget.customEditorProvider ??
        Provider.of<CustomEditorProvider?>(context, listen: false) ??
        const CustomEditorRegistry();

    final effectiveSubmessageBuilder =
        widget.submessageBuilder ??
        Provider.of<SubmessageBuilder?>(context, listen: false) ??
        ProtoFieldEditor.defaultSubmessageBuilder;

    final content = _buildContent(
      context,
      effectiveCustomEditorProvider,
      effectiveSubmessageBuilder,
    );

    return MultiProvider(
      providers: [
        Provider<CustomEditorProvider>.value(
          value: effectiveCustomEditorProvider,
        ),
        Provider<SubmessageBuilder>.value(value: effectiveSubmessageBuilder),
      ],
      child: content,
    );
  }
}
