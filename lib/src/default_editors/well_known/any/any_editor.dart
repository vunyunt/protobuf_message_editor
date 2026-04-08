import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

// For compatibility
@Deprecated('Use ProtobufJsonEditor instead')
typedef AnyEditor = AnyEditorBuilder;

@Deprecated('Use ProtobufJsonEditor instead')
class AnyEditorBuilder extends CustomMessageEditorBuilder {
  final AnyEditorRegistry registry;

  AnyEditorBuilder({required this.registry});

  @override
  String get qualifiedMessageName =>
      Any.getDefault().info_.qualifiedMessageName;

  @override
  Widget build(
    BuildContext context, {
    required GeneratedMessage data,
    GeneratedMessage? parentMessage,
  }) => AnyEditorWidget(registry: registry, data: data as Any);
}

@Deprecated('Use ProtobufJsonEditor instead')
class AnyEditorWidget extends StatefulWidget {
  final AnyEditorRegistry registry;
  final Any data;
  final AnyEditingController? controller;

  const AnyEditorWidget({
    super.key,
    required this.registry,
    required this.data,
    this.controller,
  });

  @override
  State<AnyEditorWidget> createState() => _AnyEditorWidgetState();
}

class _AnyEditorWidgetState extends State<AnyEditorWidget> {
  late AnyEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        AnyEditingController(data: widget.data, registry: widget.registry);
  }

  @override
  void didUpdateWidget(covariant AnyEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller =
          widget.controller ??
          AnyEditingController(data: widget.data, registry: widget.registry);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final unpackedMessage = _controller.unpackedMessage;
        final selectedType = _controller.selectedType;
        final hasUnsavedChanges = _controller.hasUnsavedChanges;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedType,
                    hint: const Text('Select Message Type'),
                    isExpanded: true,
                    items: widget.registry.availableMessageNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: _controller.onTypeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: unpackedMessage != null ? _controller.save : null,
                  icon: Icon(
                    hasUnsavedChanges ? Icons.save_as : Icons.save,
                    color: hasUnsavedChanges ? Colors.orange : null,
                  ),
                  label: Text(
                    'Save',
                    style: TextStyle(
                      color: hasUnsavedChanges ? Colors.orange : null,
                    ),
                  ),
                ),
              ],
            ),
            if (unpackedMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ProtoMessageEditor(
                  message: unpackedMessage,
                  onRebuildRequested: _controller.markDirty,
                ),
              ),
          ],
        );
      },
    );
  }
}
