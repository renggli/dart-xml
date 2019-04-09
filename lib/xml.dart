/// Dart XML is a lightweight library for parsing, traversing, querying and
/// building XML documents.
library xml;

import 'package:petitparser/petitparser.dart' show Parser, Token;
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/parser.dart';
import 'package:xml/src/xml/utils/exceptions.dart';

export 'package:xml/src/xml/builder.dart' show XmlBuilder;
export 'package:xml/src/xml/grammar.dart' show XmlGrammarDefinition;
export 'package:xml/src/xml/nodes/attribute.dart' show XmlAttribute;
export 'package:xml/src/xml/nodes/cdata.dart' show XmlCDATA;
export 'package:xml/src/xml/nodes/comment.dart' show XmlComment;
export 'package:xml/src/xml/nodes/data.dart' show XmlData;
export 'package:xml/src/xml/nodes/doctype.dart' show XmlDoctype;
export 'package:xml/src/xml/nodes/document.dart' show XmlDocument;
export 'package:xml/src/xml/nodes/document_fragment.dart'
    show XmlDocumentFragment;
export 'package:xml/src/xml/nodes/element.dart' show XmlElement;
export 'package:xml/src/xml/nodes/node.dart' show XmlNode;
export 'package:xml/src/xml/nodes/parent.dart' show XmlParent;
export 'package:xml/src/xml/nodes/processing.dart' show XmlProcessing;
export 'package:xml/src/xml/nodes/text.dart' show XmlText;
export 'package:xml/src/xml/parser.dart' show XmlParserDefinition;
export 'package:xml/src/xml/production.dart' show XmlProductionDefinition;
export 'package:xml/src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'package:xml/src/xml/utils/entities.dart'
    show
        encodeXmlText,
        encodeXmlAttributeValue,
        encodeXmlAttributeValueWithQuotes;
export 'package:xml/src/xml/utils/exceptions.dart'
    show
        XmlException,
        XmlParserException,
        XmlNodeTypeException,
        XmlParentException,
        XmlTagException;
export 'package:xml/src/xml/utils/name.dart' show XmlName;
export 'package:xml/src/xml/utils/named.dart' show XmlNamed;
export 'package:xml/src/xml/utils/node_type.dart' show XmlNodeType;
export 'package:xml/src/xml/utils/owned.dart' show XmlOwned;
export 'package:xml/src/xml/utils/token.dart' show XmlToken;
export 'package:xml/src/xml/utils/writable.dart' show XmlWritable;
export 'package:xml/src/xml/visitors/pretty_writer.dart' show XmlPrettyWriter;
export 'package:xml/src/xml/visitors/transformer.dart' show XmlTransformer;
export 'package:xml/src/xml/visitors/visitable.dart' show XmlVisitable;
export 'package:xml/src/xml/visitors/visitor.dart' show XmlVisitor;
export 'package:xml/src/xml/visitors/writer.dart' show XmlWriter;

final Parser _parser = XmlParserDefinition().build();

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
XmlDocument parse(String input) {
  final result = _parser.parse(input);
  if (result.isFailure) {
    final position = Token.lineAndColumnOf(input, result.position);
    throw XmlParserException(result.message, position[0], position[1]);
  }
  return result.value;
}
