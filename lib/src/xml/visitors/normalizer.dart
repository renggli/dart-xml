import '../enums/node_type.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import '../utils/functions.dart';
import 'visitor.dart';

extension XmlNormalizerExtension on XmlNode {
  /// Puts all child nodes into a "normalized" form, that is
  ///
  /// - no text node in the sub-tree is empty, and
  /// - there are no adjacent text nodes.
  ///
  /// Optionally, the following (possibly destructive) normalization operations
  /// can be performed. All operations can be either be performed selectively
  /// on nodes satisfying a predicate, or on all nodes:
  ///
  /// - If the predicate [collapseWhitespace] is `true`, consecutive whitespace
  ///   are replace with a single space-character.
  /// - If the predicate [normalizeNewline] is `true`, line endings are
  ///   combined according to https://www.w3.org/TR/xml11/#sec-line-ends.
  /// - If the predicate [trimWhitespace] is `true`, leading and trailing
  ///   whitespace are removed.
  void normalize({
    Predicate<XmlText>? collapseWhitespace,
    Predicate<XmlText>? normalizeNewline,
    Predicate<XmlText>? trimWhitespace,
    bool? collapseAllWhitespace,
    bool? normalizeAllNewline,
    bool? trimAllWhitespace,
  }) =>
      XmlNormalizer(
        collapseWhitespace:
            _toPredicate(collapseWhitespace, collapseAllWhitespace),
        normalizeNewline: _toPredicate(normalizeNewline, normalizeAllNewline),
        trimWhitespace: _toPredicate(trimWhitespace, trimAllWhitespace),
      ).visit(this);
}

Predicate<XmlText> _toPredicate(Predicate<XmlText>? predicate, bool? all) {
  assert(predicate == null || all == null,
      'Only specify the predicate or the boolean value, not both.');
  if (predicate != null) return predicate;
  if (all != null) return (node) => all;
  return (node) => false;
}

/// Normalizes a node tree in-place.
class XmlNormalizer with XmlVisitor {
  const XmlNormalizer({
    required this.collapseWhitespace,
    required this.normalizeNewline,
    required this.trimWhitespace,
  });

  final Predicate<XmlText> collapseWhitespace;
  final Predicate<XmlText> normalizeNewline;
  final Predicate<XmlText> trimWhitespace;

  @override
  void visitDocument(XmlDocument node) => _normalize(node.children);

  @override
  void visitDocumentFragment(XmlDocumentFragment node) =>
      _normalize(node.children);

  @override
  void visitElement(XmlElement node) => _normalize(node.children);

  @override
  void visitText(XmlText node) {
    if (trimWhitespace(node)) {
      node.text = node.text.trim();
    }
    if (collapseWhitespace(node)) {
      node.text = node.text.replaceAll(_whitespace, ' ');
    }
    if (normalizeNewline(node)) {
      node.text = node.text.replaceAll(_newline, '\n');
    }
  }

  void _normalize(List<XmlNode> children) {
    _mergeAdjacent(children);
    children.forEach(visit);
    _removeEmpty(children);
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

final _whitespace = RegExp(r'\s+');
final _newline = RegExp(r'\r\n|\r\u0085|\r|\u0085|\u2028');
