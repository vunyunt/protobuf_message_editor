import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/styled_widgets.dart';

// Mock message with nested message and repeated field
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'TestMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => TestMessage(),
        )
        ..aOM<TestMessage>(1, 'nested', subBuilder: () => TestMessage())
        ..pPS(2, 'repeatedStrings')
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  TestMessage createEmptyInstance() => TestMessage();
  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  TestMessage get nested => getField(1) as TestMessage;
  set nested(TestMessage v) => setField(1, v);

  List<String> get repeatedStrings => getField(2) as List<String>;
}

void main() {
  testWidgets('Expandable fields should be collapsed by default', (
    WidgetTester tester,
  ) async {
    final message = TestMessage()
      ..nested = (TestMessage()..repeatedStrings.add('hello'))
      ..repeatedStrings.addAll(['a', 'b']);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProtoMapEditor(message: message)),
      ),
    );

    // Find all ProtoMapCollapseToggle widgets
    final toggleFinders = find.byType(ProtoMapCollapseToggle);
    expect(
      toggleFinders,
      findsNWidgets(2),
      reason:
          'Should find 2 toggles: one for "nested" and one for "repeatedStrings"',
    );

    // Check if sub-content is NOT present (because it's collapsed)
    // For "nested", it should NOT show its children
    expect(
      find.text('hello'),
      findsNothing,
      reason: 'Nested message content should be hidden when collapsed',
    );

    // For "repeatedStrings", it should NOT show its elements
    expect(
      find.text('a'),
      findsNothing,
      reason: 'Repeated field elements should be hidden when collapsed',
    );
  });

  testWidgets('Newly added fields and elements should be expanded', (
    WidgetTester tester,
  ) async {
    final message = TestMessage();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProtoMapEditor(message: message)),
      ),
    );

    // Initial state: nothing is there yet
    expect(find.byType(ProtoMapCollapseToggle), findsNothing);

    // 1. Add a nested message field
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Select 'nested' from the menu
    await tester.tap(find.text('nested'));
    await tester.pumpAndSettle();

    // The field should now exist and be EXPANDED (pointing to 'TestMessage' type label)
    expect(find.byType(ProtoMapCollapseToggle), findsOneWidget);
    expect(find.text('TestMessage'), findsOneWidget);

    // Its children should be visible (Add field... button inside the nested message)
    // There should be two "Add field..." buttons now: one for root, one for nested
    expect(find.text('Add field...'), findsNWidgets(2));

    // 2. Add a repeated field
    await tester.tap(find.text('Add field...').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('repeatedStrings'));
    await tester.pumpAndSettle();

    // Now there should be 3 collapse toggles? Wait, 1 for 'nested', 1 for 'repeatedStrings'
    expect(find.byType(ProtoMapCollapseToggle), findsNWidgets(2));

    // 'repeatedStrings' should be expanded, so it should show the "Add element" button
    expect(find.text('Add element'), findsOneWidget);

    // 3. Add an element to the repeated field
    await tester.tap(find.text('Add element'));
    await tester.pumpAndSettle();

    // The element should be visible (it's a scalar, so no toggle, just the field editor)
    // Input for the string element
    expect(find.byType(TextField), findsOneWidget);
  });
}
