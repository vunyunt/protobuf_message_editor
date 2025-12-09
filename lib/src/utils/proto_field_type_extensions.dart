import 'package:protobuf/protobuf.dart';

extension ProtoFieldTypeExtensions on FieldInfo {
  /// Returns `true` if this is a singular string field.
  ///
  /// Excludes repeated fields and map fields.
  /// Use [containsString] to check for any string type including repeated/map.
  bool isStringField() {
    return containsString() && (!isRepeated) && (!isMapField);
  }

  /// Returns `true` if this field contains string type elements.
  ///
  /// This includes:
  /// - Singular string fields
  /// - Repeated string fields (e.g., `repeated string`)
  /// - Map fields with string keys or values
  bool containsString() {
    return ((type & PbFieldType.STRING_BIT) != 0);
  }

  static const int numericBits =
      PbFieldType.DOUBLE_BIT |
      PbFieldType.FLOAT_BIT |
      PbFieldType.INT32_BIT |
      PbFieldType.INT64_BIT |
      PbFieldType.SINT32_BIT |
      PbFieldType.SINT64_BIT |
      PbFieldType.UINT32_BIT |
      PbFieldType.UINT64_BIT |
      PbFieldType.FIXED32_BIT |
      PbFieldType.FIXED64_BIT |
      PbFieldType.SFIXED32_BIT |
      PbFieldType.SFIXED64_BIT;

  /// Returns `true` if this is a singular numeric field.
  ///
  /// Excludes repeated fields and map fields.
  /// Use [containsNumber] to check for any numeric type including repeated/map.
  bool isNumericField() {
    return containsNumber() && (!isRepeated) && (!isMapField);
  }

  /// Returns `true` if this field contains numeric type elements.
  ///
  /// This includes:
  /// - Singular numeric fields (int32, int64, float, double, etc.)
  /// - Repeated numeric fields (e.g., `repeated int32`)
  /// - Map fields with numeric keys or values
  bool containsNumber() {
    return (type & numericBits) != 0;
  }

  copyWithoutRepeatedBit() {
    return FieldInfo(
      name,
      tagNumber,
      index,
      type ^ PbFieldType.REPEATED_BIT,
      defaultEnumValue: defaultEnumValue,
      enumValues: enumValues,
      protoName: protoName,
      subBuilder: subBuilder,
      valueOf: valueOf,
    );
  }

  /// Creates a default element for repeated fields.
  dynamic makeDefaultElement() {
    assert(
      isRepeated,
      'makeDefaultElement is only available with repeated fields',
    );

    return subBuilder?.call() ??
        defaultEnumValue ??
        copyWithoutRepeatedBit().makeDefault?.call();
  }
}
