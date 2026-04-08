import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/custom_editors/protobuf_json_editor_provider.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_field_info.dart';

// Mock messages for testing
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
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  RootMessage createEmptyInstance() => RootMessage();
  @override
  RootMessage clone() => RootMessage()..mergeFromMessage(this);

  SubMessage get sub => getField(1);
  set sub(SubMessage v) => setField(1, v);
}

class MockProvider extends ProtobufJsonEditorProvider {
  bool called = false;
  ProtobufJsonController? lastController;
  ProtobufJsonFieldInfo? lastFieldInfo;

  @override
  Widget? getSubmessageEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) {
    called = true;
    lastController = controller;
    lastFieldInfo = fieldInfo;
    if (controller.builderInfo.qualifiedMessageName == 'test.SubMessage') {
      return const Text('CUSTOM_EDITOR_ACTIVE', key: Key('custom_editor'));
    }
    return null;
  }
}

class EmptyProvider extends ProtobufJsonEditorProvider {
  @override
  Widget? getSubmessageEditor({
    required ProtobufJsonController controller,
    required ProtobufJsonFieldInfo fieldInfo,
  }) => null;
}

void main() {
  testWidgets(
    'ProtobufJsonEditor uses provider for custom submessage editors',
    (WidgetTester tester) async {
      final root = RootMessage()..sub = (SubMessage()..foo = 'bar');
      final provider = MockProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtobufJsonEditor(message: root, provider: provider),
          ),
        ),
      );

      // Verify the custom editor is rendered
      expect(find.byKey(const Key('custom_editor')), findsOneWidget);
      expect(find.text('CUSTOM_EDITOR_ACTIVE'), findsOneWidget);

      // Verify provider was called with correct arguments
      expect(provider.called, isTrue);
      expect(
        provider.lastController?.builderInfo.qualifiedMessageName,
        'test.SubMessage',
      );
      expect(
        provider.lastFieldInfo?.parentBuilderInfo?.qualifiedMessageName,
        'test.RootMessage',
      );
    },
  );

  testWidgets(
    'ProtobufJsonEditor falls back to default editor if provider returns null',
    (WidgetTester tester) async {
      final root = RootMessage()..sub = (SubMessage()..foo = 'bar');
      final provider = EmptyProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProtobufJsonEditor(message: root, provider: provider),
          ),
        ),
      );

      // Verify the default editor is rendered (it should have 'foo' key)
      expect(find.textContaining('foo'), findsOneWidget);
      expect(find.text('CUSTOM_EDITOR_ACTIVE'), findsNothing);
    },
  );
}
