import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_editor.dart';

// A mock message for testing
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'TestMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => TestMessage(),
        )
        ..aOS(1, 'name')
        ..a<int>(2, 'value', PbFieldType.O3)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;

  @override
  TestMessage createEmptyInstance() => TestMessage();

  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  String get name => getField(1) ?? '';
  set name(String v) => setField(1, v);

  int get value => getField(2) ?? 0;
  set value(int v) => setField(2, v);
}

void main() {
  testWidgets('ProtobufJsonEditor uses external controller and calls onSave', (
    tester,
  ) async {
    final message = TestMessage()..name = 'Original';
    final controller = ProtoMapController(sourceMessage: message);

    GeneratedMessage? savedMessage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(
            message: message,
            controller: controller,
            onSave: (msg) => savedMessage = msg,
          ),
        ),
      ),
    );

    // Simulate a change
    controller.updateField('name', 'Updated');
    await tester.pump();

    // Verify "Unsaved Changes" is visible
    expect(find.text('Unsaved Changes'), findsOneWidget);

    // Click Save
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify onSave was called with updated message
    expect(savedMessage, isNotNull);
    expect((savedMessage as TestMessage).name, 'Updated');
    expect(controller.isDirty, isFalse);
  });

  testWidgets('ProtobufJsonEditor creates internal controller if none passed', (
    tester,
  ) async {
    final message = TestMessage()..name = 'Original';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProtobufJsonEditor(message: message)),
      ),
    );

    expect(find.text('Editing: test.TestMessage'), findsOneWidget);
  });
}
