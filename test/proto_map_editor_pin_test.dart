import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

class LongMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'LongMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => LongMessage(),
        )
        ..pPS(1, 'items')
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  LongMessage createEmptyInstance() => LongMessage();
  @override
  LongMessage clone() => LongMessage()..mergeFromMessage(this);

  List<String> get items => getField(1);
}

void main() {
  testWidgets('Header should remain visible when content is scrolled', (
    WidgetTester tester,
  ) async {
    // Create a message with many items to ensure scrolling is needed
    final message = LongMessage();
    message.items.addAll(List.generate(50, (i) => 'Item $i'));

    // Set a small viewport to force scrolling
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(message: message, onSave: (_) {}),
        ),
      ),
    );

    // Initial state: Save button is visible
    expect(find.text('Save'), findsOneWidget);
    final initialSaveButtonPosition = tester.getCenter(find.text('Save'));

    // Expand the 'items' field first
    await tester.tap(find.text('items:'));
    await tester.pumpAndSettle();

    // Find the scrollable area and scroll down
    final scrollable = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    expect(scrollable, findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Item 49'),
      100.0,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    // After scrolling, Save button should STILL be visible and AT THE SAME POSITION
    // (relative to the screen top, minus any layout changes if any, but since it's pinned, it shouldn't move)
    expect(find.text('Save'), findsOneWidget);
    final finalSaveButtonPosition = tester.getCenter(find.text('Save'));

    expect(
      finalSaveButtonPosition.dy,
      closeTo(initialSaveButtonPosition.dy, 1.0),
      reason:
          'Save button should stay at the same vertical position when scrolling',
    );

    // Verify we actually scrolled
    final ScrollableState scrollableState = tester.state(scrollable);
    expect(
      scrollableState.position.pixels,
      greaterThan(0.0),
      reason: 'Scrollable should have a non-zero offset',
    );
    expect(find.text('[49]:'), findsOneWidget);
  });
}
