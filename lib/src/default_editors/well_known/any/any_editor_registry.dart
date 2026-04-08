import 'package:protobuf/protobuf.dart';

/// A custom implementation for [TypeRegistry] that is used by [AnyEditor].
///
/// This provides a way to access an iterable of all available message types
@Deprecated('Use ProtobufJsonEditor instead')
class AnyEditorRegistry implements TypeRegistry {
  final Map<String, BuilderInfo> _mapping;
  final Map<String, GeneratedMessage> _messages;

  AnyEditorRegistry(Iterable<GeneratedMessage> types)
    : _mapping = Map.fromEntries(
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

  const AnyEditorRegistry.empty() : _mapping = const {}, _messages = const {};

  @override
  BuilderInfo? lookup(String qualifiedName) {
    return _mapping[qualifiedName];
  }

  GeneratedMessage? lookupMessage(String qualifiedName) {
    return _messages[qualifiedName];
  }

  Iterable<String> get availableMessageNames => _mapping.keys;
}
