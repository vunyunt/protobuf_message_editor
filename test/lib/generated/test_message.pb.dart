// This is a generated file - do not edit.
//
// Generated from test_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $0;

import 'test_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'test_message.pbenum.dart';

class TestSubmessage extends $pb.GeneratedMessage {
  factory TestSubmessage({
    $core.String? someString,
    $fixnum.Int64? someInt,
    TestEnum? someEnum,
  }) {
    final result = create();
    if (someString != null) result.someString = someString;
    if (someInt != null) result.someInt = someInt;
    if (someEnum != null) result.someEnum = someEnum;
    return result;
  }

  TestSubmessage._();

  factory TestSubmessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestSubmessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestSubmessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'protobuf_message_editor_test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'someString')
    ..aInt64(2, _omitFieldNames ? '' : 'someInt')
    ..aE<TestEnum>(3, _omitFieldNames ? '' : 'someEnum',
        enumValues: TestEnum.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestSubmessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestSubmessage copyWith(void Function(TestSubmessage) updates) =>
      super.copyWith((message) => updates(message as TestSubmessage))
          as TestSubmessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestSubmessage create() => TestSubmessage._();
  @$core.override
  TestSubmessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestSubmessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestSubmessage>(create);
  static TestSubmessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get someString => $_getSZ(0);
  @$pb.TagNumber(1)
  set someString($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSomeString() => $_has(0);
  @$pb.TagNumber(1)
  void clearSomeString() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get someInt => $_getI64(1);
  @$pb.TagNumber(2)
  set someInt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSomeInt() => $_has(1);
  @$pb.TagNumber(2)
  void clearSomeInt() => $_clearField(2);

  @$pb.TagNumber(3)
  TestEnum get someEnum => $_getN(2);
  @$pb.TagNumber(3)
  set someEnum(TestEnum value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSomeEnum() => $_has(2);
  @$pb.TagNumber(3)
  void clearSomeEnum() => $_clearField(3);
}

class AnotherTestSubmessage extends $pb.GeneratedMessage {
  factory AnotherTestSubmessage({
    $core.String? anotherString,
    $fixnum.Int64? anotherInt,
  }) {
    final result = create();
    if (anotherString != null) result.anotherString = anotherString;
    if (anotherInt != null) result.anotherInt = anotherInt;
    return result;
  }

  AnotherTestSubmessage._();

  factory AnotherTestSubmessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnotherTestSubmessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnotherTestSubmessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'protobuf_message_editor_test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'anotherString')
    ..aInt64(2, _omitFieldNames ? '' : 'anotherInt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnotherTestSubmessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnotherTestSubmessage copyWith(
          void Function(AnotherTestSubmessage) updates) =>
      super.copyWith((message) => updates(message as AnotherTestSubmessage))
          as AnotherTestSubmessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnotherTestSubmessage create() => AnotherTestSubmessage._();
  @$core.override
  AnotherTestSubmessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnotherTestSubmessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnotherTestSubmessage>(create);
  static AnotherTestSubmessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get anotherString => $_getSZ(0);
  @$pb.TagNumber(1)
  set anotherString($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAnotherString() => $_has(0);
  @$pb.TagNumber(1)
  void clearAnotherString() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get anotherInt => $_getI64(1);
  @$pb.TagNumber(2)
  set anotherInt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAnotherInt() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnotherInt() => $_clearField(2);
}

class TestMessage extends $pb.GeneratedMessage {
  factory TestMessage({
    $core.String? exampleStringField,
    $fixnum.Int64? exampleIntField,
    TestSubmessage? exampleSubmessage,
    $core.Iterable<$core.String>? exampleRepeatedStringField,
    $core.Iterable<$fixnum.Int64>? exampleRepeatedIntField,
    $core.Iterable<TestSubmessage>? exampleRepeatedSubmessageField,
    $0.BoolValue? exampleBoolValue,
    $1.Any? exampleAny,
    $core.Iterable<$1.Any>? exampleRepeatedAny,
  }) {
    final result = create();
    if (exampleStringField != null)
      result.exampleStringField = exampleStringField;
    if (exampleIntField != null) result.exampleIntField = exampleIntField;
    if (exampleSubmessage != null) result.exampleSubmessage = exampleSubmessage;
    if (exampleRepeatedStringField != null)
      result.exampleRepeatedStringField.addAll(exampleRepeatedStringField);
    if (exampleRepeatedIntField != null)
      result.exampleRepeatedIntField.addAll(exampleRepeatedIntField);
    if (exampleRepeatedSubmessageField != null)
      result.exampleRepeatedSubmessageField
          .addAll(exampleRepeatedSubmessageField);
    if (exampleBoolValue != null) result.exampleBoolValue = exampleBoolValue;
    if (exampleAny != null) result.exampleAny = exampleAny;
    if (exampleRepeatedAny != null)
      result.exampleRepeatedAny.addAll(exampleRepeatedAny);
    return result;
  }

  TestMessage._();

  factory TestMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TestMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TestMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'protobuf_message_editor_test'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exampleStringField')
    ..aInt64(2, _omitFieldNames ? '' : 'exampleIntField')
    ..aOM<TestSubmessage>(3, _omitFieldNames ? '' : 'exampleSubmessage',
        subBuilder: TestSubmessage.create)
    ..pPS(4, _omitFieldNames ? '' : 'exampleRepeatedStringField')
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'exampleRepeatedIntField', $pb.PbFieldType.K6)
    ..pPM<TestSubmessage>(
        6, _omitFieldNames ? '' : 'exampleRepeatedSubmessageField',
        subBuilder: TestSubmessage.create)
    ..aOM<$0.BoolValue>(7, _omitFieldNames ? '' : 'exampleBoolValue',
        protoName: 'exampleBoolValue', subBuilder: $0.BoolValue.create)
    ..aOM<$1.Any>(8, _omitFieldNames ? '' : 'exampleAny',
        protoName: 'exampleAny', subBuilder: $1.Any.create)
    ..pPM<$1.Any>(9, _omitFieldNames ? '' : 'exampleRepeatedAny',
        subBuilder: $1.Any.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TestMessage copyWith(void Function(TestMessage) updates) =>
      super.copyWith((message) => updates(message as TestMessage))
          as TestMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMessage create() => TestMessage._();
  @$core.override
  TestMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TestMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TestMessage>(create);
  static TestMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get exampleStringField => $_getSZ(0);
  @$pb.TagNumber(1)
  set exampleStringField($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExampleStringField() => $_has(0);
  @$pb.TagNumber(1)
  void clearExampleStringField() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get exampleIntField => $_getI64(1);
  @$pb.TagNumber(2)
  set exampleIntField($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExampleIntField() => $_has(1);
  @$pb.TagNumber(2)
  void clearExampleIntField() => $_clearField(2);

  @$pb.TagNumber(3)
  TestSubmessage get exampleSubmessage => $_getN(2);
  @$pb.TagNumber(3)
  set exampleSubmessage(TestSubmessage value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExampleSubmessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearExampleSubmessage() => $_clearField(3);
  @$pb.TagNumber(3)
  TestSubmessage ensureExampleSubmessage() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get exampleRepeatedStringField => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get exampleRepeatedIntField => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<TestSubmessage> get exampleRepeatedSubmessageField => $_getList(5);

  @$pb.TagNumber(7)
  $0.BoolValue get exampleBoolValue => $_getN(6);
  @$pb.TagNumber(7)
  set exampleBoolValue($0.BoolValue value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasExampleBoolValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearExampleBoolValue() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.BoolValue ensureExampleBoolValue() => $_ensure(6);

  @$pb.TagNumber(8)
  $1.Any get exampleAny => $_getN(7);
  @$pb.TagNumber(8)
  set exampleAny($1.Any value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExampleAny() => $_has(7);
  @$pb.TagNumber(8)
  void clearExampleAny() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Any ensureExampleAny() => $_ensure(7);

  @$pb.TagNumber(9)
  $pb.PbList<$1.Any> get exampleRepeatedAny => $_getList(8);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
