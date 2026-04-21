import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/widgets/proto_map_type_selector.dart';

void main() {
  testWidgets('ProtoMapTypeSelector filters items based on search', (
    tester,
  ) async {
    final availableTypes = [
      'package.a.Message1',
      'package.b.Message2',
      'other.Message3',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapTypeSelector(
            availableTypes: availableTypes,
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    // Initial state: show all
    expect(find.text('Message1'), findsOneWidget);
    expect(find.text('Message2'), findsOneWidget);
    expect(find.text('Message3'), findsOneWidget);

    // Search for "other"
    await tester.enterText(find.byType(TextField), 'other');
    await tester.pump();

    expect(find.text('Message1'), findsNothing);
    expect(find.text('Message2'), findsNothing);
    expect(find.text('Message3'), findsOneWidget);
  });

  testWidgets('ProtoMapTypeSelector handles keyboard navigation', (
    tester,
  ) async {
    String? selected;
    final availableTypes = ['Message1', 'Message2'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapTypeSelector(
            availableTypes: availableTypes,
            onSelected: (val) => selected = val,
            onCancel: () {},
          ),
        ),
      ),
    );

    // Press Down to highlight Message2
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    // Press Enter to select
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, 'Message2');
  });

  testWidgets('ProtoMapTypeSelector shows prefix as subtitle', (tester) async {
    final availableTypes = ['com.example.MyMessage'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapTypeSelector(
            availableTypes: availableTypes,
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('MyMessage'), findsOneWidget);
    expect(find.text('com.example'), findsOneWidget);
  });
}
