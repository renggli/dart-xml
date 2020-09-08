import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import '../utils/node_type.dart';
import 'visitor.dart';

extension XmlNormalizerExtension on XmlNode {
  /// Puts all child nodes into a "normalized" form, that is no text nodes in
  /// the sub-tree are empty and there are no adjacent text nodes.
  void normalize() => XmlNormalizer.defaultInstance.visit(this);
}

/// Normalizes a node tree in-place.
class XmlNormalizer with XmlVisitor {
  static const XmlNormalizer defaultInstance = XmlNormalizer();

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
      final node = children[i];
      if (node.nodeType == XmlNodeType.TEXT && node.text.isEmpty) {
        children.removeAt(i);
      } else {
        i++;
      }
    }
  }

  void _mergeAdjacent(List<XmlNode> children) {
    XmlText? previousText;
    for (var i = 0; i < children.length;) {
      final node = children[i];
      if (node is XmlText) {
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
