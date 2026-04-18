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
}
