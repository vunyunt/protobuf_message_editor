// This is a generated file - do not edit.
//
// Generated from example_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use exampleEnumDescriptor instead')
const ExampleEnum$json = {
  '1': 'ExampleEnum',
  '2': [
    {'1': 'value_zero', '2': 0},
    {'1': 'value_one', '2': 1},
    {'1': 'value_two', '2': 2},
  ],
};

/// Descriptor for `ExampleEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List exampleEnumDescriptor = $convert.base64Decode(
    'CgtFeGFtcGxlRW51bRIOCgp2YWx1ZV96ZXJvEAASDQoJdmFsdWVfb25lEAESDQoJdmFsdWVfdH'
    'dvEAI=');

@$core.Deprecated('Use exampleSubmessageDescriptor instead')
const ExampleSubmessage$json = {
  '1': 'ExampleSubmessage',
  '2': [
    {'1': 'some_string', '3': 1, '4': 1, '5': 9, '10': 'someString'},
    {'1': 'some_int', '3': 2, '4': 1, '5': 3, '10': 'someInt'},
    {
      '1': 'some_enum',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.protobuf_message_editor_example.ExampleEnum',
      '10': 'someEnum'
    },
  ],
};

/// Descriptor for `ExampleSubmessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exampleSubmessageDescriptor = $convert.base64Decode(
    'ChFFeGFtcGxlU3VibWVzc2FnZRIfCgtzb21lX3N0cmluZxgBIAEoCVIKc29tZVN0cmluZxIZCg'
    'hzb21lX2ludBgCIAEoA1IHc29tZUludBJJCglzb21lX2VudW0YAyABKA4yLC5wcm90b2J1Zl9t'
    'ZXNzYWdlX2VkaXRvcl9leGFtcGxlLkV4YW1wbGVFbnVtUghzb21lRW51bQ==');

@$core.Deprecated('Use exampleMessageDescriptor instead')
const ExampleMessage$json = {
  '1': 'ExampleMessage',
  '2': [
    {
      '1': 'example_string_field',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'exampleStringField'
    },
    {'1': 'example_int_field', '3': 2, '4': 1, '5': 3, '10': 'exampleIntField'},
    {
      '1': 'example_submessage',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.protobuf_message_editor_example.ExampleSubmessage',
      '10': 'exampleSubmessage'
    },
    {
      '1': 'example_repeated_string_field',
      '3': 4,
      '4': 3,
      '5': 9,
      '10': 'exampleRepeatedStringField'
    },
    {
      '1': 'example_repeated_int_field',
      '3': 5,
      '4': 3,
      '5': 3,
      '10': 'exampleRepeatedIntField'
    },
    {
      '1': 'example_repeated_submessage_field',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.protobuf_message_editor_example.ExampleSubmessage',
      '10': 'exampleRepeatedSubmessageField'
    },
  ],
};

/// Descriptor for `ExampleMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exampleMessageDescriptor = $convert.base64Decode(
    'Cg5FeGFtcGxlTWVzc2FnZRIwChRleGFtcGxlX3N0cmluZ19maWVsZBgBIAEoCVISZXhhbXBsZV'
    'N0cmluZ0ZpZWxkEioKEWV4YW1wbGVfaW50X2ZpZWxkGAIgASgDUg9leGFtcGxlSW50RmllbGQS'
    'YQoSZXhhbXBsZV9zdWJtZXNzYWdlGAMgASgLMjIucHJvdG9idWZfbWVzc2FnZV9lZGl0b3JfZX'
    'hhbXBsZS5FeGFtcGxlU3VibWVzc2FnZVIRZXhhbXBsZVN1Ym1lc3NhZ2USQQodZXhhbXBsZV9y'
    'ZXBlYXRlZF9zdHJpbmdfZmllbGQYBCADKAlSGmV4YW1wbGVSZXBlYXRlZFN0cmluZ0ZpZWxkEj'
    'sKGmV4YW1wbGVfcmVwZWF0ZWRfaW50X2ZpZWxkGAUgAygDUhdleGFtcGxlUmVwZWF0ZWRJbnRG'
    'aWVsZBJ9CiFleGFtcGxlX3JlcGVhdGVkX3N1Ym1lc3NhZ2VfZmllbGQYBiADKAsyMi5wcm90b2'
    'J1Zl9tZXNzYWdlX2VkaXRvcl9leGFtcGxlLkV4YW1wbGVTdWJtZXNzYWdlUh5leGFtcGxlUmVw'
    'ZWF0ZWRTdWJtZXNzYWdlRmllbGQ=');
