library xml.visitors.normalizer;

import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/nodes/document_fragment.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/nodes/text.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// Normalizes a node tree in-place.
class XmlNormalizer with XmlVisitor {
  static final XmlNormalizer defaultInstance = XmlNormalizer();

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
      final node = children[i];
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
      final node = children[i];
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
