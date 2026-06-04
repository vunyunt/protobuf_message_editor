import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor_theme.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';

/// A field editor for map fields.
class ProtoMapMapFieldEditor extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final ProtoMapFieldInfo fieldInfo;

  @Deprecated('Use ProtoMapEditorProviderScope instead')
  final ProtoMapEditorProvider? provider;

  final bool enabled;

  const ProtoMapMapFieldEditor({
    super.key,
    required this.controller,
    required this.fieldInfo,
    @Deprecated('Use ProtoMapEditorProviderScope instead')
    this.provider,
    this.enabled = true,
  });

  @override
  State<ProtoMapMapFieldEditor> createState() => _ProtoMapMapFieldEditorState();
}

class _ProtoMapMapFieldEditorState extends State<ProtoMapMapFieldEditor> {
  late bool _isCollapsed;
  bool _isAdding = false;
  final TextEditingController _newKeyController = TextEditingController();
  String? _newKeyError;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.controller.isInitialLoad;
  }

  @override
  void dispose() {
    _newKeyController.dispose();
    super.dispose();
  }

  void _commitNewEntry() {
    final key = _newKeyController.text.trim();
    if (key.isEmpty) {
      setState(() => _newKeyError = 'Key cannot be empty');
      return;
    }

    final controller = widget.controller;
    final jsonKey = widget.fieldInfo.jsonKey!;
    final rawMap = controller.jsonMap[jsonKey];
    final map = rawMap is Map ? Map<String, dynamic>.from(rawMap) : <String, dynamic>{};

    if (map.containsKey(key)) {
      setState(() => _newKeyError = 'Key already exists');
      return;
    }

    // Validate key type if necessary (e.g. integral)
    final keyType = widget.fieldInfo.mapKeyFieldType;
    if (keyType != null && (keyType & PbFieldType.INT32_BIT) != 0) {
       if (int.tryParse(key) == null) {
         setState(() => _newKeyError = 'Key must be an integer');
         return;
       }
    }

    // If we get here, the key is valid.
    final protoFieldInfo = widget.fieldInfo.fieldInfo!;
    dynamic defaultValue = protoFieldInfo.getDefaultValue(forElement: true);

    controller.updateMapValue(jsonKey, key, defaultValue);

    setState(() {
      _isAdding = false;
      _newKeyController.clear();
      _newKeyError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final fieldInfo = widget.fieldInfo;
    final jsonKey = fieldInfo.jsonKey!;
    final depth = fieldInfo.depth;

    final rawValue = controller.jsonMap[jsonKey];
    final value = rawValue is Map ? Map<String, dynamic>.from(rawValue) : <String, dynamic>{};

    final theme = ProtoMapEditorTheme.of(context);
    final parentMessageName = fieldInfo.parentBuilderInfo?.qualifiedMessageName
        .split('.')
        .last;
    final parentContext = [
      if (parentMessageName != null) 'Message: $parentMessageName',
      if (fieldInfo.parentFieldName != null)
        'Field: ${fieldInfo.parentFieldName}',
    ].join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProtoMapIndent(
          depth: depth,
          child: ProtoMapFieldRow(
            label: fieldInfo.label!,
            labelColor: theme.getLabelColor(depth),
            tooltip: parentContext.isEmpty ? null : parentContext,
            leading: ProtoMapCollapseToggle(
              isCollapsed: _isCollapsed,
              onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
            ),
            onTapLabel: () => setState(() => _isCollapsed = !_isCollapsed),
            trailing: ProtoMapRemoveButton(
              controller: controller,
              jsonKey: jsonKey,
              enabled: widget.enabled,
            ),
          ),
        ),
        if (!_isCollapsed)
          ...value.keys.map((key) {
            return _MapEntryRow(
              key: ValueKey(key),
              controller: controller,
              fieldKey: jsonKey,
              mapKey: key,
              depth: depth + 1,
              fieldInfo: fieldInfo,
              enabled: widget.enabled,
            );
          }),
        if (!_isCollapsed && _isAdding && widget.enabled)
          ProtoMapIndent(
            depth: depth + 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newKeyController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter new key...',
                        errorText: _newKeyError,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (_) => _commitNewEntry(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, size: 20),
                    onPressed: _commitNewEntry,
                    tooltip: 'Add entry',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() {
                      _isAdding = false;
                      _newKeyError = null;
                      _newKeyController.clear();
                    }),
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ),
          ),
        if (!_isCollapsed && !_isAdding && widget.enabled)
          ProtoMapActionButton(
            label: 'Add entry',
            icon: Icons.add,
            depth: depth + 1,
            tooltip: 'Add entry to ${fieldInfo.label}',
            onTap: () => setState(() => _isAdding = true),
          ),
      ],
    );
  }
}

class _MapEntryRow extends StatefulWidget {
  final ProtoMapControllerBase controller;
  final String fieldKey;
  final String mapKey;
  final int depth;
  final ProtoMapFieldInfo fieldInfo;

  final bool enabled;

  const _MapEntryRow({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.mapKey,
    required this.depth,
    required this.fieldInfo,
    required this.enabled,
  });

  @override
  State<_MapEntryRow> createState() => _MapEntryRowState();
}

class _MapEntryRowState extends State<_MapEntryRow> {
  bool _isRenaming = false;
  late TextEditingController _renameController;
  String? _renameError;

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.mapKey);
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MapEntryRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapKey != widget.mapKey) {
      _renameController.text = widget.mapKey;
    }
  }

  void _commitRename() {
    final newKey = _renameController.text.trim();
    if (newKey == widget.mapKey) {
      setState(() => _isRenaming = false);
      return;
    }

    if (newKey.isEmpty) {
      setState(() => _renameError = 'Key cannot be empty');
      return;
    }

    final map = widget.controller.jsonMap[widget.fieldKey] as Map<String, dynamic>;
    if (map.containsKey(newKey)) {
      setState(() => _renameError = 'Key already exists');
      return;
    }

    // Validate key type
    final keyType = widget.fieldInfo.mapKeyFieldType;
    if (keyType != null && (keyType & PbFieldType.INT32_BIT) != 0) {
       if (int.tryParse(newKey) == null) {
         setState(() => _renameError = 'Key must be an integer');
         return;
       }
    }

    widget.controller.renameMapKey(widget.fieldKey, widget.mapKey, newKey);
    setState(() {
      _isRenaming = false;
      _renameError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRenaming) {
      return ProtoMapIndent(
        depth: widget.depth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _renameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    errorText: _renameError,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (_) => _commitRename(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, size: 20),
                onPressed: _commitRename,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() {
                  _isRenaming = false;
                  _renameError = null;
                  _renameController.text = widget.mapKey;
                }),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ProtoMapFieldEditor(
          controller: widget.controller,
          jsonKey: widget.fieldKey,
          mapKey: widget.mapKey,
          depth: widget.depth,
          parentFieldName: widget.fieldKey,
          enabled: widget.enabled,
        ),
        Positioned(
          right: 36, // Adjust based on theme and other buttons
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.edit, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: widget.enabled ? () => setState(() => _isRenaming = true) : null,
            tooltip: 'Rename key',
          ),
        ),
        Positioned(
          right: 8,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: widget.enabled ? () {
              final map = Map<String, dynamic>.from(
                widget.controller.jsonMap[widget.fieldKey] as Map,
              );
              map.remove(widget.mapKey);
              widget.controller.updateField(widget.fieldKey, map);
            } : null,
            tooltip: 'Remove entry',
          ),
        ),
      ],
    );
  }
}
