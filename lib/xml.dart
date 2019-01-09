/// Dart XML is a lightweight library for parsing, traversing, querying and
/// building XML documents.
library xml;

import 'package:petitparser/petitparser.dart' show Parser, Token;

import 'src/xml/nodes/document.dart';
import 'src/xml/parser.dart';
import 'src/xml/utils/exceptions.dart';

export 'src/xml/builder.dart' show XmlBuilder;
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
export 'src/xml/reader.dart' show XmlReader, XmlPushReader;
export 'src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'src/xml/utils/exceptions.dart'
    show
        XmlException,
        XmlParserException,
        XmlNodeTypeException,
        XmlParentException;
export 'src/xml/utils/name.dart' show XmlName;
export 'src/xml/utils/named.dart' show XmlNamed;
export 'src/xml/utils/node_type.dart' show XmlNodeType, XmlPushReaderNodeType;
export 'src/xml/utils/owned.dart' show XmlOwned;
export 'src/xml/utils/writable.dart' show XmlWritable;
export 'src/xml/visitors/transformer.dart' show XmlTransformer;
export 'src/xml/visitors/visitable.dart' show XmlVisitable;
export 'src/xml/visitors/visitor.dart' show XmlVisitor;

final Parser _parser = XmlParserDefinition().build();

/// Return an [XmlDocument] for the given `input` string, or throws an
/// [XmlParserException] if the input is invalid.
XmlDocument parse(String input) {
  final result = _parser.parse(input);
  if (result.isFailure) {
    final position = Token.lineAndColumnOf(input, result.position);
    throw XmlParserException(result.message, position[0], position[1]);
  }
  return result.value;
}
