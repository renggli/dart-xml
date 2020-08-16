import '../mixins/has_parent.dart';
import 'node.dart';

/// Abstract XML data node.
abstract class XmlData extends XmlNode with XmlHasParent<XmlNode> {
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
