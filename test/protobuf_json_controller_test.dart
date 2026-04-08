import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/src/protobuf_json_editor/protobuf_json_controller.dart';

// A mock message for testing
class TestMessage extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'TestMessage',
          package: const PackageName('test'),
          createEmptyInstance: () => TestMessage(),
        )
        ..aOS(1, 'name')
        ..a<int>(2, 'value', PbFieldType.O3)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;

  @override
  TestMessage createEmptyInstance() => TestMessage();

  @override
  TestMessage clone() => TestMessage()..mergeFromMessage(this);

  String get name => getField(1) ?? '';
  set name(String v) => setField(1, v);

  int get value => getField(2) ?? 0;
  set value(int v) => setField(2, v);
}

void main() {
  group('ProtobufJsonEditingController', () {
    late TestMessage message;
    late ProtobufJsonEditingController controller;

    setUp(() {
      message = TestMessage()
        ..name = 'test'
        ..value = 123;
      controller = ProtobufJsonEditingController(sourceMessage: message);
    });

    test('initialization converts message to JSON map', () {
      expect(controller.jsonMap, {'name': 'test', 'value': 123});
      expect(controller.isDirty, isFalse);
    });

    test('updateField updates JSON map and marks dirty', () {
      controller.updateField('name', 'new name');
      expect(controller.jsonMap['name'], 'new name');
      expect(controller.isDirty, isTrue);
    });

    test('updateField with same value does not mark dirty', () {
      controller.updateField('name', 'test');
      expect(controller.isDirty, isFalse);
    });

    test('save returns fresh message and does NOT update source message', () {
      controller.updateField('name', 'saved name');
      final result = controller.save() as TestMessage;

      expect(message.name, 'test'); // Source remains unchanged
      expect(result.name, 'saved name');
      expect(controller.isDirty, isFalse);
    });

    test('reset restores JSON map from source message', () {
      controller.updateField('name', 'changed');
      controller.reset();

      expect(controller.jsonMap['name'], 'test');
      expect(controller.isDirty, isFalse);
    });

    test('getFieldInfo returns correct metadata', () {
      final info = controller.getFieldInfo('name');
      expect(info, isNotNull);
      expect(info!.name, 'name');
      expect(info.tagNumber, 1);
    });
  });

  group('ProtobufJsonSubmessageController', () {
    test('initialization uses initialValue map', () {
      final subController = ProtobufJsonSubmessageController(
        initialValue: {'name': 'sub'},
        builderInfo: TestMessage().info_,
      );

      expect(subController.jsonMap, {'name': 'sub'});
    });

    test('onChanged is called when field updates', () {
      Map<String, dynamic>? captured;
      final subController = ProtobufJsonSubmessageController(
        initialValue: {'name': 'sub'},
        builderInfo: TestMessage().info_,
        onChanged: (map) => captured = map,
      );

      subController.updateField('name', 'changed');
      expect(captured, {'name': 'changed'});
      expect(subController.jsonMap['name'], 'changed');
    });

    test('getSavedMessage creates a fresh submessage', () {
      final subController = ProtobufJsonSubmessageController(
        initialValue: {'name': 'sub', 'value': 456},
        builderInfo: TestMessage().info_,
      );

      final result = subController.getSavedMessage() as TestMessage;
      expect(result.name, 'sub');
      expect(result.value, 456);
    });
  });

  _testAny();
}

class MockAny extends GeneratedMessage {
  static final BuilderInfo _i =
      BuilderInfo(
          'Any',
          package: const PackageName('google.protobuf'),
          createEmptyInstance: () => MockAny(),
        )
        ..aOS(1, 'typeUrl')
        ..a<List<int>>(2, 'value', PbFieldType.OY)
        ..hasRequiredFields = false;

  @override
  BuilderInfo get info_ => _i;

  @override
  MockAny createEmptyInstance() => MockAny();

  @override
  MockAny clone() => MockAny()..mergeFromMessage(this);
}

void _testAny() {
  group('ProtobufJsonController Any resolution', () {
    test('Any message expansion is resolved in submessage controller', () {
      final registry = TypeRegistry([TestMessage()]);
      final json = {
        '@type': 'type.googleapis.com/test.TestMessage',
        'name': 'inner',
        'value': 456,
      };

      final subController = ProtobufJsonSubmessageController(
        initialValue: json,
        builderInfo: MockAny().info_,
        typeRegistry: registry,
      );

      expect(
        subController.builderInfo.qualifiedMessageName,
        'test.TestMessage',
      );
      expect(subController.getFieldInfo('name'), isNotNull);
      expect(subController.getFieldInfo('value'), isNotNull);

      subController.updateField('name', 'new inner');
      expect(subController.jsonMap['name'], 'new inner');
      expect(
        subController.jsonMap['@type'],
        'type.googleapis.com/test.TestMessage',
      );
    });

    test('addField with typeUrl initializes @type for Any field', () {
      final parentInfo = BuilderInfo(
        'Parent',
        createEmptyInstance: () => TestMessage(),
      )..aOM<MockAny>(1, 'anyField', subBuilder: () => MockAny());
      final json = <String, dynamic>{};
      final controller = ProtobufJsonSubmessageController(
        initialValue: json,
        builderInfo: parentInfo,
      );

      controller.addField(
        'anyField',
        typeUrl: 'type.googleapis.com/test.TestMessage',
      );

      expect(controller.jsonMap['anyField'], {
        '@type': 'type.googleapis.com/test.TestMessage',
      });
    });

    test('addField without typeUrl for Any field uses empty map', () {
      final parentInfo = BuilderInfo(
        'Parent',
        createEmptyInstance: () => TestMessage(),
      )..aOM<MockAny>(1, 'anyField', subBuilder: () => MockAny());
      final json = <String, dynamic>{};
      final controller = ProtobufJsonSubmessageController(
        initialValue: json,
        builderInfo: parentInfo,
      );

      controller.addField('anyField');

      expect(controller.jsonMap['anyField'], <String, dynamic>{});
    });

    test('updating repeated Any field with typed elements works', () {
      final parentInfo = BuilderInfo(
        'Parent',
        createEmptyInstance: () => TestMessage(),
      )..pPM<MockAny>(1, 'repeatedAny', subBuilder: () => MockAny());
      final json = <String, dynamic>{'repeatedAny': []};
      final controller = ProtobufJsonSubmessageController(
        initialValue: json,
        builderInfo: parentInfo,
      );

      final newList = [
        {'@type': 'type.googleapis.com/test.TestMessage', 'name': 'item1'},
      ];
      controller.updateField('repeatedAny', newList);

      expect(
        controller.jsonMap['repeatedAny'][0]['@type'],
        'type.googleapis.com/test.TestMessage',
      );
    });
  });
}
