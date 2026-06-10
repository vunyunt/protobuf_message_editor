import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

// Mock message with nested message for testing drill-down
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'TestMessage',
    package: const PackageName('test'),
    createEmptyInstance: () => TestMessage(),
  )
    ..aOS(1, 'rootField')
    ..aOM<TestMessage>(2, 'nested', subBuilder: () => TestMessage())
    ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  TestMessage createEmptyInstance() => TestMessage();
  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  String get rootField => getField(1);
  set rootField(String v) => setField(1, v);

  TestMessage get nested => getField(2) as TestMessage;
  set nested(TestMessage v) => setField(2, v);
}

void main() {
  testWidgets('ProtoMapEditor drill-down and back navigation', (
    WidgetTester tester,
  ) async {
    final message = TestMessage()
      ..rootField = 'root-val'
      ..nested = (TestMessage()..rootField = 'nested-val');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(message: message),
        ),
      ),
    );

    Finder findBreadcrumb(String text) {
      return find.descendant(
        of: find.byType(InkWell),
        matching: find.text(text),
      );
    }

    // Initial state: both rootField and nested fields are visible (or nested label is visible)
    expect(find.textContaining('rootField'), findsAtLeast(1));
    expect(find.textContaining('nested'), findsOneWidget);
    expect(find.text('root-val'), findsOneWidget);
    // The breadcrumb bar shouldn't be visible
    expect(findBreadcrumb('TestMessage'), findsNothing);

    // Find the maximize button for the nested field
    final maximizeButton = find.byType(ProtoMapMaximizeButton);
    expect(maximizeButton, findsOneWidget);

    // Drill down into nested message
    await tester.tap(maximizeButton);
    await tester.pumpAndSettle();

    // Now, we should only see the nested message's fields
    // So the 'root-val' text field of the root message should be hidden, but we should see 'nested-val'
    expect(find.text('root-val'), findsNothing);
    expect(find.text('nested-val'), findsOneWidget);

    // The breadcrumb bar should be visible containing "TestMessage" and "nested"
    expect(findBreadcrumb('TestMessage'), findsOneWidget);
    expect(findBreadcrumb('nested'), findsOneWidget);

    // Click on the "TestMessage" breadcrumb to go back
    await tester.tap(findBreadcrumb('TestMessage'));
    await tester.pumpAndSettle();

    // Now we should be back at the root level
    expect(find.text('root-val'), findsOneWidget);
    expect(findBreadcrumb('TestMessage'), findsNothing);
  });
}
