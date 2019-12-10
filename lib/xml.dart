/// Dart XML is a lightweight library for parsing, traversing, querying and
/// building XML documents.
library xml;

import 'package:petitparser/petitparser.dart' show Parser, Token;

import 'src/xml/entities/default_mapping.dart';
import 'src/xml/entities/entity_mapping.dart';
import 'src/xml/nodes/document.dart';
import 'src/xml/parser.dart';
import 'src/xml/utils/cache.dart';
import 'src/xml/utils/exceptions.dart';

export 'src/xml/builder.dart' show XmlBuilder;
export 'src/xml/entities/default_mapping.dart' show XmlDefaultEntityMapping;
export 'src/xml/entities/entity_mapping.dart' show XmlEntityMapping;
export 'src/xml/entities/null_mapping.dart' show XmlNullEntityMapping;
export 'src/xml/grammar.dart' show XmlGrammarDefinition;
export 'src/xml/nodes/attribute.dart' show XmlAttribute;
export 'src/xml/nodes/cdata.dart' show XmlCDATA;
export 'src/xml/nodes/comment.dart' show XmlComment;
export 'src/xml/nodes/data.dart' show XmlData;
export 'src/xml/nodes/doctype.dart' show XmlDoctype;
export 'src/xml/nodes/document.dart' show XmlDocument;
export 'src/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
export 'src/xml/nodes/element.dart' show XmlElement;
export 'src/xml/nodes/node.dart' show XmlNode;
export 'src/xml/nodes/parent.dart' show XmlParent;
export 'src/xml/nodes/processing.dart' show XmlProcessing;
export 'src/xml/nodes/text.dart' show XmlText;
export 'src/xml/parser.dart' show XmlParserDefinition;
export 'src/xml/production.dart' show XmlProductionDefinition;
export 'src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'src/xml/utils/entities.dart'
    show
        // ignore: deprecated_member_use_from_same_package
        encodeXmlText,
        // ignore: deprecated_member_use_from_same_package
        encodeXmlAttributeValue,
        // ignore: deprecated_member_use_from_same_package
        encodeXmlAttributeValueWithQuotes;
export 'src/xml/utils/exceptions.dart'
    show
        XmlException,
        XmlParserException,
        XmlNodeTypeException,
        XmlParentException,
        XmlTagException;
export 'src/xml/utils/name.dart' show XmlName;
export 'src/xml/utils/named.dart' show XmlNamed;
export 'src/xml/utils/node_type.dart' show XmlNodeType;
export 'src/xml/utils/owned.dart' show XmlOwned;
export 'src/xml/utils/token.dart' show XmlToken;
export 'src/xml/utils/writable.dart' show XmlWritable;
export 'src/xml/visitors/pretty_writer.dart' show XmlPrettyWriter;
export 'src/xml/visitors/transformer.dart' show XmlTransformer;
export 'src/xml/visitors/visitable.dart' show XmlVisitable;
export 'src/xml/visitors/visitor.dart' show XmlVisitor;
export 'src/xml/visitors/writer.dart' show XmlWriter;

/// Cache of parsers for a specific entity mapping.
final XmlCache<XmlEntityMapping, Parser> _parserCache =
    XmlCache((entityMapping) => XmlParserDefinition(entityMapping).build(), 5);

/// Return an [XmlDocument] for the given [input] string, or throws an
/// [XmlParserException] if the input is invalid.
///
/// For example, the following code prints `Hello World`:
///
///    final document = parse('<?xml?><root message="Hello World" />');
///    print(document.rootElement.getAttribute('message'));
///
/// Note: It is the responsibility of the caller to provide a standard Dart
/// [String] using the default UTF-16 encoding.
XmlDocument parse(String input,
    {XmlEntityMapping entityMapping = const XmlDefaultEntityMapping.xml()}) {
  final result = _parserCache[entityMapping].parse(input);
  if (result.isFailure) {
    final lineAndColumn = Token.lineAndColumnOf(result.buffer, result.position);
    throw XmlParserException(result.message,
        buffer: result.buffer,
        position: result.position,
        line: lineAndColumn[0],
        column: lineAndColumn[1]);
  }
  return result.value;
}
