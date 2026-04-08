import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';

@Deprecated('Use ProtobufJsonEditor instead')
class ProtoNavigationNode {
  final int depth;
  final GeneratedMessage? parent;
  final FieldInfo? fieldInfo;
  final GeneratedMessage message;

  ProtoNavigationNode({
    required this.depth,
    required this.parent,
    this.fieldInfo,
    required this.message,
  });
}

@Deprecated('Use ProtobufJsonEditor instead')
class ProtoNavigationState extends ChangeNotifier {
  late final ProtoNavigationNode root;
  late final List<ProtoNavigationNode> _stack;

  UnmodifiableListView<ProtoNavigationNode> getStack() =>
      UnmodifiableListView(_stack);

  ProtoNavigationState({required this.root}) {
    _stack = [root];
  }

  ProtoNavigationState.fromRootMessage(GeneratedMessage message) {
    root = ProtoNavigationNode(depth: 0, parent: null, message: message);
    _stack = [root];
  }

  ProtoNavigationNode getCurrent() => _stack.last;

  ProtoNavigationNode? getParent() =>
      _stack.length > 1 ? _stack[_stack.length - 2] : null;

  void push(GeneratedMessage message, {FieldInfo? fieldInfo}) {
    final current = getCurrent();
    _stack.add(
      ProtoNavigationNode(
        depth: current.depth + 1,
        parent: current.message,
        fieldInfo: fieldInfo,
        message: message,
      ),
    );
    notifyListeners();
  }

  void replace(GeneratedMessage message, {FieldInfo? fieldInfo}) {
    if (_stack.length < 2) throw Exception('Cannot replace root node');

    final current = _stack.removeLast();
    _stack.add(
      ProtoNavigationNode(
        depth: current.depth,
        parent: current.parent,
        fieldInfo: fieldInfo ?? current.fieldInfo,
        message: message,
      ),
    );
    notifyListeners();
  }

  void popUntilDepth(int depth) {
    while (_stack.length > 1 && _stack.last.depth > depth) {
      _stack.removeLast();
    }
    notifyListeners();
  }
}
