import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

import 'lib/generated/test_message.pb.dart';

class CustomNamesProvider extends ProtoMapEditorProvider {
  final Map<String, String>? customNames;

  CustomNamesProvider({this.customNames});

  @override
  Map<String, String>? get customMessageNames => customNames;
}

void main() {
  testWidgets('Any field editor uses custom name from AnyEditorRegistry', (
    tester,
  ) async {
    final registry = AnyEditorRegistry(
      [
        TestSubmessage.getDefault(),
        AnotherTestSubmessage.getDefault(),
      ],
      customMessageNames: {
        'protobuf_message_editor_test.TestSubmessage': 'Custom Test Submessage',
        'protobuf_message_editor_test.AnotherTestSubmessage': 'Custom Another',
      },
    );

    final submessage = TestSubmessage(someString: 'helloAny');
    final message = TestMessage()..exampleAny = Any.pack(submessage);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(message: message, typeRegistry: registry),
        ),
      ),
    );

    // Should show the custom name in the badge instead of qualified name
    expect(find.text('Custom Test Submessage'), findsWidgets);
    expect(
      find.text('protobuf_message_editor_test.TestSubmessage'),
      findsNothing,
    );
  });

  testWidgets('Any field editor uses custom name from ProtoMapEditorProvider', (
    tester,
  ) async {
    final registry = AnyEditorRegistry([
      TestSubmessage.getDefault(),
      AnotherTestSubmessage.getDefault(),
    ]);

    final provider = CustomNamesProvider(
      customNames: {
        'protobuf_message_editor_test.TestSubmessage': 'Provider Test Submessage',
      },
    );

    final submessage = TestSubmessage(someString: 'helloAny');
    final message = TestMessage()..exampleAny = Any.pack(submessage);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(
            message: message,
            typeRegistry: registry,
            provider: provider,
          ),
        ),
      ),
    );

    // Should show the custom name from provider in the badge
    expect(find.text('Provider Test Submessage'), findsWidgets);
  });

  testWidgets('Any field editor merges provider and registry custom names with provider priority', (
    tester,
  ) async {
    final registry = AnyEditorRegistry(
      [
        TestSubmessage.getDefault(),
        AnotherTestSubmessage.getDefault(),
      ],
      customMessageNames: {
        'protobuf_message_editor_test.TestSubmessage': 'Registry Test Submessage',
        'protobuf_message_editor_test.AnotherTestSubmessage': 'Registry Another',
      },
    );

    final provider = CustomNamesProvider(
      customNames: {
        'protobuf_message_editor_test.TestSubmessage': 'Provider Test Submessage',
      },
    );

    final submessage1 = TestSubmessage(someString: 'one');
    final submessage2 = AnotherTestSubmessage();
    final message = TestMessage()
      ..exampleAny = Any.pack(submessage1); // We'll manually test both

    // Render with exampleAny packed as TestSubmessage
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(
            key: const ValueKey('step-1'),
            message: message,
            typeRegistry: registry,
            provider: provider,
          ),
        ),
      ),
    );

    // TestSubmessage should use the provider's name (higher priority)
    expect(find.text('Provider Test Submessage'), findsWidgets);
    expect(find.text('Registry Test Submessage'), findsNothing);

    // Now pack it with AnotherTestSubmessage
    message.exampleAny = Any.pack(submessage2);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(
            key: const ValueKey('step-2'),
            message: message,
            typeRegistry: registry,
            provider: provider,
          ),
        ),
      ),
    );

    // AnotherTestSubmessage is not in provider, so it should fall back to registry's name
    expect(find.text('Registry Another'), findsWidgets);
  });

  testWidgets('Type selector search shows and filters by custom name', (
    tester,
  ) async {
    final registry = AnyEditorRegistry(
      [
        TestSubmessage.getDefault(),
        AnotherTestSubmessage.getDefault(),
      ],
      customMessageNames: {
        'protobuf_message_editor_test.TestSubmessage': 'Fantastic Submessage',
      },
    );

    final message = TestMessage();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(message: message, typeRegistry: registry),
        ),
      ),
    );

    // Add field
    await tester.tap(find.text('Add field...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('exampleAny'));
    await tester.pumpAndSettle();

    // Click select type
    await tester.tap(find.text('Select type...'));
    await tester.pumpAndSettle();

    // Should see both the custom name and the type prefix
    expect(find.text('Fantastic Submessage'), findsOneWidget);
    expect(find.text('AnotherTestSubmessage'), findsOneWidget);

    // Type query matching custom name in search field
    await tester.enterText(find.byType(TextField), 'Fantastic');
    await tester.pumpAndSettle();

    // Fantastic Submessage should still be visible, AnotherTestSubmessage hidden
    expect(find.text('Fantastic Submessage'), findsOneWidget);
    expect(find.text('AnotherTestSubmessage'), findsNothing);
  });
}
