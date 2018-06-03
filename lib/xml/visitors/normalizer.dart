library xml.visitors.normalizer;

import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/utils/node_type.dart';
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// Normalizes a node tree in-place.
class XmlNormalizer extends XmlVisitor {
  const XmlNormalizer();

  @override
  void visitDocument(XmlDocument node) => _normalize(node.children);

  @override
  void visitDocumentFragment(XmlDocumentFragment node) =>
      _normalize(node.children);

  @override
  void visitElement(XmlElement node) => _normalize(node.children);

  void _normalize(List<XmlNode> children) {
    _removeEmpty(children);
    _mergeAdjacent(children);
    children.forEach(visit);
  }

  void _removeEmpty(List<XmlNode> children) {
    for (var i = 0; i < children.length;) {
      XmlNode node = children[i];
      if (node.nodeType == XmlNodeType.TEXT && node.text.isEmpty) {
        children.removeAt(i);
      } else {
        i++;
      }
    }
  }

  void _mergeAdjacent(List<XmlNode> children) {
    XmlText previousText;
    for (var i = 0; i < children.length;) {
      XmlNode node = children[i];
      if (node.nodeType == XmlNodeType.TEXT) {
        if (previousText == null) {
          previousText = node;
          i++;
        } else {
          previousText.text += node.text;
          children.removeAt(i);
        }
      } else {
        previousText = null;
        i++;
      }
    }
  }
}
