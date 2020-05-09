library xml.nodes.document;

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../mixins/has_children.dart';
import '../parse.dart';
import '../utils/exceptions.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'declaration.dart';
import 'doctype.dart';
import 'element.dart';
import 'node.dart';

/// XML document node.
class XmlDocument extends XmlNode with XmlHasChildren {
  /// Return an [XmlDocument] for the given [input] string, or throws an
  /// [XmlParserException] if the input is invalid.
  ///
  /// For example, the following code prints `Hello World`:
  ///
  ///    final document = new XmlDocument.parse('<?xml?><root message="Hello World" />');
  ///    print(document.rootElement.getAttribute('message'));
  ///
  /// Note: It is the responsibility of the caller to provide a standard Dart
  /// [String] using the default UTF-16 encoding.
  factory XmlDocument.parse(String input,
          {XmlEntityMapping entityMapping =
              const XmlDefaultEntityMapping.xml()}) =>
      parse(input, entityMapping: entityMapping);

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
