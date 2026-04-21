import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import '../../utils/proto_field_type_extensions.dart';
import '../proto_map_editor_theme.dart';
import 'searchable_list_selector.dart';

/// A searchable field selector for protobuf message fields.
class ProtoMapFieldSelector extends StatelessWidget {
  final List<FieldInfo> availableFields;
  final ValueChanged<FieldInfo> onSelected;
  final VoidCallback onCancel;

  const ProtoMapFieldSelector({
    super.key,
    required this.availableFields,
    required this.onSelected,
    required this.onCancel,
  });

  /// Shows the field selector in an overlay with robust positioning.
  static OverlayEntry show({
    required BuildContext context,
    required LayerLink layerLink,
    required List<FieldInfo> availableFields,
    required ValueChanged<FieldInfo> onSelected,
    required VoidCallback onCancel,
  }) {
    final theme = ProtoMapEditorTheme.of(context);
    return SearchableListSelector.show<FieldInfo>(
      context: context,
      layerLink: layerLink,
      items: availableFields,
      onSelected: onSelected,
      onCancel: onCancel,
      searchText: (field) => field.name,
      maxWidth: 300,
      searchHint: 'Search field...',
      itemBuilder: (context, field, isSelected) {
        return _FieldItem(field: field, isSelected: isSelected, theme: theme);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

    return SearchableListSelector<FieldInfo>(
      items: availableFields,
      onSelected: onSelected,
      onCancel: onCancel,
      searchText: (field) => field.name,
      maxWidth: 300,
      searchHint: 'Search field...',
      itemBuilder: (context, field, isSelected) {
        return _FieldItem(field: field, isSelected: isSelected, theme: theme);
      },
    );
  }
}

class _FieldItem extends StatefulWidget {
  final FieldInfo field;
  final bool isSelected;
  final ProtoMapEditorTheme theme;

  const _FieldItem({
    required this.field,
    required this.isSelected,
    required this.theme,
  });

  @override
  State<_FieldItem> createState() => _FieldItemState();
}

class _FieldItemState extends State<_FieldItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final showExpanded = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        color: widget.isSelected ? Colors.blue.withOpacity(0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: showExpanded ? _buildExpandedView() : _buildCompactView(),
      ),
    );
  }

  Widget _buildCompactView() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.field.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: widget.theme.fieldValueStyle.copyWith(
              fontWeight: widget.isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: widget.isSelected ? Colors.blue : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: _TypeBadge(
            type: widget.field.typeNameBadge,
            theme: widget.theme,
            isSelected: widget.isSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.field.name,
          style: widget.theme.fieldValueStyle.copyWith(
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            color: widget.isSelected ? Colors.blue : null,
          ),
        ),
        const SizedBox(height: 4),
        _TypeBadge(
          type: widget.field.typeNameBadge,
          theme: widget.theme,
          isSelected: widget.isSelected,
          isFull: true,
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final ProtoMapEditorTheme theme;
  final bool isSelected;
  final bool isFull;

  const _TypeBadge({
    required this.type,
    required this.theme,
    required this.isSelected,
    this.isFull = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : theme.collapseToggleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        type,
        maxLines: isFull ? null : 1,
        overflow: isFull ? null : TextOverflow.ellipsis,
        style: theme.hintTextStyle.copyWith(
          fontSize: 10,
          fontFamily: 'monospace',
          color: isSelected ? Colors.blue : null,
        ),
      ),
    );
  }
}
