import 'package:flutter/material.dart';

/// A [ThemeExtension] that defines the styling tokens for the Protobuf JSON editor.
@immutable
class ProtoMapEditorTheme extends ThemeExtension<ProtoMapEditorTheme> {
  /// The style for field labels (e.g., "fieldName:").
  final TextStyle fieldLabelStyle;

  /// The style for field values (e.g., strings, numbers in text fields).
  final TextStyle fieldValueStyle;

  /// The style for hint text (e.g., "null", "No type selected").
  final TextStyle hintTextStyle;

  /// The style for action buttons (e.g., "Add field...", "Add element").
  final TextStyle actionButtonStyle;

  /// The style for the "Unsaved Changes" indicator.
  final TextStyle unsavedChangesStyle;

  /// The style for enum values in dropdowns.
  final TextStyle enumValueStyle;

  /// The style for the type badge text in `google.protobuf.Any` editors.
  final TextStyle typeBadgeStyle;

  /// The color for remove/close buttons.
  final Color removeButtonColor;

  /// The color for collapse/expand toggle icons.
  final Color collapseToggleColor;

  /// The decoration for the type selector badge in `google.protobuf.Any` editors.
  final BoxDecoration typeBadgeDecoration;

  /// The width of a single indentation level.
  final double indentWidth;

  /// The padding for a single field row.
  final EdgeInsets fieldRowPadding;

  /// The content padding for the main editor container.
  final EdgeInsets contentPadding;

  /// The fixed height for field value widgets (scalar/enum editors).
  final double fieldValueHeight;

  /// The size for small icons (add, remove).
  final double smallIconSize;

  /// The colors to use for different nesting depths.
  ///
  /// If depth exceeds the length of this list, it wraps around.
  final List<Color> depthColors;

  /// The size for collapse/expand toggle icons.
  final double collapseIconSize;

  const ProtoMapEditorTheme({
    required this.fieldLabelStyle,
    required this.fieldValueStyle,
    required this.hintTextStyle,
    required this.actionButtonStyle,
    required this.unsavedChangesStyle,
    required this.enumValueStyle,
    required this.typeBadgeStyle,
    required this.removeButtonColor,
    required this.collapseToggleColor,
    required this.typeBadgeDecoration,
    required this.indentWidth,
    required this.fieldRowPadding,
    required this.contentPadding,
    required this.fieldValueHeight,
    required this.smallIconSize,
    required this.collapseIconSize,
    required this.depthColors,
  });

  /// Creates a [ProtoMapEditorTheme] with default values that match the current hardcoded look.
  factory ProtoMapEditorTheme.defaults(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ProtoMapEditorTheme(
      fieldLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      fieldValueStyle: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
      hintTextStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
      actionButtonStyle: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unsavedChangesStyle: const TextStyle(color: Colors.orange, fontSize: 12),
      enumValueStyle: const TextStyle(
        fontSize: 13,
        fontFamily: 'monospace',
        color: Colors.blue,
      ),
      typeBadgeStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
      removeButtonColor: Colors.grey,
      collapseToggleColor: Colors.grey[600]!,
      typeBadgeDecoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      indentWidth: 16.0,
      fieldRowPadding: const EdgeInsets.symmetric(vertical: 2.0),
      contentPadding: const EdgeInsets.all(8.0),
      fieldValueHeight: 24.0,
      smallIconSize: 14.0,
      collapseIconSize: 16.0,
      depthColors: [
        primaryColor,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.indigo,
        Colors.pink,
      ],
    );
  }

  /// Gets the color for a label at the given depth.
  Color getLabelColor(int depth) {
    if (depthColors.isEmpty) return fieldLabelStyle.color ?? Colors.black;
    return depthColors[depth % depthColors.length];
  }

  /// Returns the [ProtoMapEditorTheme] from the current [Theme].
  ///
  /// Falls back to [ProtoMapEditorTheme.defaults] if no extension is found.
  static ProtoMapEditorTheme of(BuildContext context) {
    return Theme.of(context).extension<ProtoMapEditorTheme>() ??
        ProtoMapEditorTheme.defaults(context);
  }

