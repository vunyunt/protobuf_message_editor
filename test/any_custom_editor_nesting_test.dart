import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_editor.dart';

import 'lib/generated/test_message.pb.dart';

class MockAnyProvider extends ProtoMapEditorProvider {
  @override
  Widget? getSubmessageEditor({
    required ProtobufJsonController controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    if (fieldInfo.jsonKey == 'exampleAny') {
      return ProtoMapAnyFieldEditor(
        controller: controller,
        fieldInfo: fieldInfo,
        provider: this,
      );
    }
    return null;
  }
}

void main() {
  testWidgets(
    'ProtoMapAnyFieldEditor does not double-nest when used via provider',
    (tester) async {
      final message = TestMessage();
      final registry = TypeRegistry([TestSubmessage()]);
      final rootController = ProtoMapController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      final provider = MockAnyProvider();

      // Add the field with some initial content
      rootController.updateField('exampleAny', {
        '@type':
            'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
        'someString': 'initial value',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtobufJsonFieldEditor(
              controller: rootController,
              jsonKey: 'exampleAny',
              provider: provider,
            ),
          ),
        ),
      );

      await tester.pump();

      // The map should look like:
      // {exampleAny: {@type: ...}}
      // NOT {exampleAny: {exampleAny: {@type: ...}}}

      expect(rootController.jsonMap.containsKey('exampleAny'), isTrue);
      final exampleAnyValue = rootController.jsonMap['exampleAny'];
      expect(exampleAnyValue, isA<Map<String, dynamic>>());
      expect((exampleAnyValue as Map).containsKey('exampleAny'), isFalse);
      expect(exampleAnyValue.containsKey('@type'), isTrue);

      // Now try updating a field inside the Any
      // We need to find the nested editor.
      // ProtoMapAnyFieldEditor builds a ProtoMapMessageEditor for the submessage.
      // The fields of TestSubmessage should now be rendered.
      // YamlFieldRow appends a colon to the label.
      final subFieldFinder = find.textContaining('someString');

      expect(subFieldFinder, findsOneWidget);

      // Update the subfield by finding the TextField and entering text
      // TestSubmessage has 'someString' at tag 1.
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'new value');
      await tester.pump();

      expect(
        rootController.jsonMap['exampleAny']['someString'],
        equals('new value'),
      );
      expect(
        rootController.jsonMap['exampleAny'].containsKey('exampleAny'),
        isFalse,
      );
    },
  );
}

// Access private state for testing purposes if needed, OR just use public APIs.
// To use find.byType(ProtoMapAnyFieldEditor), I need to import it.
// To access _ProtoMapAnyFieldEditorState, I'd need to put the test in the same package or use a trick.
// But I can just check the rootController.jsonMap after pumping.
