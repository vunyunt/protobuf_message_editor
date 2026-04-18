import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';

// Mock messages for testing
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'TestMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => TestMessage(),
        )
        ..aOS(1, 'visibleField')
        ..aOS(2, 'excludedField')
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;
  @override
  TestMessage createEmptyInstance() => TestMessage();
  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  String get visibleField => getField(1);
  set visibleField(String v) => setField(1, v);

  String get excludedField => getField(2);
  set excludedField(String v) => setField(2, v);
}

class ExclusionProvider extends ProtoMapEditorProvider {
  @override
  bool shouldExcludeField({
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) {
    return fieldInfo.jsonKey == 'excludedField';
  }
}

void main() {
  testWidgets('ProtoMapEditor excludes fields based on provider', (
    WidgetTester tester,
  ) async {
    final message = TestMessage()
      ..visibleField = 'visible'
      ..excludedField = 'hidden';
    final provider = ExclusionProvider();
    print('DEBUG MESSAGE JSON: ${message.toProto3Json()}');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProtobufJsonEditor(message: message, provider: provider),
        ),
      ),
    );

    // Verify the visible field is rendered
    expect(find.textContaining('visibleField'), findsOneWidget);

    // Verify the excluded field is NOT rendered
    expect(find.textContaining('excludedField'), findsNothing);
  });
}
