// This is a generated file - do not edit.
//
// Generated from test_message.proto.

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

@$core.Deprecated('Use testEnumDescriptor instead')
const TestEnum$json = {
  '1': 'TestEnum',
  '2': [
    {'1': 'value_zero', '2': 0},
    {'1': 'value_one', '2': 1},
    {'1': 'value_two', '2': 2},
  ],
};

/// Descriptor for `TestEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List testEnumDescriptor = $convert.base64Decode(
    'CghUZXN0RW51bRIOCgp2YWx1ZV96ZXJvEAASDQoJdmFsdWVfb25lEAESDQoJdmFsdWVfdHdvEA'
    'I=');

@$core.Deprecated('Use testSubmessageDescriptor instead')
const TestSubmessage$json = {
  '1': 'TestSubmessage',
  '2': [
    {'1': 'some_string', '3': 1, '4': 1, '5': 9, '10': 'someString'},
    {'1': 'some_int', '3': 2, '4': 1, '5': 3, '10': 'someInt'},
    {
      '1': 'some_enum',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.protobuf_message_editor_test.TestEnum',
      '10': 'someEnum'
    },
  ],
};

/// Descriptor for `TestSubmessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testSubmessageDescriptor = $convert.base64Decode(
    'Cg5UZXN0U3VibWVzc2FnZRIfCgtzb21lX3N0cmluZxgBIAEoCVIKc29tZVN0cmluZxIZCghzb2'
    '1lX2ludBgCIAEoA1IHc29tZUludBJDCglzb21lX2VudW0YAyABKA4yJi5wcm90b2J1Zl9tZXNz'
    'YWdlX2VkaXRvcl90ZXN0LlRlc3RFbnVtUghzb21lRW51bQ==');

@$core.Deprecated('Use anotherTestSubmessageDescriptor instead')
const AnotherTestSubmessage$json = {
  '1': 'AnotherTestSubmessage',
  '2': [
    {'1': 'another_string', '3': 1, '4': 1, '5': 9, '10': 'anotherString'},
    {'1': 'another_int', '3': 2, '4': 1, '5': 3, '10': 'anotherInt'},
  ],
};

/// Descriptor for `AnotherTestSubmessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List anotherTestSubmessageDescriptor = $convert.base64Decode(
    'ChVBbm90aGVyVGVzdFN1Ym1lc3NhZ2USJQoOYW5vdGhlcl9zdHJpbmcYASABKAlSDWFub3RoZX'
    'JTdHJpbmcSHwoLYW5vdGhlcl9pbnQYAiABKANSCmFub3RoZXJJbnQ=');

@$core.Deprecated('Use testMessageDescriptor instead')
const TestMessage$json = {
  '1': 'TestMessage',
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
      '6': '.protobuf_message_editor_test.TestSubmessage',
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
      '6': '.protobuf_message_editor_test.TestSubmessage',
      '10': 'exampleRepeatedSubmessageField'
    },
    {
      '1': 'exampleBoolValue',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.BoolValue',
      '10': 'exampleBoolValue'
    },
    {
      '1': 'exampleAny',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'exampleAny'
    },
    {
      '1': 'example_repeated_any',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'exampleRepeatedAny'
    },
  ],
};

/// Descriptor for `TestMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMessageDescriptor = $convert.base64Decode(
    'CgtUZXN0TWVzc2FnZRIwChRleGFtcGxlX3N0cmluZ19maWVsZBgBIAEoCVISZXhhbXBsZVN0cm'
    'luZ0ZpZWxkEioKEWV4YW1wbGVfaW50X2ZpZWxkGAIgASgDUg9leGFtcGxlSW50RmllbGQSWwoS'
    'ZXhhbXBsZV9zdWJtZXNzYWdlGAMgASgLMiwucHJvdG9idWZfbWVzc2FnZV9lZGl0b3JfdGVzdC'
    '5UZXN0U3VibWVzc2FnZVIRZXhhbXBsZVN1Ym1lc3NhZ2USQQodZXhhbXBsZV9yZXBlYXRlZF9z'
    'dHJpbmdfZmllbGQYBCADKAlSGmV4YW1wbGVSZXBlYXRlZFN0cmluZ0ZpZWxkEjsKGmV4YW1wbG'
    'VfcmVwZWF0ZWRfaW50X2ZpZWxkGAUgAygDUhdleGFtcGxlUmVwZWF0ZWRJbnRGaWVsZBJ3CiFl'
    'eGFtcGxlX3JlcGVhdGVkX3N1Ym1lc3NhZ2VfZmllbGQYBiADKAsyLC5wcm90b2J1Zl9tZXNzYW'
    'dlX2VkaXRvcl90ZXN0LlRlc3RTdWJtZXNzYWdlUh5leGFtcGxlUmVwZWF0ZWRTdWJtZXNzYWdl'
    'RmllbGQSRgoQZXhhbXBsZUJvb2xWYWx1ZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5Cb29sVm'
    'FsdWVSEGV4YW1wbGVCb29sVmFsdWUSNAoKZXhhbXBsZUFueRgIIAEoCzIULmdvb2dsZS5wcm90'
    'b2J1Zi5BbnlSCmV4YW1wbGVBbnkSRgoUZXhhbXBsZV9yZXBlYXRlZF9hbnkYCSADKAsyFC5nb2'
    '9nbGUucHJvdG9idWYuQW55UhJleGFtcGxlUmVwZWF0ZWRBbnk=');
