# Searchable List Selector

The `SearchableListSelector` is a generic, searchable overlay component designed for selection tasks within the Protobuf message editor.

## Design Philosophy

- **Generic & Reusable**: It takes a list of items of type `T` and handles filtering and selection logic generically.
- **Centralized Selection Lifecycle**: The component handles both keyboard navigation (Arrow keys + Enter) and touch/click selection (via an internal `InkWell` wrapper). Callers should only focus on building the item widget, not worrying about tap handlers.
- **Robust Positioning**: It includes a static `show` method that handles automatic positioning (above or below the target) based on available screen space and window constraints.

## Usage

```dart
SearchableListSelector.show<MyItem>(
  context: context,
  layerLink: layerLink,
  items: items,
  onSelected: (item) => print('Selected: $item'),
  onCancel: () => print('Cancelled'),
  searchText: (item) => item.name,
  itemBuilder: (context, item, isSelected) => Text(item.name),
);
```

## Implementation Details

- **Internal InkWell**: Each item built by the `itemBuilder` is automatically wrapped in an `InkWell` by `SearchableListSelector`. This ensures consistent selection behavior across different types of selectors.
- **Focus Management**: The internal search field automatically requests focus when the selector is shown, allowing immediate typing for filtering.
