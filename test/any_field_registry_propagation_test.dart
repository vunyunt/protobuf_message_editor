import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_message_editor.dart';

import 'lib/generated/test_message.pb.dart';

void main() {
  testWidgets(
    'ProtoMapAnyFieldEditor passes customTypeRegistry down to sub-controller',
    (tester) async {
      final message = TestMessage();

      // Root registry is EMPTY
      final rootController = ProtoMapController(
        sourceMessage: message,
        typeRegistry: const TypeRegistry.empty(),
      );

      // Initialize the Any field with just the type info in the map
      rootController.addField(
        'exampleAny',
        typeUrl:
            'type.googleapis.com/protobuf_message_editor_test.TestSubmessage',
      );

      // Custom registry has TestSubmessage
      final customRegistry = AnyEditorRegistry([TestSubmessage.getDefault()]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtoMapAnyFieldEditor(
              controller: rootController,
              fieldInfo: ProtoMapFieldInfo(
                fieldInfo: rootController.getFieldInfo('exampleAny'),
                jsonKey: 'exampleAny',
                depth: 0,
              ),
              customTypeRegistry: customRegistry,
            ),
          ),
        ),
      );

      // Before the fix, the submessage would have been unresolved because it used the empty root registry.
      // This would result in rendering fields of Any (type_url, value) instead of TestSubmessage.

      // Check if sub-fields editor can be interacted with
      expect(find.text('Add field...'), findsWidgets);

      // Verify that '@type' is still in the map (it shouldn't have been stripped during resolution)
      // Actually, subController's builderInfo should be TestSubmessage's builderInfo
      final subEditor = find.byType(ProtoMapMessageEditor);
      expect(subEditor, findsOneWidget);
      final editorWidget = tester.widget<ProtoMapMessageEditor>(subEditor);
      expect(
        editorWidget.controller.builderInfo.qualifiedMessageName,
        'protobuf_message_editor_test.TestSubmessage',
      );
    },
  );
}
