## 0.0.5

- Add `AnyEditor` for editing `google.protobuf.Any` messages
- Add `AnyEditorRegistry` for managing available message types for `AnyEditor`

Breaking changes:

- `SubmessageBuilder` typedef has been updated to include `parentMessage` and `onRebuildRequested` parameters.
- Add copy-to-edit button for frozen submessages

## 0.0.4

Added support for `google.protobuf.BoolValue` via a default custom editor registry

## 0.0.3

Added missing exports relevant to custom field editors

## 0.0.2

`ProtoDualPanelMessageEditor` can now accept a root message instead of a `ProtoNavigationState`.
When used this way, the widget will create an internally managed `ProtoNavigationState`.

## 0.0.1

Initial release
