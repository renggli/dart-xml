import '../exceptions/type_exception.dart';
import '../nodes/cdata.dart';
import '../nodes/document_fragment.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import 'descendants.dart';
import 'mutator.dart';

extension XmlStringExtension on XmlNode {
  /// Return the concatenated text value its descendants.
  String get innerText => descendants
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.value)
      .join();

  /// Replaces the children of this node with text contents.
  set innerText(String value) {
    XmlNodeTypeException.checkHasChildren(this);
    children.clear();
    if (value.isNotEmpty) {
      children.add(XmlText(value));
    }
  }

  /// Return the markup representing this node and all its child nodes.
  String get outerXml => toXmlString();

  /// Replaces the markup representing this node and all its child nodes.
  set outerXml(String value) => replace(XmlDocumentFragment.parse(value));

  /// Return the markup representing the child nodes of this node.
  String get innerXml => children.map((node) => node.toXmlString()).join();

  /// Replaces the markup representing the child nodes of this node.
  set innerXml(String value) {
    XmlNodeTypeException.checkHasChildren(this);
    children.clear();
    if (value.isNotEmpty) {
      children.add(XmlDocumentFragment.parse(value));
    }
  }
}
