import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';

class SubMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'SubMessage',
    package: const PackageName('test'),
    createEmptyInstance: () => SubMessage(),
  )..aOS(1, 'foo');

  @override
  BuilderInfo get info_ => _i;
  @override
  SubMessage createEmptyInstance() => SubMessage();
  @override
  SubMessage clone() => SubMessage()..mergeFromMessage(this);

  String get foo => getField(1) ?? '';
  set foo(String v) => setField(1, v);
}

class RootMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo(
    'RootMessage',
    package: const PackageName('test'),
    createEmptyInstance: () => RootMessage(),
  )..aOM<SubMessage>(1, 'sub', subBuilder: () => SubMessage());

  @override
  BuilderInfo get info_ => _i;
  @override
  RootMessage createEmptyInstance() => RootMessage();
  @override
  RootMessage clone() => RootMessage()..mergeFromMessage(this);

  SubMessage get sub => getField(1);
  set sub(SubMessage v) => setField(1, v);
}

void main() {
  group('ProtoMapController Normalization', () {
    test('updateField normalizes GeneratedMessage to Map', () {
      final root = RootMessage();
      final controller = ProtoMapController(sourceMessage: root);

      final sub = SubMessage()..foo = 'bar';
      controller.updateField('sub', sub);

      expect(controller.jsonMap['sub'], isA<Map<String, dynamic>>());
      expect(controller.jsonMap['sub']['foo'], 'bar');
    });

    test('addField normalizes initialValue GeneratedMessage to Map', () {
      final root = RootMessage();
      final controller = ProtoMapController(sourceMessage: root);

      final sub = SubMessage()..foo = 'baz';
      controller.addField('sub', initialValue: sub);

      expect(controller.jsonMap['sub'], isA<Map<String, dynamic>>());
      expect(controller.jsonMap['sub']['foo'], 'baz');
    });

    test(
      'ProtoMapSubmessageController normalizes initialValue GeneratedMessage',
      () {
        final sub = SubMessage()..foo = 'qux';
        final subController = ProtoMapSubmessageController(
          initialValue: sub as dynamic, // Force dynamic to test normalization
          builderInfo: SubMessage().info_,
        );

        expect(subController.jsonMap, isA<Map<String, dynamic>>());
        expect(subController.jsonMap['foo'], 'qux');
      },
    );
  });
}
