library xml.nodes.data;

import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/parent.dart';
import 'package:xml/src/xml/utils/owned.dart';

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
