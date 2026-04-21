import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/proto_map_field_selector.dart';

void main() {
  testWidgets('ProtoMapFieldSelector filters fields based on search', (
    tester,
  ) async {
    final field1 = FieldInfo('field1', 1, 1, PbFieldType.O3);
    final field2 = FieldInfo('otherField', 2, 2, PbFieldType.OS);
    final availableFields = [field1, field2];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapFieldSelector(
            availableFields: availableFields,
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    // Initial state: show all
    expect(find.text('field1'), findsOneWidget);
    expect(find.text('otherField'), findsOneWidget);

    // Search for "other"
    await tester.enterText(find.byType(TextField), 'other');
    await tester.pump();

    expect(find.text('field1'), findsNothing);
    expect(find.text('otherField'), findsOneWidget);
  });

  testWidgets('ProtoMapFieldSelector handles keyboard navigation', (
    tester,
  ) async {
    final field1 = FieldInfo('field1', 1, 1, PbFieldType.O3);
    final field2 = FieldInfo('field2', 2, 2, PbFieldType.O3);
    final availableFields = [field1, field2];

    FieldInfo? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapFieldSelector(
            availableFields: availableFields,
            onSelected: (val) => selected = val,
            onCancel: () {},
          ),
        ),
      ),
    );

    // Press Down to highlight field2
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    // Press Enter to select
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, field2);
  });

  testWidgets('ProtoMapFieldSelector displays type badge', (tester) async {
    final field = FieldInfo('myField', 1, 1, PbFieldType.O3);
    final availableFields = [field];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapFieldSelector(
            availableFields: availableFields,
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('myField'), findsOneWidget);
    expect(find.text('int32'), findsOneWidget);
  });

  testWidgets('ProtoMapFieldSelector shows repeated fields with [] suffix', (
    tester,
  ) async {
    final field = FieldInfo(
      'myRepeatedField',
      1,
      1,
      PbFieldType.P3,
    ); // repeated int32
    final availableFields = [field];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapFieldSelector(
            availableFields: availableFields,
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('myRepeatedField'), findsOneWidget);
    expect(find.text('int32[]'), findsOneWidget);
  });
}
