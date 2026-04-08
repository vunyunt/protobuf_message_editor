import 'package:flutter/foundation.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'any_editor_registry.dart';

@Deprecated('Use ProtobufJsonEditor instead')
class AnyEditingController extends ChangeNotifier {
  final Any data;
  final AnyEditorRegistry registry;

  GeneratedMessage? _unpackedMessage;
  String? _selectedType;
  bool _hasUnsavedChanges = false;

  AnyEditingController({required this.data, required this.registry}) {
    _unpack();
  }

  GeneratedMessage? get unpackedMessage => _unpackedMessage;
  String? get selectedType => _selectedType;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void _unpack() {
    if (data.typeUrl.isNotEmpty) {
      final typeName = data.typeUrl.split('/').last;
      final message = registry.lookupMessage(typeName);
      if (message != null) {
        _unpackedMessage = message.deepCopy();
        _unpackedMessage!.mergeFromBuffer(data.value);
        _selectedType = typeName;
      }
    }
  }

  void onTypeChanged(String? newType) {
    if (newType == null || newType == _selectedType) return;

    _selectedType = newType;
    final message = registry.lookupMessage(newType)!;
    _unpackedMessage = message.deepCopy();
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void save() {
    if (_unpackedMessage == null) return;

    data.typeUrl = _selectedType!;
    data.value = _unpackedMessage!.writeToBuffer();
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void markDirty() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }
}
