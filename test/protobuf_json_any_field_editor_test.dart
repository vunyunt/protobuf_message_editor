import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

import '../example/lib/generated/example_message.pb.dart';

void main() {
  final registry = AnyEditorRegistry([
    ExampleSubmessage.getDefault(),
    AnotherExampleSubmessage.getDefault(),
  ]);

  testWidgets(
    'ProtobufJsonAnyFieldEditor renders type selector and submessage',
    (tester) async {
      final submessage = ExampleSubmessage(someString: 'helloAny');
      final message = ExampleMessage()..exampleAny = Any.pack(submessage);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtobufJsonEditor(message: message, typeRegistry: registry),
          ),
        ),
      );

      // Should show the type name
      expect(
        find.text('protobuf_message_editor_example.ExampleSubmessage'),
        findsWidgets,
      );

      // Should show the value of the sub-field
      expect(find.text('helloAny'), findsOneWidget);
    },
  );

  testWidgets('ProtobufJsonAnyFieldEditor can change type', (tester) async {
    final message = ExampleMessage();
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
      find
          .text('protobuf_message_editor_example.AnotherExampleSubmessage')
          .last,
    );
    await tester.pumpAndSettle();

    // Now it should show "Add field..." for the submessage
    expect(find.text('Add field...'), findsWidgets);
  });
}
