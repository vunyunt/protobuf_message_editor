import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';

class DataInspectorModule extends StatefulWidget {
  final Directory dataDirectory;
  final Directory localDirectory;
  final GeneratedMessage? Function(String relativePath) getMessageTypeForPath;
  final TypeRegistry typeRegistry;
  final Iterable<String> registeredTypeNames;
  final Future<void> Function(File file)? onFileSaved;

  const DataInspectorModule({
    super.key,
    required this.dataDirectory,
    required this.localDirectory,
    required this.getMessageTypeForPath,
    required this.typeRegistry,
    required this.registeredTypeNames,
    this.onFileSaved,
  });

  @override
  State<DataInspectorModule> createState() => _DataInspectorModuleState();
}

class _DataInspectorModuleState extends State<DataInspectorModule> {
  File? _selectedFile;
  String? _relativeSelectedPath;
  bool _isLocal = false;

  void _onFileSelected(File file, String relativePath, bool isLocal) {
    setState(() {
      _selectedFile = file;
      _relativeSelectedPath = relativePath;
      _isLocal = isLocal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Pane: File Tree
        SizedBox(
          width: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: double.infinity,
                child: Text(
                  'File Explorer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _FileTreeRoot(
                      label: 'Game Data',
                      directory: widget.dataDirectory,
                      onFileSelected: (file, path) =>
                          _onFileSelected(file, path, false),
                      selectedPath: !_isLocal ? _relativeSelectedPath : null,
                    ),
                    _FileTreeRoot(
                      label: 'Local Data (.local)',
                      directory: widget.localDirectory,
                      onFileSelected: (file, path) =>
                          _onFileSelected(file, path, true),
                      selectedPath: _isLocal ? _relativeSelectedPath : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Pane: Content
        Expanded(
          child: _selectedFile == null
              ? const Center(child: Text('Select a file to inspect'))
              : _FileDetailView(
                  key: ValueKey(_selectedFile!.path),
                  file: _selectedFile!,
                  relativePath: _relativeSelectedPath!,
                  getMessageTypeForPath: widget.getMessageTypeForPath,
                  typeRegistry: widget.typeRegistry,
                  registeredTypeNames: widget.registeredTypeNames,
                  onFileSaved: widget.onFileSaved,
                ),
        ),
      ],
    );
  }
}

class _FileTreeRoot extends StatefulWidget {
  final String label;
  final Directory directory;
  final void Function(File file, String relativePath) onFileSelected;
  final String? selectedPath;

  const _FileTreeRoot({
    required this.label,
    required this.directory,
    required this.onFileSelected,
    this.selectedPath,
  });

  @override
  State<_FileTreeRoot> createState() => _FileTreeRootState();
}

class _FileTreeRootState extends State<_FileTreeRoot> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: Icon(_expanded ? Icons.expand_more : Icons.chevron_right),
          title: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _DirectoryContent(
              directory: widget.directory,
              rootDirectory: widget.directory,
              onFileSelected: widget.onFileSelected,
              selectedPath: widget.selectedPath,
            ),
          ),
      ],
    );
  }
}

class _DirectoryContent extends StatelessWidget {
  final Directory directory;
  final Directory rootDirectory;
  final void Function(File file, String relativePath) onFileSelected;
  final String? selectedPath;

