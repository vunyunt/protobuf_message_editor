import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/searchable_list_selector.dart';

void main() {
  testWidgets('SearchableListSelector selects item on click', (tester) async {
    String? selected;
    final items = ['item1', 'item2', 'item3'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableListSelector<String>(
            items: items,
            onSelected: (val) => selected = val,
            onCancel: () {},
            searchText: (item) => item,
            itemBuilder: (context, item, isHighlighted, isSelected) {
              return Text(item);
            },
          ),
        ),
      ),
    );

    // Click on item2
    await tester.tap(find.text('item2'));
    await tester.pump();

    expect(selected, 'item2');
  });

  testWidgets('SearchableListSelector selects item on Enter key', (
    tester,
  ) async {
    String? selected;
    final items = ['item1', 'item2', 'item3'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableListSelector<String>(
            items: items,
            onSelected: (val) => selected = val,
            onCancel: () {},
            searchText: (item) => item,
            itemBuilder: (context, item, isHighlighted, isSelected) {
              return Text(item);
            },
          ),
        ),
      ),
    );

    // Initially first item is selected (index 0)
    // Press Down to highlight item2
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    // Press Enter to select
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, 'item2');
  });

  testWidgets('SearchableListSelector filters items', (tester) async {
    final items = ['apple', 'banana', 'cherry'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchableListSelector<String>(
            items: items,
            onSelected: (_) {},
            onCancel: () {},
            searchText: (item) => item,
            itemBuilder: (context, item, isHighlighted, isSelected) {
              return Text(item);
            },
          ),
        ),
      ),
    );

    expect(find.text('apple'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);
    expect(find.text('cherry'), findsOneWidget);

    // Search for "a"
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();

    expect(find.text('apple'), findsOneWidget);
    expect(find.text('banana'), findsOneWidget);
    expect(find.text('cherry'), findsNothing);
  });
}
