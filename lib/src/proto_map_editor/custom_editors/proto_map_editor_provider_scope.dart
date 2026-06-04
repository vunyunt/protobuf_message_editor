import 'package:flutter/widgets.dart';
import 'package:protobuf_message_editor/src/proto_map_editor/custom_editors/proto_map_editor_provider.dart';

/// A scope that provides a [ProtoMapEditorProvider] to the widget tree.
class ProtoMapEditorProviderScope extends InheritedWidget {
  /// The custom editor provider.
  final ProtoMapEditorProvider? provider;

  /// Creates a [ProtoMapEditorProviderScope].
  const ProtoMapEditorProviderScope({
    super.key,
    required this.provider,
    required super.child,
  });

  /// Resolves the nearest [ProtoMapEditorProvider] from the given [context].
  static ProtoMapEditorProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProtoMapEditorProviderScope>()
        ?.provider;
  }

  @override
  bool updateShouldNotify(ProtoMapEditorProviderScope oldWidget) {
    return provider != oldWidget.provider;
  }
}
