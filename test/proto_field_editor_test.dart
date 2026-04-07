import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/field_editors/proto_field_editor.dart';
import 'package:provider/provider.dart';
import 'lib/generated/test_message.pb.dart';

void main() {
  testWidgets(
    'ProtoFieldEditor correctly indexes into repeated message fields',
    (WidgetTester tester) async {
      final message = TestMessage()
        ..exampleRepeatedSubmessageField.addAll([
          TestSubmessage(someString: 'item 0'),
          TestSubmessage(someString: 'item 1'),
        ]);

      final fieldInfo =
          message.info_.fieldInfo[6]!; // exampleRepeatedSubmessageField

      GeneratedMessage? passedSubmessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtoFieldEditor(
              message: message,
              fieldInfo: fieldInfo,
              listIndex: 1,
              submessageBuilder:
                  ({
                    required submessage,
                    required parentMessage,
                    required fieldInfo,
                    onRebuildRequested,
                  }) {
                    passedSubmessage = submessage;
                    return Text(submessage.getField(1) as String);
                  },
            ),
          ),
        ),
      );

      expect(passedSubmessage, isNotNull);
      expect(passedSubmessage, isA<TestSubmessage>());
      expect((passedSubmessage as TestSubmessage).someString, 'item 1');
      expect(find.text('item 1'), findsOneWidget);
    },
  );

  testWidgets(
    'ProtoMessageEditor calls getSubmessageEditorBuilder with correct submessage in a list',
    (WidgetTester tester) async {
      final message = TestMessage()
        ..exampleRepeatedSubmessageField.addAll([
          TestSubmessage(someString: 'item 0'),
          TestSubmessage(someString: 'item 1'),
        ]);

      final fieldInfo =
          message.info_.fieldInfo[6]!; // exampleRepeatedSubmessageField

      GeneratedMessage? capturedSubmessage;
      GeneratedMessage? capturedParent;

      final mockProvider = CustomEditorRegistry(
        customMessageEditors: {
          TestSubmessage.getDefault().info_.qualifiedMessageName:
              _MockMessageEditorBuilder((context, data, parent) {
                capturedSubmessage = data;
                capturedParent = parent;
                return Text('Custom Editor for ${data.getField(1)}');
              }),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                Provider<CustomEditorProvider>.value(value: mockProvider),
              ],
              child: ProtoFieldEditor(
                message: message,
                fieldInfo: fieldInfo,
                listIndex: 1,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(capturedSubmessage, isNotNull);
      expect(capturedSubmessage, isA<TestSubmessage>());
      expect((capturedSubmessage as TestSubmessage).someString, 'item 1');
      expect(capturedParent, message);
      expect(find.text('Custom Editor for item 1'), findsOneWidget);
    },
  );
}

class _MockMessageEditorBuilder
    extends CustomMessageEditorBuilder<TestSubmessage> {
  final Widget Function(BuildContext, TestSubmessage, GeneratedMessage?)
  _builder;
  _MockMessageEditorBuilder(this._builder);

  @override
  String get qualifiedMessageName =>
      TestSubmessage.getDefault().info_.qualifiedMessageName;

  @override
  Widget build(
    BuildContext context, {
    required TestSubmessage data,
    GeneratedMessage? parentMessage,
  }) {
    return _builder(context, data, parentMessage);
  }
}
