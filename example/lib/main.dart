import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor_example/generated/example_message.pb.dart';

void main() {
  runApp(ProtobufMessageEditorExampleApp());
}

class ProtobufMessageEditorExampleApp extends StatefulWidget {
  const ProtobufMessageEditorExampleApp({super.key});

  @override
  State<StatefulWidget> createState() =>
      _ProtobufMessageEditorExampleAppState();
}

class _ProtobufMessageEditorExampleAppState
    extends State<ProtobufMessageEditorExampleApp>
    with TickerProviderStateMixin {
  late final GeneratedMessage _rootMessage;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _rootMessage = ExampleMessage();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  void _showMessageJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message JSON'),
        content: SingleChildScrollView(
          child: Text(jsonEncode(_rootMessage.toProto3Json())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dual Panel Usage Example',
      home: Scaffold(
        appBar: AppBar(
          actions: [
            Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => _showMessageJson(context),
                  child: Text('Show JSON'),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Dual Panel Editor'),
              Tab(text: 'Plain Editor'),
            ],
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: ProtoDualPanelMessageEditor.withRootMessage(
                rootMessage: _rootMessage,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: ProtoMessageEditor(message: _rootMessage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
