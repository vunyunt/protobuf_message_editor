import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

// Mock messages
class InnerMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('InnerMessage', createEmptyInstance: () => InnerMessage())
    ..aOS(1, 'name');
  @override
  BuilderInfo get info_ => _i;
  @override
  InnerMessage createEmptyInstance() => InnerMessage();
  @override
  InnerMessage clone() => InnerMessage()..mergeFromMessage(this);

  String get name => getField(1) as String? ?? '';
  set name(String v) => setField(1, v);
}

class TestComplexMapMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('TestComplexMapMessage', createEmptyInstance: () => TestComplexMapMessage())
    ..m<String, InnerMessage>(1, 'msgMap', entryClassName: 'TestComplexMapMessage.MsgMapEntry', keyFieldType: PbFieldType.OS, valueFieldType: PbFieldType.OM, valueCreator: () => InnerMessage())
    ..m<String, Int64>(2, 'scalarMap', entryClassName: 'TestComplexMapMessage.ScalarMapEntry', keyFieldType: PbFieldType.OS, valueFieldType: PbFieldType.O6);
  
  @override
  BuilderInfo get info_ => _i;
  @override
  TestComplexMapMessage createEmptyInstance() => TestComplexMapMessage();
  @override
  TestComplexMapMessage clone() => TestComplexMapMessage()..mergeFromMessage(this);

  Map<String, InnerMessage> get msgMap => $_getMap(0);
  Map<String, Int64> get scalarMap => $_getMap(1);
}

void main() {
  testWidgets('Fix Issue 2: Create new key without TypeError', (WidgetTester tester) async {
    final message = TestComplexMapMessage();
    // Initialize maps so they show up in the editor
    message.scalarMap['dummy'] = Int64(0);
    message.scalarMap.remove('dummy');
    message.msgMap['dummy'] = InnerMessage();
    message.msgMap.remove('dummy');
    

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(
            message: message,
          ),
        ),
      ),
    );

    // Expand scalarMap
    final scalarMapLabel = find.textContaining('scalarMap');
    expect(scalarMapLabel, findsOneWidget);
    
    final scalarMapChevron = find.descendant(
      of: find.ancestor(of: scalarMapLabel, matching: find.byType(Row)),
      matching: find.byType(ProtoMapCollapseToggle),
    );
    await tester.tap(scalarMapChevron);
    await tester.pumpAndSettle();

    // Click "Add" button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter key "new_key"
    await tester.enterText(find.byType(TextField), 'new_key');
    // Confirm (onSubmitted)
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Should NOT throw TypeError, and "new_key" should be visible
    expect(tester.takeException(), isNull);
    expect(find.textContaining('new_key'), findsOneWidget);
  });

  testWidgets('Fix Issue 1: Value is shown after expanding key', (WidgetTester tester) async {
    final message = TestComplexMapMessage();
    // Initialize maps
    message.scalarMap['dummy'] = Int64(0);
    message.scalarMap.remove('dummy');
    
    final inner = InnerMessage()..name = 'inner_val';
    message.msgMap['key1'] = inner;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(
            message: message,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Wait for markInitialLoadComplete

    // Expand msgMap
    final msgMapLabel = find.textContaining('msgMap');
    final msgMapChevron = find.descendant(
      of: find.ancestor(of: msgMapLabel, matching: find.byType(Row)),
      matching: find.byType(ProtoMapCollapseToggle),
    );
    await tester.tap(msgMapChevron);
    await tester.pumpAndSettle();

    expect(find.textContaining('key1'), findsOneWidget);

    // Should NOT throw, and should show "name" field of InnerMessage
    expect(tester.takeException(), isNull);
    

    expect(find.text('name:'), findsOneWidget);
    expect(find.text('inner_val'), findsOneWidget);
  });
}
