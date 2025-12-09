import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/field_editors/proto_field_editor.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';
import 'package:protobuf_message_editor/src/utils/proto_message_extensions.dart';

class ProtoListFieldEditor extends StatefulWidget {
  static dynamic defaultRepeatedFieldAddBuilder({
    required FieldIdentifier identifier,
    required FieldInfo fieldInfo,
  }) {
    return fieldInfo.makeDefaultElement();
  }

  final GeneratedMessage message;
  final FieldInfo fieldInfo;
  final Widget Function(BuildContext context, dynamic item, int index)?
  itemBuilder;
  final dynamic Function({
    required FieldIdentifier identifier,
    required FieldInfo fieldInfo,
  })
  repeatedFieldAddBuilder;
  final Widget Function({
    required GeneratedMessage submessage,
    required FieldInfo fieldInfo,
  })
  submessageBuilder;

  const ProtoListFieldEditor({
    super.key,
    required this.message,
    required this.fieldInfo,
    this.itemBuilder,
    this.repeatedFieldAddBuilder = defaultRepeatedFieldAddBuilder,
    this.submessageBuilder = ProtoFieldEditor.defaultSubmessageBuilder,
  });

  @override
  State<ProtoListFieldEditor> createState() => _ProtoListFieldEditorState();
}

class _ProtoListFieldExpansionState {
  final Map<(int, int), bool> _expandedMap = {};

  void handleOnExpandedChanged({
    required GeneratedMessage message,
    required int fieldTag,
    required bool expanded,
  }) {
    _expandedMap[(identityHashCode(message), fieldTag)] = expanded;
  }

  bool shouldBeExpanded({
    required GeneratedMessage message,
    required int fieldTag,
  }) {
    return _expandedMap[(identityHashCode(message), fieldTag)] ?? false;
  }
}

final _expansionState = _ProtoListFieldExpansionState();

class _ProtoListFieldEditorState extends State<ProtoListFieldEditor> {
  @override
  Widget build(BuildContext context) {
    final submessage = widget.message.getField(widget.fieldInfo.tagNumber);

    if (submessage is! Iterable) {
      return Text(submessage.toString());
    }

    final itemBuilder = widget.itemBuilder;

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: ExpansionTile(
        onExpansionChanged: (expanded) {
          _expansionState.handleOnExpandedChanged(
            expanded: expanded,
            message: widget.message,
            fieldTag: widget.fieldInfo.tagNumber,
          );
        },
        initiallyExpanded: _expansionState.shouldBeExpanded(
          message: widget.message,
          fieldTag: widget.fieldInfo.tagNumber,
        ),
        title: const Text("List"),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...submessage.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            if (itemBuilder != null) {
              return itemBuilder(context, item, index);
            }

            if (item is! GeneratedMessage) {
              return ProtoFieldEditor(
                fieldInfo: widget.fieldInfo,
                message: widget.message,
                listIndex: index,
              );
            }

            return widget.submessageBuilder(
              fieldInfo: widget.fieldInfo,
              submessage: item,
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                final created = widget.repeatedFieldAddBuilder(
                  identifier: widget.message.getFieldIdentifierByTag(
                    widget.fieldInfo.tagNumber,
                  ),
                  fieldInfo: widget.fieldInfo,
                );

                if (submessage is ListBase) {
                  setState(() {
                    submessage.add(created);
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ),
        ],
      ),
    );
  }
}
