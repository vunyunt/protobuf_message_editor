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

import 'package:protobuf/protobuf.dart' as $pb;

class ExampleEnum extends $pb.ProtobufEnum {
  static const ExampleEnum value_zero =
      ExampleEnum._(0, _omitEnumNames ? '' : 'value_zero');
  static const ExampleEnum value_one =
      ExampleEnum._(1, _omitEnumNames ? '' : 'value_one');
  static const ExampleEnum value_two =
      ExampleEnum._(2, _omitEnumNames ? '' : 'value_two');

  static const $core.List<ExampleEnum> values = <ExampleEnum>[
    value_zero,
    value_one,
    value_two,
  ];

  static final $core.List<ExampleEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ExampleEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ExampleEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
