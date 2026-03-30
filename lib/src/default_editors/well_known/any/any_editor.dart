import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'any_editor_registry.dart';

class AnyEditor extends CustomMessageEditorBuilder {
  final AnyEditorRegistry registry;

  AnyEditor({required this.registry});

  @override
  String get qualifiedMessageName =>
      Any.getDefault().info_.qualifiedMessageName;

  @override
  Widget build(BuildContext context, {required GeneratedMessage data}) =>
      _AnyEditorWidget(registry: registry, data: data as Any);
}

class _AnyEditorWidget extends StatefulWidget {
  final AnyEditorRegistry registry;
  final Any data;

  const _AnyEditorWidget({required this.registry, required this.data});

  @override
  State<_AnyEditorWidget> createState() => __AnyEditorWidgetState();
}

class __AnyEditorWidgetState extends State<_AnyEditorWidget> {
  GeneratedMessage? _unpackedMessage;
  String? _selectedType;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _unpack();
  }

  void _unpack() {
    if (widget.data.typeUrl.isNotEmpty) {
      final typeName = widget.data.typeUrl.split('/').last;
      final message = widget.registry.lookupMessage(typeName);
      if (message != null) {
        _unpackedMessage = message.deepCopy();
        _unpackedMessage!.mergeFromBuffer(widget.data.value);
        _selectedType = typeName;
      }
    }
  }

  void _onTypeChanged(String? newType) {
    if (newType == null || newType == _selectedType) return;

    setState(() {
      _selectedType = newType;
      final message = widget.registry.lookupMessage(newType)!;
      _unpackedMessage = message.deepCopy();
      _hasUnsavedChanges = true;
    });
  }

  void _save() {
    if (_unpackedMessage == null) return;

    setState(() {
      widget.data.typeUrl = 'type.googleapis.com/$_selectedType';
      widget.data.value = _unpackedMessage!.writeToBuffer();
      _hasUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: _selectedType,
                hint: const Text('Select Message Type'),
                isExpanded: true,
                items: widget.registry.availableMessageNames.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: _onTypeChanged,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _unpackedMessage != null ? _save : null,
              icon: Icon(
                _hasUnsavedChanges ? Icons.save_as : Icons.save,
                color: _hasUnsavedChanges ? Colors.orange : null,
              ),
              label: Text(
                'Save',
                style: TextStyle(
                  color: _hasUnsavedChanges ? Colors.orange : null,
                ),
              ),
            ),
          ],
        ),
        if (_unpackedMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ProtoMessageEditor(
              message: _unpackedMessage!,
              onRebuildRequested: () {
                if (!_hasUnsavedChanges) {
                  setState(() {
                    _hasUnsavedChanges = true;
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}
