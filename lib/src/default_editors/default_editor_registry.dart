import 'package:protobuf_message_editor/protobuf_message_editor.dart';
import 'package:protobuf_message_editor/src/default_editors/well_known/bool_value_editor.dart';

final defaultEditorRegistry = CustomEditorRegistry.fromIterable(
  customMessageEditors: [BoolValueEditor()],
);
