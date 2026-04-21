import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../proto_map_editor_theme.dart';

/// A generic searchable list selector for overlays.
class SearchableListSelector<T> extends StatefulWidget {
  final List<T> items;
  final ValueChanged<T> onSelected;
  final VoidCallback onCancel;

  /// Extracts searchable text from an item for filtering.
  final String Function(T item) searchText;

  /// Builds the item widget for the list.
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;

  /// Maximum width of the selector popup.
  final double maxWidth;

  /// Search hint text.
  final String searchHint;

  /// Optional override for search text style.
  final TextStyle? searchStyle;

  /// Optional override for search hint style.
  final TextStyle? hintStyle;

  /// Maximum height of the selector popup.
  final double maxHeight;

  const SearchableListSelector({
    super.key,
    required this.items,
    required this.onSelected,
    required this.onCancel,
    required this.searchText,
    required this.itemBuilder,
    this.maxWidth = 400,
    this.maxHeight = 400,
    this.searchHint = 'Search...',
    this.searchStyle,
    this.hintStyle,
  });

  /// Shows the selector in an overlay with robust positioning.
  static OverlayEntry show<T>({
    required BuildContext context,
    required LayerLink layerLink,
    required List<T> items,
    required ValueChanged<T> onSelected,
    required VoidCallback onCancel,
    required String Function(T item) searchText,
    required Widget Function(BuildContext context, T item, bool isSelected)
    itemBuilder,
    double maxWidth = 400,
    double maxHeight = 400,
    String searchHint = 'Search...',
  }) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final windowHeight = MediaQuery.of(context).size.height;

    // Determine if we should show above or below
    final spaceBelow = windowHeight - offset.dy - size.height;
    final spaceAbove = offset.dy;
    final showAbove = spaceBelow < maxHeight && spaceAbove > spaceBelow;

    // Calculate actual bounds to stay within window
    final effectiveMaxHeight = showAbove
        ? (spaceAbove - 16)
        : (spaceBelow - 16);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onCancel,
              child: Container(color: Colors.transparent),
            ),
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor: showAbove
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: showAbove
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: Offset(0, showAbove ? -4 : 4),
              child: Material(
                color: Colors.transparent,
                child: SearchableListSelector<T>(
                  items: items,
                  onSelected: onSelected,
                  onCancel: onCancel,
                  searchText: searchText,
                  itemBuilder: itemBuilder,
                  maxWidth: maxWidth,
                  maxHeight: effectiveMaxHeight < maxHeight
                      ? effectiveMaxHeight
                      : maxHeight,
                  searchHint: searchHint,
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  @override
  State<SearchableListSelector<T>> createState() =>
      _SearchableListSelectorState<T>();
}

class _SearchableListSelectorState<T> extends State<SearchableListSelector<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();

  List<T> _filteredItems = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
    _focusNode.requestFocus();
    _focusNode.onKey = (FocusNode node, RawKeyEvent event) {
      if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveSelection(1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveSelection(-1);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredItems.isNotEmpty) {
          widget.onSelected(_filteredItems[_selectedIndex]);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onCancel();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  void _moveSelection(int delta) {
    setState(() {
      if (_filteredItems.isNotEmpty) {
        _selectedIndex =
            (_selectedIndex + delta + _filteredItems.length) %
            _filteredItems.length;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items
          .where(
            (item) => widget.searchText(item).toLowerCase().contains(query),
          )
          .toList();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoMapEditorTheme.of(context);

    final windowSize = MediaQuery.of(context).size;
    final horizontalPadding = 32.0;
    final verticalPadding = 32.0;

    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth.clamp(
          0,
          windowSize.width - horizontalPadding,
        ),
        maxHeight: widget.maxHeight.clamp(
          0,
          windowSize.height - verticalPadding,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.collapseToggleColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchBar(theme),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              controller: _listScrollController,
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return InkWell(
                  onTap: () => widget.onSelected(item),
                  child: widget.itemBuilder(
                    context,
                    item,
                    index == _selectedIndex,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProtoMapEditorTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: widget.searchStyle ?? theme.fieldValueStyle,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: widget.hintStyle ?? theme.hintTextStyle,
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
