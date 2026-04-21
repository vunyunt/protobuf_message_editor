import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

class SubMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'SubMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => SubMessage(),
        )
        ..aOS(1, 'foo')
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  SubMessage createEmptyInstance() => SubMessage();
  @override
  SubMessage clone() => SubMessage()..mergeFromMessage(this);

  String get foo => getField(1);
  set foo(String v) => setField(1, v);
}

class RootMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'RootMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => RootMessage(),
        )
        ..aOM<SubMessage>(1, 'sub', subBuilder: () => SubMessage())
        ..pPS(2, 'tags')
        ..pc<SubMessage>(
          3,
          'subs',
          PbFieldType.PM,
          subBuilder: () => SubMessage(),
        )
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  RootMessage createEmptyInstance() => RootMessage();
  @override
  RootMessage clone() => RootMessage()..mergeFromMessage(this);

  SubMessage get sub => getField(1);
  set sub(SubMessage v) => setField(1, v);

  List<SubMessage> get subs => getField(3);
}

class CustomBuilderProvider extends ProtoMapEditorProvider {
  @override
  GeneratedMessage? getSubmessageBuilder({
    required BuilderInfo submessageBuilderInfo,
    FieldInfo? fieldInfo,
  }) {
    if (submessageBuilderInfo.qualifiedMessageName == 'test.SubMessage') {
      return SubMessage()..foo = 'INITIAL_VALUE';
    }
    return null;
  }
}

void main() {
  testWidgets('Custom builder initializes new submessage fields', (
    WidgetTester tester,
  ) async {
    final root = RootMessage();
    final provider = CustomBuilderProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(message: root, provider: provider),
        ),
      ),
    );

    // Initial state: sub is not set
    expect(find.textContaining('sub'), findsNothing);

    // Click "Add field"
    await tester.tap(find.text('Add field...'));
    await tester.pumpAndSettle();

    // Select 'sub' from the list
    await tester.tap(find.text('sub'));
    await tester.pumpAndSettle();

    // Verify 'sub' is added
    expect(find.textContaining('sub'), findsOneWidget);

    // It should be expanded by default since it was added after initial load
    expect(find.textContaining('INITIAL_VALUE'), findsOneWidget);
  });

  testWidgets('Custom builder initializes new repeated submessage elements', (
    WidgetTester tester,
  ) async {
    final root = RootMessage();
    root.subs.add(SubMessage()..foo = 'existing');
    final provider = CustomBuilderProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtoMapEditor(message: root, provider: provider),
        ),
      ),
    );

    // Expand 'subs'
    await tester.tap(find.textContaining('subs'));
    await tester.pumpAndSettle();

    // Click "Add element"
    await tester.tap(find.text('Add element'));
    await tester.pumpAndSettle();

    // Verify a new element is added and it should be expanded by default
    expect(find.textContaining('INITIAL_VALUE'), findsOneWidget);
    expect(find.textContaining('existing'), findsOneWidget);
  });
}
