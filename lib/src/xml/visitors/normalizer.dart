library xml.visitors.normalizer;

import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import '../utils/node_type.dart';
import 'visitor.dart';

/// Normalizes a node tree in-place.
class XmlNormalizer extends XmlVisitor {
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