  @override
  ProtoMapEditorTheme copyWith({
    TextStyle? fieldLabelStyle,
    TextStyle? fieldValueStyle,
    TextStyle? hintTextStyle,
    TextStyle? actionButtonStyle,
    TextStyle? unsavedChangesStyle,
    TextStyle? enumValueStyle,
    TextStyle? typeBadgeStyle,
    Color? removeButtonColor,
    Color? collapseToggleColor,
    BoxDecoration? typeBadgeDecoration,
    double? indentWidth,
    EdgeInsets? fieldRowPadding,
    EdgeInsets? contentPadding,
    double? fieldValueHeight,
    double? smallIconSize,
    double? collapseIconSize,
    List<Color>? depthColors,
  }) {
    return ProtoMapEditorTheme(
      fieldLabelStyle: fieldLabelStyle ?? this.fieldLabelStyle,
      fieldValueStyle: fieldValueStyle ?? this.fieldValueStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      actionButtonStyle: actionButtonStyle ?? this.actionButtonStyle,
      unsavedChangesStyle: unsavedChangesStyle ?? this.unsavedChangesStyle,
      enumValueStyle: enumValueStyle ?? this.enumValueStyle,
      typeBadgeStyle: typeBadgeStyle ?? this.typeBadgeStyle,
      removeButtonColor: removeButtonColor ?? this.removeButtonColor,
      collapseToggleColor: collapseToggleColor ?? this.collapseToggleColor,
      typeBadgeDecoration: typeBadgeDecoration ?? this.typeBadgeDecoration,
      indentWidth: indentWidth ?? this.indentWidth,
      fieldRowPadding: fieldRowPadding ?? this.fieldRowPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      fieldValueHeight: fieldValueHeight ?? this.fieldValueHeight,
      smallIconSize: smallIconSize ?? this.smallIconSize,
      collapseIconSize: collapseIconSize ?? this.collapseIconSize,
      depthColors: depthColors ?? this.depthColors,
    );
  }

  @override
  ProtoMapEditorTheme lerp(
    ThemeExtension<ProtoMapEditorTheme>? other,
    double t,
  ) {
    if (other is! ProtoMapEditorTheme) return this;

    return ProtoMapEditorTheme(
      fieldLabelStyle: TextStyle.lerp(
        fieldLabelStyle,
        other.fieldLabelStyle,
        t,
      )!,
      fieldValueStyle: TextStyle.lerp(
        fieldValueStyle,
        other.fieldValueStyle,
        t,
      )!,
      hintTextStyle: TextStyle.lerp(hintTextStyle, other.hintTextStyle, t)!,
      actionButtonStyle: TextStyle.lerp(
        actionButtonStyle,
        other.actionButtonStyle,
        t,
      )!,
      unsavedChangesStyle: TextStyle.lerp(
        unsavedChangesStyle,
        other.unsavedChangesStyle,
        t,
      )!,
      enumValueStyle: TextStyle.lerp(enumValueStyle, other.enumValueStyle, t)!,
      typeBadgeStyle: TextStyle.lerp(typeBadgeStyle, other.typeBadgeStyle, t)!,
      removeButtonColor: Color.lerp(
        removeButtonColor,
        other.removeButtonColor,
        t,
      )!,
      collapseToggleColor: Color.lerp(
        collapseToggleColor,
        other.collapseToggleColor,
        t,
      )!,
      typeBadgeDecoration: BoxDecoration.lerp(
        typeBadgeDecoration,
        other.typeBadgeDecoration,
        t,
      )!,
      indentWidth: lerpDouble(indentWidth, other.indentWidth, t)!,
      fieldRowPadding: EdgeInsets.lerp(
        fieldRowPadding,
        other.fieldRowPadding,
        t,
      )!,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
      fieldValueHeight: lerpDouble(
        fieldValueHeight,
        other.fieldValueHeight,
        t,
      )!,
      smallIconSize: lerpDouble(smallIconSize, other.smallIconSize, t)!,
      collapseIconSize: lerpDouble(
        collapseIconSize,
        other.collapseIconSize,
        t,
      )!,
      depthColors: t < 0.5 ? depthColors : other.depthColors,
    );
  }

  /// Helper for interpolating doubles.
  static double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? 0) + ((b ?? 0) - (a ?? 0)) * t;
  }
}

@Deprecated('Use ProtoMapEditorTheme instead')
typedef ProtobufEditorTheme = ProtoMapEditorTheme;
