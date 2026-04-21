import 'package:flutter/material.dart';
import '../proto_map_editor_theme.dart';
import 'searchable_list_selector.dart';

/// A searchable type selector for protobuf message types.
class ProtoMapTypeSelector extends StatelessWidget {
  final List<String> availableTypes;
  final ValueChanged<String> onSelected;
  final VoidCallback onCancel;

  const ProtoMapTypeSelector({
    super.key,
    required this.availableTypes,
    required this.onSelected,
    required this.onCancel,
  });

  /// Shows the type selector in an overlay with robust positioning.
  static OverlayEntry show({
    required BuildContext context,
    required LayerLink layerLink,
    required List<String> availableTypes,
    required ValueChanged<String> onSelected,
    required VoidCallback onCancel,
  }) {
    final theme = ProtoMapEditorTheme.of(context);
    return SearchableListSelector.show<String>(
      context: context,
      layerLink: layerLink,
      items: availableTypes,
      onSelected: onSelected,
      onCancel: onCancel,
      searchText: (type) => type,
      maxWidth: 400,
      searchHint: 'Search message type...',
      itemBuilder: (context, type, isSelected) {
        return _TypeItem(type: type, isSelected: isSelected, theme: theme);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

    return SearchableListSelector<String>(
      items: availableTypes,
      onSelected: onSelected,
      onCancel: onCancel,
      searchText: (type) => type,
      maxWidth: 400,
      searchHint: 'Search message type...',
      itemBuilder: (context, type, isSelected) {
        return _TypeItem(type: type, isSelected: isSelected, theme: theme);
      },
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String type;
  final bool isSelected;
  final ProtoMapEditorTheme theme;

  const _TypeItem({
    required this.type,
    required this.isSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final parts = type.split('.');
    final messageName = parts.last;
    final prefix = parts.take(parts.length - 1).join('.');

    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            messageName,
            style: theme.fieldValueStyle.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : null,
            ),
          ),
          if (prefix.isNotEmpty)
            _ScrollingPrefix(
              prefix: prefix,
              theme: theme,
              isSelected: isSelected,
            ),
        ],
      ),
    );
  }
}

class _ScrollingPrefix extends StatefulWidget {
  final String prefix;
  final ProtoMapEditorTheme theme;
  final bool isSelected;

  const _ScrollingPrefix({
    required this.prefix,
    required this.theme,
    required this.isSelected,
  });

  @override
  State<_ScrollingPrefix> createState() => _ScrollingPrefixState();
}

class _ScrollingPrefixState extends State<_ScrollingPrefix> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Text(
          widget.prefix,
          style: widget.theme.hintTextStyle.copyWith(
            fontSize: 10,
            fontFamily: 'monospace',
            color: widget.isSelected ? Colors.blue.withOpacity(0.7) : null,
          ),
        ),
      ),
    );
  }
}
