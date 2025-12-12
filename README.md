<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

A general protobuf message (`GeneratedMessage`) editor. Note that this only
works with material apps as it relies on material widgets.

## Features

Given a `GeneratedMessage` instance, `ProtoMessageEditor` and
`ProtoDualPanelMessageEditor` can be used to edit the message. Do note that
this still requires the protobuf definition to be present and the dart code
to be generated.

## Getting started

Install the package:

```
flutter pub add protobuf_message_editor
```

## Usage

There are two main widgets provided by this package:

### ProtoMessageEditor

Simple editor with expansion tiles for submessages:

```dart
Widget build(context) {
  final message = YourGeneratedMessage();

  return SingleChildScrollView(
    child: ProtoMessageEditor(message: message),
  );
}
```

### ProtoDualPanelMessageEditor

Dual panel editor with navigation support for nested messages:

```dart
late final GeneratedMessage _rootMessage;
late final ProtoNavigationState _navigationState;

@override
initState() {
  super.initState();
  _rootMessage = YourGeneratedMessage();
  _navigationState = ProtoNavigationState.fromRootMessage(_rootMessage);
}

@override
dispose() {
  _navigationState.dispose();

  super.dispose();
}

Widget build(context) {
  // With a manually created navigation state
  return ProtoDualPanelMessageEditor(
    navigationState: _navigationState,
  );

  // Or with a root message
  // The widget will create an internally managed navigation state, and dispose
  // of it when the widget is disposed.
  return ProtoDualPanelMessageEditor.withRootMessage(
    rootMessage: _rootMessage,
  );
}
```

See the `/example` folder for a complete working example with both editors.

## Additional information

This was meant to be a quick and dirty internal tooling solution for one of
my projects, but ended up needing this for other projects as well. It's
probably quite buggy and not well-tested, doesn't have any real documentation
outside of the simple examples, and is definitely not production ready.