  const _DirectoryContent({
    required this.directory,
    required this.rootDirectory,
    required this.onFileSelected,
    this.selectedPath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: directory.existsSync() ? directory.list().toList() : Future.value([]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final entities = snapshot.data!;
        entities.sort((a, b) {
          if (a is Directory && b is! Directory) return -1;
          if (a is! Directory && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

        return Column(
          children: entities.map((entity) {
            final name = p.basename(entity.path);
            final relativePath = p.relative(
              entity.path,
              from: rootDirectory.path,
            );

            if (entity is Directory) {
              return _DirectoryNode(
                name: name,
                directory: entity,
                rootDirectory: rootDirectory,
                onFileSelected: onFileSelected,
                selectedPath: selectedPath,
              );
            } else if (entity is File) {
              final isSelected = selectedPath == relativePath;
              return ListTile(
                dense: true,
                selected: isSelected,
                leading: _getFileIcon(name),
                title: Text(name),
                onTap: () => onFileSelected(entity, relativePath),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  Icon _getFileIcon(String name) {
    final ext = p.extension(name).toLowerCase();
    if (ext == '.binpb') return const Icon(Icons.settings_suggest, size: 18);
    if (ext == '.json') return const Icon(Icons.code, size: 18);
    if (['.png', '.jpg', '.jpeg', '.gif'].contains(ext)) {
      return const Icon(Icons.image, size: 18);
    }
    return const Icon(Icons.description, size: 18);
  }
}

class _DirectoryNode extends StatefulWidget {
  final String name;
  final Directory directory;
  final Directory rootDirectory;
  final void Function(File file, String relativePath) onFileSelected;
  final String? selectedPath;

  const _DirectoryNode({
    required this.name,
    required this.directory,
    required this.rootDirectory,
    required this.onFileSelected,
    this.selectedPath,
  });

  @override
  State<_DirectoryNode> createState() => _DirectoryNodeState();
}

class _DirectoryNodeState extends State<_DirectoryNode> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _checkExpand();
  }

  @override
  void didUpdateWidget(_DirectoryNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkExpand();
  }

  void _checkExpand() {
    if (widget.selectedPath != null &&
        p.isWithin(
          widget.directory.path,
          p.join(widget.rootDirectory.path, widget.selectedPath),
        )) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: Icon(_expanded ? Icons.folder_open : Icons.folder),
          title: Text(widget.name),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _DirectoryContent(
              directory: widget.directory,
              rootDirectory: widget.rootDirectory,
              onFileSelected: widget.onFileSelected,
              selectedPath: widget.selectedPath,
            ),
          ),
      ],
    );
  }
}

class _FileDetailView extends StatefulWidget {
  final File file;
  final String relativePath;
  final GeneratedMessage? Function(String relativePath) getMessageTypeForPath;
  final TypeRegistry typeRegistry;
  final Iterable<String> registeredTypeNames;
  final Future<void> Function(File file)? onFileSaved;

  const _FileDetailView({
    super.key,
    required this.file,
    required this.relativePath,
    required this.getMessageTypeForPath,
    required this.typeRegistry,
    required this.registeredTypeNames,
    this.onFileSaved,
  });

  @override
  State<_FileDetailView> createState() => _FileDetailViewState();
}

class _FileDetailViewState extends State<_FileDetailView> {
  GeneratedMessage? _protoMessage;
  String? _textContent;
  bool _isLoading = true;
  String? _error;
  bool _manualTypeSelection = false;

  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _loadFile();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _protoMessage = null;
      _textContent = null;
    });

    try {
      final ext = p.extension(widget.file.path).toLowerCase();
      if (ext == '.binpb') {
        _protoMessage = widget.getMessageTypeForPath(
          widget.relativePath,
        );
        if (_protoMessage != null) {
          final bytes = await widget.file.readAsBytes();
          if (bytes.isNotEmpty) {
            _protoMessage!.mergeFromBuffer(bytes);
          }
        }
      } else if (_isTextFile(ext)) {
        _textContent = await widget.file.readAsString();
        _textController.text = _textContent!;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isTextFile(String ext) {
    return [
      '.json',
      '.txt',
      '.sc',
      '.dart',
      '.proto',
      '.yaml',
      '.md',
      '.xml',
      '.html',
      '.css',
    ].contains(ext);
  }

  bool _isImageFile(String ext) {
    return ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'].contains(ext);
  }

  Future<void> _saveText() async {
    try {
      await widget.file.writeAsString(_textController.text);
      if (widget.onFileSaved != null) {
        await widget.onFileSaved!(widget.file);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File saved successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error loading file: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadFile, child: const Text('Retry')),
          ],
        ),
      );
    }

    final ext = p.extension(widget.file.path).toLowerCase();

    if (ext == '.binpb') {
      if (_protoMessage == null || _manualTypeSelection) {
        return _buildProtoTypeSelector();
      }
      return _buildProtoEditor();
    }

    if (_textContent != null) {
      return _buildTextEditor();
    }

    if (_isImageFile(ext)) {
      return _buildImageViewer();
    }

    return _buildGenericViewer();
  }

  Widget _buildProtoEditor() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Type: ${_protoMessage!.info_.messageName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _manualTypeSelection = true),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Change Type'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ProtoMapEditor(
            message: _protoMessage!,
            typeRegistry: widget.typeRegistry,
            onSave: (message) async {
              try {
                await widget.file.writeAsBytes(message.writeToBuffer());
                if (widget.onFileSaved != null) {
                  await widget.onFileSaved!(widget.file);
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Protobuf saved successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save protobuf: $e')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProtoTypeSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Select Protobuf Message Type'),
          const SizedBox(height: 16),
          SizedBox(
            width: 400,
            height: 500,
            child: Card(
              child: ProtoMapTypeSelector(
                availableTypes: widget.registeredTypeNames.toList()..sort(),
                onCancel: () => setState(() => _manualTypeSelection = false),
                onSelected: (typeName) async {
                  final builderInfo = widget.typeRegistry.lookup(typeName);
                  final instance = builderInfo?.createEmptyInstance?.call();
                  if (instance != null) {
                    // Try to load existing data if possible
                    try {
                      final bytes = await widget.file.readAsBytes();
                      if (bytes.isNotEmpty) {
                        instance.mergeFromBuffer(bytes);
                      }
                    } catch (_) {}

                    setState(() {
                      _protoMessage = instance;
                      _manualTypeSelection = false;
                    });
                  }
                },
              ),
            ),
          ),
          if (_protoMessage != null)
            TextButton(
              onPressed: () => setState(() => _manualTypeSelection = false),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildTextEditor() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(p.basename(widget.file.path)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveText,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            p.basename(widget.file.path),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: InteractiveViewer(child: Image.file(widget.file))),
        ],
      ),
    );
  }

  Widget _buildGenericViewer() {
    final fileSize = widget.file.lengthSync();
    String sizeStr;
    if (fileSize < 1024) {
      sizeStr = '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      sizeStr = '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      sizeStr = '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            p.basename(widget.file.path),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('File size: $sizeStr'),
          const SizedBox(height: 16),
          const Text('No viewer available for this file type.'),
        ],
      ),
    );
  }
}
