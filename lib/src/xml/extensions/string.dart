import '../exceptions/type_exception.dart';
import '../nodes/cdata.dart';
import '../nodes/document_fragment.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import 'descendants.dart';
import 'mutator.dart';

extension XmlStringExtension on XmlNode {
  /// The concatenated text value of this node and its descendants.
  ///
  /// Setting this property replaces the children of this node with the provided
  /// text content.
  String get innerText => descendants
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.value)
      .join();

  set innerText(String value) {
    XmlNodeTypeException.checkHasChildren(this);
    children.clear();
    if (value.isNotEmpty) {
      children.add(XmlText(value));
    }
  }

  /// The markup representing this node and all its child nodes.
  ///
  /// Setting this property replaces this node with the parsed XML markup.
  String get outerXml => toXmlString();

  set outerXml(String value) => replace(XmlDocumentFragment.parse(value));

  /// The markup representing the child nodes of this node.
  ///
  /// Setting this property replaces the child nodes with the parsed XML markup.
  String get innerXml => children.map((node) => node.toXmlString()).join();

  set innerXml(String value) {
    XmlNodeTypeException.checkHasChildren(this);
    children.clear();
    if (value.isNotEmpty) {
      children.add(XmlDocumentFragment.parse(value));
    }
  }
}
