import '../../../xml_events.dart' show XmlNodeDecoder, XmlNodeType, parseEvents;
import '../builder.dart';
import '../entities/entity_mapping.dart';
import '../exceptions/parser_exception.dart';
import '../mixins/has_children.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML document fragment node.
class XmlDocumentFragment extends XmlNode with XmlHasChildren<XmlNode> {
  /// Return an [XmlDocumentFragment] for the given [input] string, or throws an
  /// [XmlParserException] if the input is invalid.
  ///
  /// Note: It is the responsibility of the caller to provide a standard Dart
  /// [String] using the default UTF-16 encoding.
  factory XmlDocumentFragment.parse(
    String input, {
    XmlEntityMapping? entityMapping,
  }) {
    final events = parseEvents(
      input,
      entityMapping: entityMapping,
      validateNesting: true,
    );
    return XmlDocumentFragment(const XmlNodeDecoder().convertIterable(events));
  }

  /// Returns an [XmlDocumentFragment] built from calling the provided `callback`
  /// with an [XmlBuilder].
  factory XmlDocumentFragment.build(
    void Function(XmlBuilder builder) callback,
  ) {
    final builder = XmlBuilder();
    callback(builder);
    return builder.buildFragment();
  }

  /// Create a document fragment node with `children`.
  XmlDocumentFragment([Iterable<XmlNode> children = const []]) {
    this.children.initialize(this, childrenNodeTypes);
    this.children.addAll(children);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_FRAGMENT;

  @override
  XmlDocumentFragment copy() =>
      XmlDocumentFragment(children.map((each) => each.copy()));

  @override
  void accept(XmlVisitor visitor) => visitor.visitDocumentFragment(this);
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
