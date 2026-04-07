import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

import 'lib/generated/test_message.pb.dart';

void main() {
  group('getSavedMessage with empty Any fields', () {
    late TypeRegistry registry;

    setUp(() {
      registry = TypeRegistry([TestSubmessage()]);
    });

    test('saves successfully when singular Any field is empty map', () {
      final message = TestMessage()..exampleStringField = 'hello';

      final controller = ProtobufJsonEditingController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      // Simulate adding an Any field without selecting a type.
      controller.addField('exampleAny');

      // Before the fix, this would throw:
      // FormatException: Protobuf JSON decoding failed at: root["exampleAny"]. Expected a string
      final saved = controller.getSavedMessage();

      expect(saved, isA<TestMessage>());
      final savedMsg = saved as TestMessage;
      expect(savedMsg.exampleStringField, equals('hello'));
      // The empty Any field should be treated as unset.
      expect(savedMsg.hasExampleAny(), isFalse);
    });

    test('saves successfully when singular Any field has valid type', () {
      final message = TestMessage();

      final controller = ProtobufJsonEditingController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      controller.updateField('exampleAny', <String, dynamic>{
        '@type':
            'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
        'someString': 'test value',
      });

      final saved = controller.getSavedMessage();

      expect(saved, isA<TestMessage>());
      final savedMsg = saved as TestMessage;
      expect(savedMsg.hasExampleAny(), isTrue);
    });

    test(
      'saves successfully when repeated Any has mix of empty and valid entries',
      () {
        final message = TestMessage();

        final controller = ProtobufJsonEditingController(
          sourceMessage: message,
          typeRegistry: registry,
        );

        controller.updateField('exampleRepeatedAny', [
          <String, dynamic>{
            '@type':
                'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
            'someString': 'first',
          },
          <String, dynamic>{}, // empty Any — should be filtered out
          <String, dynamic>{
            '@type':
                'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
            'someString': 'third',
          },
        ]);

        final saved = controller.getSavedMessage();

        expect(saved, isA<TestMessage>());
        final savedMsg = saved as TestMessage;
        // Only the 2 valid entries should remain.
        expect(savedMsg.exampleRepeatedAny.length, equals(2));
      },
    );

    test('saves successfully when repeated Any is all empty entries', () {
      final message = TestMessage();

      final controller = ProtobufJsonEditingController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      controller.updateField('exampleRepeatedAny', [
        <String, dynamic>{},
        <String, dynamic>{},
      ]);

      final saved = controller.getSavedMessage();

      expect(saved, isA<TestMessage>());
      final savedMsg = saved as TestMessage;
      // All entries were empty, so the repeated field should be empty.
      expect(savedMsg.exampleRepeatedAny, isEmpty);
    });

    test('preserves other fields when stripping empty Any', () {
      final message = TestMessage()
        ..exampleStringField = 'keep me'
        ..exampleIntField = Int64(42);

      final controller = ProtobufJsonEditingController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      // Add an empty Any field.
      controller.addField('exampleAny');

      final saved = controller.getSavedMessage() as TestMessage;

      expect(saved.exampleStringField, equals('keep me'));
      expect(saved.exampleIntField, equals(Int64(42)));
      expect(saved.hasExampleAny(), isFalse);
    });
  });
}
