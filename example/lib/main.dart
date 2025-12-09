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
  late final ProtoNavigationState _navigationState;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _rootMessage = ExampleMessage();
    _navigationState = ProtoNavigationState.fromRootMessage(_rootMessage);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dual Panel Usage Example',
      home: Scaffold(
        appBar: AppBar(
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
              child: ProtoDualPanelMessageEditor(
                navigationState: _navigationState,
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
