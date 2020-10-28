import 'package:petitparser/petitparser.dart';

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../mixins/has_children.dart';
import '../parser.dart';
import '../utils/cache.dart';
import '../utils/exceptions.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML document fragment node.
class XmlDocumentFragment extends XmlNode with XmlHasChildren {
  /// Return an [XmlDocumentFragment] for the given [input] string, or throws an
  /// [XmlParserException] if the input is invalid.
  ///
  /// Note: It is the responsibility of the caller to provide a standard Dart
  /// [String] using the default UTF-16 encoding.
  factory XmlDocumentFragment.parse(String input,
      {XmlEntityMapping? entityMapping}) {
    final mapping = entityMapping ?? defaultEntityMapping;
    final parser = documentFragmentParserCache[mapping];
    final result = parser.parse(input);
    if (result.isFailure) {
      final lineAndColumn =
          Token.lineAndColumnOf(result.buffer, result.position);
      throw XmlParserException(result.message,
          buffer: result.buffer,
          position: result.position,
          line: lineAndColumn[0],
          column: lineAndColumn[1]);
    }
    return result.value;
  }

  /// Create a document fragment node with `children`.
  XmlDocumentFragment([Iterable<XmlNode> childrenIterable = const []]) {
    children.initialize(this, childrenNodeTypes);
    children.addAll(childrenIterable);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_FRAGMENT;

  @override
  XmlDocumentFragment copy() =>
      XmlDocumentFragment(children.map((each) => each.copy()));

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDocumentFragment(this);
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

/// Internal cache of parsers for a specific entity mapping.
final XmlCache<XmlEntityMapping, Parser> documentFragmentParserCache =
    XmlCache((entityMapping) {
  final definition = XmlParserDefinition(entityMapping);
  return definition.build(start: definition.documentFragment).end();
}, 5);
