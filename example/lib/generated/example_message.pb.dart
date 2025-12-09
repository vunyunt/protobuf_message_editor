// This is a generated file - do not edit.
//
// Generated from example_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'example_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'example_message.pbenum.dart';

class ExampleSubmessage extends $pb.GeneratedMessage {
  factory ExampleSubmessage({
    $core.String? someString,
    $fixnum.Int64? someInt,
    ExampleEnum? someEnum,
  }) {
    final result = create();
    if (someString != null) result.someString = someString;
    if (someInt != null) result.someInt = someInt;
    if (someEnum != null) result.someEnum = someEnum;
    return result;
  }

  ExampleSubmessage._();

  factory ExampleSubmessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExampleSubmessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExampleSubmessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'protobuf_message_editor_example'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'someString')
    ..aInt64(2, _omitFieldNames ? '' : 'someInt')
    ..aE<ExampleEnum>(3, _omitFieldNames ? '' : 'someEnum',
        enumValues: ExampleEnum.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExampleSubmessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExampleSubmessage copyWith(void Function(ExampleSubmessage) updates) =>
      super.copyWith((message) => updates(message as ExampleSubmessage))
          as ExampleSubmessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExampleSubmessage create() => ExampleSubmessage._();
  @$core.override
  ExampleSubmessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExampleSubmessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExampleSubmessage>(create);
  static ExampleSubmessage? _defaultInstance;

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
  ExampleEnum get someEnum => $_getN(2);
  @$pb.TagNumber(3)
  set someEnum(ExampleEnum value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSomeEnum() => $_has(2);
  @$pb.TagNumber(3)
  void clearSomeEnum() => $_clearField(3);
}

class ExampleMessage extends $pb.GeneratedMessage {
  factory ExampleMessage({
    $core.String? exampleStringField,
    $fixnum.Int64? exampleIntField,
    ExampleSubmessage? exampleSubmessage,
    $core.Iterable<$core.String>? exampleRepeatedStringField,
    $core.Iterable<$fixnum.Int64>? exampleRepeatedIntField,
    $core.Iterable<ExampleSubmessage>? exampleRepeatedSubmessageField,
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
    return result;
  }

  ExampleMessage._();

  factory ExampleMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExampleMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExampleMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'protobuf_message_editor_example'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exampleStringField')
    ..aInt64(2, _omitFieldNames ? '' : 'exampleIntField')
    ..aOM<ExampleSubmessage>(3, _omitFieldNames ? '' : 'exampleSubmessage',
        subBuilder: ExampleSubmessage.create)
    ..pPS(4, _omitFieldNames ? '' : 'exampleRepeatedStringField')
    ..p<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'exampleRepeatedIntField', $pb.PbFieldType.K6)
    ..pPM<ExampleSubmessage>(
        6, _omitFieldNames ? '' : 'exampleRepeatedSubmessageField',
        subBuilder: ExampleSubmessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExampleMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExampleMessage copyWith(void Function(ExampleMessage) updates) =>
      super.copyWith((message) => updates(message as ExampleMessage))
          as ExampleMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExampleMessage create() => ExampleMessage._();
  @$core.override
  ExampleMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExampleMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExampleMessage>(create);
  static ExampleMessage? _defaultInstance;

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
  ExampleSubmessage get exampleSubmessage => $_getN(2);
  @$pb.TagNumber(3)
  set exampleSubmessage(ExampleSubmessage value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExampleSubmessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearExampleSubmessage() => $_clearField(3);
  @$pb.TagNumber(3)
  ExampleSubmessage ensureExampleSubmessage() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get exampleRepeatedStringField => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get exampleRepeatedIntField => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<ExampleSubmessage> get exampleRepeatedSubmessageField =>
      $_getList(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
