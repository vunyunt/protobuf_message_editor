import 'package:protobuf/protobuf.dart';

/// A custom implementation for [TypeRegistry] that is used by [AnyEditor].
///
/// This provides a way to access an iterable of all available message types
class AnyEditorRegistry implements TypeRegistry {
  final Map<String, BuilderInfo> _mapping;
  final Map<String, GeneratedMessage> _messages;
  final Map<String, String>? customMessageNames;

  AnyEditorRegistry(
    Iterable<GeneratedMessage> types, {
    this.customMessageNames,
  })  : _mapping = Map.fromEntries(
          types.map(
            (message) =>
                MapEntry(message.info_.qualifiedMessageName, message.info_),
          ),
        ),
        _messages = Map.fromEntries(
          types.map(
            (message) => MapEntry(message.info_.qualifiedMessageName, message),
          ),
        );

  const AnyEditorRegistry.empty()
      : _mapping = const {},
        _messages = const {},
        customMessageNames = null;

  @override
  BuilderInfo? lookup(String qualifiedName) {
    return _mapping[qualifiedName];
  }

  GeneratedMessage? lookupMessage(String qualifiedName) {
    return _messages[qualifiedName];
  }

  Iterable<String> get availableMessageNames => _mapping.keys;
}
