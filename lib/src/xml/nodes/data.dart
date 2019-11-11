library xml.nodes.data;

import '../utils/owned.dart';
import 'node.dart';
import 'parent.dart';

/// Abstract XML data node.
abstract class XmlData extends XmlNode with XmlOwnedMixin<XmlParent> {
  String _text;

  /// Return the textual value of this node.
  @override
  String get text => _text;

  /// Update the textual value of this node.
  set text(String text) {
    ArgumentError.checkNotNull(text, 'text');
    _text = text;
  }

  /// Create a data section with `text`.
  XmlData(String text) {
    this.text = text;
  }
}
