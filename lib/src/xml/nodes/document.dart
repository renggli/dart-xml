library xml.nodes.document;

import '../mixins/has_children.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'declaration.dart';
import 'doctype.dart';
import 'element.dart';
import 'node.dart';

/// XML document node.
class XmlDocument extends XmlNode with XmlHasChildren {
  /// Create a document node with `children`.
  XmlDocument([Iterable<XmlNode> childrenIterable = const []]) {
    children.initialize(this, childrenNodeTypes);
    children.addAll(childrenIterable);
  }

  /// Return the [XmlDeclaration] element, or `null` if not defined.
  ///
  /// For example the following code prints `<?xml version="1.0">`:
  ///
  ///    var xml = '<?xml version="1.0">'
  ///              '<shelf></shelf>';
  ///    print(parse(xml).doctypeElement);
  ///
  XmlDeclaration get declaration =>
      children.firstWhere((node) => node is XmlDeclaration, orElse: () => null);

  /// Return the [XmlDoctype] element, or `null` if not defined.
  ///
  /// For example, the following code prints `<!DOCTYPE html>`:
  ///
  ///    var xml = '<!DOCTYPE html>'
  ///              '<html><body></body></html>';
  ///    print(parse(xml).doctypeElement);
  ///
  XmlDoctype get doctypeElement =>
      children.firstWhere((node) => node is XmlDoctype, orElse: () => null);

  /// Return the root [XmlElement] of the document, or throw a [StateError] if
  /// the document has no such element.
  ///
  /// For example, the following code prints `<books />`:
  ///
  ///     var xml = '<?xml version="1.0"?>'
  ///               '<books />';
  ///     print(parse(xml).rootElement);
  ///
  XmlElement get rootElement =>
      children.firstWhere((node) => node is XmlElement,
          orElse: () => throw StateError('Empty XML document'));

  @override
  String get text => null;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDocument(this);
}

/// Supported child node types.
const Set<XmlNodeType> childrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.DECLARATION,
  XmlNodeType.DOCUMENT_TYPE,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};
