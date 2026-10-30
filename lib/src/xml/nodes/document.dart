import '../../xml_events/converters/node_decoder.dart';
import '../../xml_events/iterable.dart';
import '../builder/builder.dart';
import '../entities/entity_mapping.dart';
import '../enums/node_type.dart';
import '../exceptions/parser_exception.dart';
import '../exceptions/tag_exception.dart';
import '../extensions/descendants.dart';
import '../mixins/has_children.dart';
import '../visitors/visitor.dart';
import 'declaration.dart';
import 'doctype.dart';
import 'element.dart';
import 'node.dart';

/// XML document node.
class XmlDocument extends XmlNode with XmlHasChildren<XmlNode> {
  /// Parses an [XmlDocument] from the given [input] string.
  ///
  /// Throws an [XmlParserException] or [XmlTagException] if the input is invalid.
  ///
  /// For example, the following code prints `Hello World`:
  ///
  /// ```dart
  /// final document = XmlDocument.parse('<?xml?><root message="Hello World" />');
  /// print(document.rootElement.getAttribute('message'));
  /// ```
  ///
  /// Note: It is the responsibility of the caller to provide a standard Dart
  /// [String] using the default UTF-16 encoding.
  factory parse(String input, {XmlEntityMapping? entityMapping}) {
    final sanitizedInput = input.startsWith('\uFEFF')
        ? input.substring(1)
        : input;
    final events = XmlEventIterable(
      sanitizedInput,
      entityMapping: entityMapping,
      validateDocument: true,
      validateNesting: true,
      withNamespace: true,
    );
    return XmlDocument(const XmlNodeDecoder().convertIterable(events));
  }

  /// Builds an [XmlDocument] using a [callback] with an [XmlBuilder].
  ///
  /// For example, the following code creates a document with a single root element
  /// and textual contents:
  ///
  /// ```dart
  /// final document = XmlDocument.build((builder) {
  ///   builder.declaration();
  ///   builder.element('root', nest: 'Hello World');
  /// });
  /// print(document.toXmlString());
  /// ```
  factory build(void Function(XmlBuilder builder) callback) {
    final builder = XmlBuilder();
    callback(builder);
    return builder.buildDocument();
  }

  /// Creates a document node with [children].
  new([Iterable<XmlNode> children = const []]) {
    this.children.initialize(this, childrenNodeTypes);
    this.children.addAll(children);
  }

  /// The [XmlDeclaration] element, or `null` if not defined.
  ///
  /// For example the following code prints `<?xml version="1.0"?>`:
  ///
  /// ```dart
  /// const xml = '<?xml version="1.0"?>'
  ///             '<shelf></shelf>';
  /// print(XmlDocument.parse(xml).declaration);
  /// ```
  XmlDeclaration? get declaration {
    for (final node in children) {
      if (node is XmlDeclaration) {
        return node;
      }
    }
    return null;
  }

  /// The [XmlDoctype] element, or `null` if not defined.
  ///
  /// For example, the following code prints `<!DOCTYPE html>`:
  ///
  /// ```dart
  /// const xml = '<!DOCTYPE html>'
  ///             '<html><body></body></html>';
  /// print(XmlDocument.parse(xml).doctypeElement);
  /// ```
  XmlDoctype? get doctypeElement {
    for (final node in children) {
      if (node is XmlDoctype) {
        return node;
      }
    }
    return null;
  }

  /// The root [XmlElement] of the document.
  ///
  /// Throws a [StateError] if the document has no such element.
  ///
  /// For example, the following code prints `<books />`:
  ///
  /// ```dart
  /// const xml = '<?xml version="1.0"?>'
  ///             '<books />';
  /// print(XmlDocument.parse(xml).rootElement);
  /// ```
  XmlElement get rootElement {
    for (final node in children) {
      if (node is XmlElement) {
        return node;
      }
    }
    throw StateError('Empty XML document');
  }

  /// Returns the first [XmlElement] with an ID matching [id], or `null` if not found.
  ///
  /// Checks attributes named `id`, `xml:id`, or attributes declared with type `ID`
  /// in the document type declaration's internal subset.
  XmlElement? getElementById(String id) {
    final dtdIds = <String, Set<String>>{};
    final subset = doctypeElement?.internalSubset;
    if (subset != null) {
      final regExp = RegExp(
        r'<!ATTLIST\s+([^\s>]+)\s+([^\s>]+)\s+ID\b',
        caseSensitive: false,
      );
      for (final m in regExp.allMatches(subset)) {
        dtdIds.putIfAbsent(m.group(1)!, () => {}).add(m.group(2)!);
      }
    }
    for (final element in descendantElements) {
      for (final attribute in element.attributes) {
        final qName = attribute.name.qualified;
        if (qName == 'id' ||
            qName == 'xml:id' ||
            (dtdIds[element.name.local]?.contains(attribute.name.local) ??
                false)) {
          if (attribute.value == id) {
            return element;
          }
        }
      }
    }
    return null;
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT;

  @override
  XmlDocument copy() => XmlDocument(children.map((each) => each.copy()));

  @override
  void accept(XmlVisitor visitor) => visitor.visitDocument(this);
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
