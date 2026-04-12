import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

import 'lib/generated/test_message.pb.dart';

void main() {
  final registry = AnyEditorRegistry([
    TestSubmessage.getDefault(),
    AnotherTestSubmessage.getDefault(),
  ]);

  testWidgets(
    'ProtoMapAnyFieldEditor renders type selector and submessage',
    (tester) async {
      final submessage = TestSubmessage(someString: 'helloAny');
      final message = TestMessage()..exampleAny = Any.pack(submessage);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtobufJsonEditor(message: message, typeRegistry: registry),
          ),
        ),
      );

      // Should show the type name
      expect(
        find.text('protobuf_message_editor_test.TestSubmessage'),
        findsWidgets,
      );

      // Should show the value of the sub-field
      expect(find.text('helloAny'), findsOneWidget);
    },
  );

  testWidgets('ProtoMapAnyFieldEditor can change type', (tester) async {
    final message = TestMessage();
    // Do NOT set exampleAny to Any() here.

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(message: message, typeRegistry: registry),
        ),
      ),
    );

    // Add exampleAny field first
    await tester.tap(find.text('Add field...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('exampleAny'));
    await tester.pumpAndSettle();

    expect(find.text('Select type...'), findsOneWidget);

    // Open type selector menu
    await tester.tap(find.text('Select type...'));
    await tester.pumpAndSettle();

    // Select AnotherExampleSubmessage
    await tester.tap(
      find.text('protobuf_message_editor_test.AnotherTestSubmessage').last,
    );
    await tester.pumpAndSettle();

    // Now it should show "Add field..." for the submessage
    expect(find.text('Add field...'), findsWidgets);
  });

  testWidgets('ProtoMapAnyFieldEditor handles null rawValue', (
    tester,
  ) async {
    final message = TestMessage();
    final controller = ProtoMapController(
      sourceMessage: message,
      typeRegistry: registry,
    );

    // Manually force a null value for exampleAny which is an Any field
    final json = Map<String, dynamic>.from(controller.jsonMap);
    json['exampleAny'] = null;
    controller.updateFullJson(json);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonFieldEditor(
            controller: controller,
            jsonKey: 'exampleAny',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Select type...'), findsOneWidget);
  });

  testWidgets('ProtoMapAnyFieldEditor handles null label', (tester) async {
    final message = TestMessage();
    final controller = ProtoMapController(
      sourceMessage: message,
      typeRegistry: registry,
    );

    // Initialize the field in the map
    controller.addField('exampleAny');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapAnyFieldEditor(
            controller: controller,
            fieldInfo: ProtoMapFieldInfo(
              fieldInfo: controller.getFieldInfo('exampleAny'),
              jsonKey: 'exampleAny',
              label: null, // Force null label
              depth: 0,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Select type...'), findsOneWidget);
  });
}
