import 'package:flutter/material.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_controller.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/proto_map_field_info.dart';

/// A node in the navigation stack of [ProtoMapEditor].
class ProtoMapNavigationNode {
  /// The user-friendly label for this breadcrumb level.
  final String label;

  /// The controller managing the state at this level.
  final ProtoMapControllerBase controller;

  /// Field information for this submessage.
  final ProtoMapFieldInfo? fieldInfo;

  ProtoMapNavigationNode({
    required this.label,
    required this.controller,
    this.fieldInfo,
  });
}

/// An [InheritedWidget] that provides navigation stack manipulation functions
/// to nested fields inside [ProtoMapEditor].
class ProtoMapNavigationScope extends InheritedWidget {
  final List<ProtoMapNavigationNode> stack;
  final void Function({
    required String label,
    required ProtoMapControllerBase controller,
    required ProtoMapFieldInfo fieldInfo,
  }) onPush;
  final void Function(int depth) onPopUntilDepth;

  const ProtoMapNavigationScope({
    super.key,
    required this.stack,
    required this.onPush,
    required this.onPopUntilDepth,
    required super.child,
  });

  static ProtoMapNavigationScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProtoMapNavigationScope>();
  }

  @override
  bool updateShouldNotify(ProtoMapNavigationScope oldWidget) {
    return stack != oldWidget.stack;
  }
}
