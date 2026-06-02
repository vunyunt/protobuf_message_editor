import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

import 'lib/generated/test_message.pb.dart';

class MockUnpackedAnyProvider extends ProtoMapEditorProvider {
  @override
  Widget? getSubmessageEditor({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    if (controller.builderInfo.qualifiedMessageName ==
        'protobuf_message_editor_test.TestSubmessage') {
      return const Text(
        'CUSTOM_UNPACKED_EDITOR',
        key: Key('custom_unpacked_editor'),
      );
    }
    return null;
  }
}

void main() {
  testWidgets(
    'ProtoMapAnyFieldEditor resolves and renders custom submessage editor for unpacked Any type',
    (tester) async {
      final message = TestMessage();
      final registry = TypeRegistry([TestSubmessage()]);
      final rootController = ProtoMapController(
        sourceMessage: message,
        typeRegistry: registry,
      );

      final provider = MockUnpackedAnyProvider();

      // Set the Any field to contain a TestSubmessage
      rootController.updateField('exampleAny', {
        '@type':
            'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
        'someString': 'nested test',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtoMapEditor(
              message: message,
              controller: rootController,
              typeRegistry: registry,
              provider: provider,
            ),
          ),
        ),
      );

      await tester.pump();

      // Expand the 'exampleAny' field to show its content
      final anyFieldLabel = find.textContaining('exampleAny');
      expect(anyFieldLabel, findsOneWidget);
      await tester.tap(anyFieldLabel);
      await tester.pumpAndSettle();

      // Verify that the custom unpacked submessage editor is rendered instead of the default fields
      expect(find.byKey(const Key('custom_unpacked_editor')), findsOneWidget);
      expect(find.text('CUSTOM_UNPACKED_EDITOR'), findsOneWidget);
      // Ensure the default 'someString' field editor inside TestSubmessage is NOT rendered
      expect(find.textContaining('someString'), findsNothing);
    },
  );
}
