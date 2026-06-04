import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/proto_map_navigation_scope.dart';

/// A field editor for message values (nested objects).
class ProtoMapMessageFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  @Deprecated('Use ProtoMapEditorProviderScope instead')
  final ProtoMapEditorProvider? provider;

  final bool enabled;

  const ProtoMapMessageFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    @Deprecated('Use ProtoMapEditorProviderScope instead')
    this.provider,
    this.enabled = true,
  });

  @override
  State<ProtoMapMessageFieldEditor> createState() =>
      _ProtoMapMessageFieldEditorState();
}

@Deprecated('Use ProtoMapMessageFieldEditor instead')
typedef ProtobufJsonMessageFieldEditor = ProtoMapMessageFieldEditor;

class _ProtoMapMessageFieldEditorState
    extends State<ProtoMapMessageFieldEditor> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.controller.isInitialLoad;
  }

  @override
  Widget build(BuildContext context) {
    final jsonKey = widget.fieldInfo.jsonKey!;
    final index = widget.fieldInfo.index;


    final theme = ProtoMapEditorTheme.of(context);

    final parentMessageName = widget
        .fieldInfo
        .parentBuilderInfo
        ?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (widget.fieldInfo.parentFieldName != null)
        'Field: ${widget.fieldInfo.parentFieldName}',
    ].join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProtoMapIndent(
          depth: widget.fieldInfo.depth,
          child: Builder(
            builder: (context) {
              final navigationScope = ProtoMapNavigationScope.of(context);
              return ProtoMapFieldRow(
                label: widget.fieldInfo.label ?? jsonKey,
                labelColor: theme.getLabelColor(widget.fieldInfo.depth),
                tooltip: parentContext.isEmpty ? null : parentContext,
                leading: ProtoMapCollapseToggle(
                  isCollapsed: _isCollapsed,
                  onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
                onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
                value: Text(
                  widget.fieldInfo.submessageBuilderInfo?.qualifiedMessageName
                          .split('.')
                          .last ??
                      '',
                  style: theme.fieldValueStyle.copyWith(
                    color: theme.getLabelColor(widget.fieldInfo.depth),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (navigationScope != null &&
                        widget.fieldInfo.submessageBuilderInfo != null) ...[
                      ProtoMapMaximizeButton(
                        onTap: () {
                          final subController = widget.controller.createSubmessageController(widget.fieldInfo);
                          navigationScope.onPush(
                            label: widget.fieldInfo.label ?? jsonKey,
                            controller: subController,
                            fieldInfo: widget.fieldInfo,
                          );
                        },
                        enabled: widget.enabled,
                      ),
                      const SizedBox(width: 8),
                    ],
                    ProtoMapRemoveButton(
                      controller: widget.controller,
                      jsonKey: jsonKey,
                      index: index,
                      enabled: widget.enabled,
                    ),
                  ],
                ),
              );
            }
          ),
        ),
        if (!_isCollapsed) ...[_buildSubmessageContent()],
      ],
    );
  }

  Widget _buildSubmessageContent() {
    if (widget.fieldInfo.submessageBuilderInfo == null) return const SizedBox.shrink();

    final subController = widget.controller.createSubmessageController(widget.fieldInfo);

    return ProtoMapMessageEditor(
      controller: subController,
      depth: widget.fieldInfo.depth + 1,
      parentFieldName: widget.fieldInfo.label ?? widget.fieldInfo.jsonKey,
      enabled: widget.enabled,
    );
  }
}
