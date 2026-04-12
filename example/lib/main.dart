import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart';
import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor_example/generated/example_message.pb.dart';

void main() {
  runApp(ProtobufMessageEditorExampleApp());
}

final exampleRegistry = AnyEditorRegistry([
  AnotherExampleSubmessage.getDefault(),
  ExampleSubmessage.getDefault(),
]);

final exampleCustomEditors = CustomEditorRegistry.fromIterable(
  customMessageEditors: [AnyEditorBuilder(registry: exampleRegistry)],
);

class ProtobufMessageEditorExampleApp extends StatefulWidget {
  const ProtobufMessageEditorExampleApp({super.key});

  @override
  State<StatefulWidget> createState() =>
      _ProtobufMessageEditorExampleAppState();
}

class _ProtobufMessageEditorExampleAppState
    extends State<ProtobufMessageEditorExampleApp>
    with TickerProviderStateMixin {
  late GeneratedMessage _rootMessage;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _rootMessage =
        ExampleMessage(
            exampleBoolValue: BoolValue(value: true),
            exampleStringField: "testasdf",
          )
          ..exampleRepeatedAny.addAll([
            Any.pack(ExampleSubmessage()..someString = 'Nested Any 1'),
            Any.pack(
              AnotherExampleSubmessage()..anotherString = 'Nested Any 2',
            ),
          ]);

    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
  }

  void _showMessageJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message JSON'),
        content: SingleChildScrollView(
          child: Text(
            jsonEncode(
              _rootMessage.toProto3Json(typeRegistry: exampleRegistry),
            ),
          ),
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
              Tab(text: 'JSON Editor (New)'),
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
                customEditorProvider: exampleCustomEditors,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: ProtoMessageEditor(
                  message: _rootMessage,
                  customEditorProvider: exampleCustomEditors,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: ProtoMapEditor(
                message: _rootMessage,
                typeRegistry: exampleRegistry,
                onSave: (msg) {
                  setState(() {
                    _rootMessage = msg;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
