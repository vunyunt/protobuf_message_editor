import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/proto_map_field_selector.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

class ProtoMapAddFieldButton extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final int depth;
  final String? parentFieldName;
  final ProtoMapEditorProvider? provider;

  const ProtoMapAddFieldButton({
    super.key,
    required this.controller,
    required this.depth,
    this.parentFieldName,
    this.provider,
  });

  @override
  State<ProtoMapAddFieldButton> createState() => _ProtoMapAddFieldButtonState();
}

class _ProtoMapAddFieldButtonState extends State<ProtoMapAddFieldButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _hideSelector();
    super.dispose();
  }

  void _hideSelector() {
    if (_overlayEntry != null) {
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    }
  }

  void _showSelector(BuildContext context) {
    _hideSelector();

    final unsetFields =
        widget.controller.builderInfo.fieldInfo.values
            .where((f) => !widget.controller.jsonMap.containsKey(f.name))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    if (unsetFields.isEmpty) return;

    _overlayEntry = ProtoMapFieldSelector.show(
      context: context,
      layerLink: _layerLink,
      availableFields: unsetFields,
      onSelected: (field) {
        _hideSelector();

        Map<String, dynamic>? initialValue;
        final protoFieldInfo = ProtoMapFieldInfo(
          fieldInfo: field,
          jsonKey: field.name,
          depth: widget.depth,
          parentFieldName: widget.parentFieldName,
          parentBuilderInfo: widget.controller.builderInfo,
          submessageBuilderInfo: field.isMessageField
              ? field.subBuilder?.call().info_
              : null,
          label: field.name,
        );

        if (field.isMessageField &&
            !field.isScalarMessage &&
            !field.isRepeated) {
          final subBuilderInfo = field.subBuilder?.call().info_;
          if (subBuilderInfo != null) {
            final customMessage = widget.provider?.getSubmessageBuilder(
              submessageBuilderInfo: subBuilderInfo,
              fieldInfo: protoFieldInfo,
            );
            if (customMessage != null) {
              initialValue =
                  ProtoMapControllerBase.normalizeValue(
                        customMessage,
                        widget.controller.typeRegistry,
                      )
                      as Map<String, dynamic>;
            }
          }
        }

        if (initialValue == null) {
          final customInitialValue = widget.provider?.getFieldInitialValue(
            controller: widget.controller,
            fieldInfo: protoFieldInfo,
          );
          if (customInitialValue != null) {
            widget.controller.addField(
              field.name,
              initialValue: customInitialValue,
            );
            return;
          }
        }

        widget.controller.addField(field.name, initialValue: initialValue);
      },
      onCancel: _hideSelector,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFieldsToAdd = widget.controller.builderInfo.fieldInfo.values.any(
      (f) => !widget.controller.jsonMap.containsKey(f.name),
    );

    if (!hasFieldsToAdd) return const SizedBox.shrink();

    final parentMessageName = widget.controller.builderInfo.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      'Message: $parentMessageName',
      if (widget.parentFieldName != null) 'Field: ${widget.parentFieldName}',
    ].join('\n');

    return CompositedTransformTarget(
      link: _layerLink,
      child: ProtoMapActionButton(
        label: 'Add field...',
        icon: Icons.add,
        depth: widget.depth,
        tooltip: 'Add field to $parentContext',
        onTap: () => _showSelector(context),
      ),
    );
  }
}

@Deprecated('Use ProtoMapAddFieldButton instead')
typedef ProtobufJsonAddFieldButton = ProtoMapAddFieldButton;
