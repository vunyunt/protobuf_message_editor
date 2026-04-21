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
    return (type & numericBits) != 0 || _isNumericWkt;
  }

  bool get _isNumericWkt {
    if (!isMessageField) return false;
    final name = subBuilder?.call().info_.qualifiedMessageName;
    return name == 'google.protobuf.DoubleValue' ||
        name == 'google.protobuf.FloatValue' ||
        name == 'google.protobuf.Int32Value' ||
        name == 'google.protobuf.UInt32Value' ||
        name == 'google.protobuf.Int64Value' ||
        name == 'google.protobuf.UInt64Value';
  }

  /// Returns `true` if this is a message or group field.
  bool get isMessageField => isGroupOrMessage;

  /// Returns `true` if this is a boolean field.
  bool get isBoolField =>
      type == PbFieldType.OB ||
      (isMessageField &&
          subBuilder?.call().info_.qualifiedMessageName ==
              'google.protobuf.BoolValue');

  /// Returns `true` if this is an enum field.
  bool get isEnumField => type == PbFieldType.OE || type == PbFieldType.PE;

  /// Returns `true` if this is a `google.protobuf.Any` field.
  bool get isAnyField =>
      isMessageField &&
      subBuilder?.call().info_.qualifiedMessageName == 'google.protobuf.Any';

  /// Returns `true` if this is a bytes field.
  bool get isBytesField => (type & PbFieldType.BYTES_BIT) != 0;

  /// Returns `true` if this is a Well-Known Type that serializes to a scalar in JSON.
  bool get isScalarMessage {
    if (!isMessageField) return false;
    final name = subBuilder?.call().info_.qualifiedMessageName;
    return name != null && _wktScalars.contains(name);
  }

  /// Returns `true` if this is a `google.protobuf.*Value` wrapper type.
  bool get isWrapperType {
    if (!isMessageField) return false;
    final name = subBuilder?.call().info_.qualifiedMessageName;
    return name != null && _wrapperTypes.contains(name);
  }

  static const _wktScalars = {
    'google.protobuf.BoolValue',
    'google.protobuf.StringValue',
    'google.protobuf.BytesValue',
    'google.protobuf.DoubleValue',
    'google.protobuf.FloatValue',
    'google.protobuf.Int32Value',
    'google.protobuf.UInt32Value',
    'google.protobuf.Int64Value',
    'google.protobuf.UInt64Value',
    'google.protobuf.Timestamp',
    'google.protobuf.Duration',
    'google.protobuf.FieldMask',
  };

  static const _wrapperTypes = {
    'google.protobuf.BoolValue',
    'google.protobuf.StringValue',
    'google.protobuf.BytesValue',
    'google.protobuf.DoubleValue',
    'google.protobuf.FloatValue',
    'google.protobuf.Int32Value',
    'google.protobuf.UInt32Value',
    'google.protobuf.Int64Value',
    'google.protobuf.UInt64Value',
  };

  /// Returns the enum name for a given value (int or string).
  String getEnumName(dynamic value) {
    if (!isEnumField) return value?.toString() ?? 'null';
    final values = enumValues!;
    return value is String
        ? value
        : values
              .firstWhere((e) => e.value == value, orElse: () => values.first)
              .name;
  }

  /// Casts a string value to the appropriate type for this field.
  dynamic castString(String value) {
    if ((type & (PbFieldType.DOUBLE_BIT | PbFieldType.FLOAT_BIT)) != 0 ||
        _isFloatWkt) {
      return double.tryParse(value) ?? value;
    }
    if (containsNumber()) {
      // Note: Int64/UInt64 are strings in JSON, but we can treat them
      // as numbers in the UI if possible, or just return as is if parse fails.
      return int.tryParse(value) ?? value;
    }
    if (isBoolField) {
      return value.toLowerCase() == 'true';
    }
    return value;
  }

  bool get _isFloatWkt {
    if (!isMessageField) return false;
    final name = subBuilder?.call().info_.qualifiedMessageName;
    return name == 'google.protobuf.DoubleValue' ||
        name == 'google.protobuf.FloatValue';
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

  /// Returns a sensible default value for this field (or its elements if repeated) for Proto3 JSON representation.
  dynamic getDefaultValue({bool forElement = false}) {
    if (isRepeated && !forElement) return <dynamic>[];
    if (isMapField && !forElement) return <String, dynamic>{};
    if (isMessageField && !isScalarMessage) return <String, dynamic>{};
    if (isBoolField) return false;
    if (isEnumField) return enumValues!.first.name;
    if (isNumericField()) return 0;
    if (isStringField()) return "";
    return null;
  }

  /// Returns a compact string representation of the field's type.
  String get typeNameBadge {
    final suffix = isRepeated ? '[]' : '';
    if (isMapField) {
      return 'map';
    }
    if (isEnumField) return 'enum$suffix';
    if (isMessageField) {
      final messageName = subBuilder?.call().info_.qualifiedMessageName;
      if (messageName != null) {
        return '${messageName.split('.').last}$suffix';
      }
      return 'message$suffix';
    }
    if (isBoolField) return 'bool$suffix';
    if (isStringField()) return 'string$suffix';
    if (isBytesField) return 'bytes$suffix';

    const numericMap = {
      PbFieldType.OD: 'double',
      PbFieldType.OF: 'float',
      PbFieldType.O3: 'int32',
      PbFieldType.O6: 'int64',
      PbFieldType.OS3: 'sint32',
      PbFieldType.OS6: 'sint64',
      PbFieldType.OU3: 'uint32',
      PbFieldType.OU6: 'uint64',
      PbFieldType.OF3: 'fixed32',
      PbFieldType.OF6: 'fixed64',
      PbFieldType.OSF3: 'sfixed32',
      PbFieldType.OSF6: 'sfixed64',
    };

    final baseType = type & ~PbFieldType.REPEATED_BIT;
    final typeName = numericMap[baseType];
    if (typeName != null) return '$typeName$suffix';

    return 'unknown$suffix';
  }
}
