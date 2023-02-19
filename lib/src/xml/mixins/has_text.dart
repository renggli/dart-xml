import '../exceptions/type_exception.dart';
import '../navigation/descendants.dart';
import '../nodes/cdata.dart';
import '../nodes/data.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import 'has_children.dart';

/// Mixin for nodes with text.
mixin XmlHasText implements XmlChildrenBase {
  /// Returns the value of the node, or `null`.
  ///
  /// The returned value depends on the type of the node:
  /// - attributes return their attribute value;
  /// - text, CDATA, and comment nodes return their textual content; and
  /// - processing and declaration nodes return their contents.
  /// All other nodes return `null`.
  String? get value => null;

  /// Returns the concatenated text of this node or its descendants, for
  /// [XmlData] nodes return the textual value of the node.
  @Deprecated('Use [value] to access the textual content of this node, or '
      '[innerText] to access the textual content of its descendants.')
  String get text => innerText;

  /// Return the concatenated text value its descendants.
  String get innerText => XmlDescendantsIterable(this as XmlNode)
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.value)
      .join();

  /// Replaces the children of this node with text contents.
  set innerText(String value) {
    XmlNodeTypeException.checkHasChildren(this as XmlNode);
    children.clear();
    if (value.isNotEmpty) {
      children.add(XmlText(value));
    }
  }
}
