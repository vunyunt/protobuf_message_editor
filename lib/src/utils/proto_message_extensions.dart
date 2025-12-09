import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:protobuf_message_editor/src/utils/proto_field_type_extensions.dart';
import 'package:protobuf/protobuf.dart';

/// Represents a field identifier for a protobuf message.
/// Note that [qualifiedMessageName] represents the *parent*'s type
typedef FieldIdentifier = ({String qualifiedMessageName, int fieldTag});

typedef SubmessageIdentifier = ({int fieldTag, int? listIndex});

extension ProtoMessageExtensions on GeneratedMessage {
  void setFieldFromString({
    required FieldInfo field,
    required String value,

    /// The index of the item in the list if the field is a repeated field.
    int? indexInList,
  }) {
    if ((indexInList != null) != field.isRepeated) {
      throw Exception(
        'IndexInList must be provided if and only if the field is a repeated field',
      );
    }

    if (indexInList != null) {
      final list = getField(field.tagNumber) as List;
      list[indexInList] = value;
    } else if (field.isNumericField()) {
      setNumericValue(field: field, value: value);
    } else if (field.isStringField()) {
      setField(field.tagNumber, value);
    } else {
      throw Exception('Unsupported field type: ${field.type}');
    }
  }

  dynamic parseNumericValue({required FieldInfo field, required String value}) {
    if (field.isNumericField()) {
      switch (PbFieldType.baseType(field.type)) {
        case PbFieldType.INT32_BIT:
        case PbFieldType.UINT32_BIT:
          return int.parse(value);
        case PbFieldType.INT64_BIT:
        case PbFieldType.UINT64_BIT:
          return Int64(int.parse(value));
        case PbFieldType.FLOAT_BIT:
        case PbFieldType.DOUBLE_BIT:
          return double.parse(value);
        default:
          throw Exception('Unsupported numeric field type: ${field.type}');
      }
    } else {
      throw Exception('Unsupported field type: ${field.type}');
    }
  }

  void setNumericValue({required FieldInfo field, required String value}) {
    if (value.isEmpty) {
      clearField(field.tagNumber);
    }

    if (kDebugMode && !field.isNumericField()) {
      throw Exception('Field ${field.name} is not a numeric field');
    }

    setField(field.tagNumber, parseNumericValue(field: field, value: value));
  }

  FieldIdentifier? getFieldIdentifierByName(String name) {
    final fieldInfo = info_.byName[name];
    if (fieldInfo == null) {
      return null;
    }

    return (
      qualifiedMessageName: info_.qualifiedMessageName,
      fieldTag: fieldInfo.tagNumber,
    );
  }

  FieldIdentifier getFieldIdentifierByTag(int tag) {
    final fieldInfo = info_.fieldInfo[tag];
    if (fieldInfo == null) {
      throw Exception('Field $tag not found');
    }

    return (qualifiedMessageName: info_.qualifiedMessageName, fieldTag: tag);
  }
}
