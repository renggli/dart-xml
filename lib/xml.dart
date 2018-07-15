/// Dart XML is a lightweight library for parsing, traversing, querying and
/// building XML documents.
library xml;

import 'package:petitparser/petitparser.dart' show Parser, ParserError;

import 'xml/nodes/document.dart';
import 'xml/parser.dart';

export 'xml/builder.dart' show XmlBuilder;
export 'xml/grammar.dart' show XmlGrammarDefinition;
export 'xml/nodes/attribute.dart' show XmlAttribute;
export 'xml/nodes/cdata.dart' show XmlCDATA;
export 'xml/nodes/comment.dart' show XmlComment;
export 'xml/nodes/data.dart' show XmlData;
export 'xml/nodes/doctype.dart' show XmlDoctype;
export 'xml/nodes/document.dart' show XmlDocument;
export 'xml/nodes/document_fragment.dart' show XmlDocumentFragment;
export 'xml/nodes/element.dart' show XmlElement;
export 'xml/nodes/node.dart' show XmlNode;
export 'xml/nodes/parent.dart' show XmlParent;
export 'xml/nodes/processing.dart' show XmlProcessing;
export 'xml/nodes/text.dart' show XmlText;
export 'xml/parser.dart' show XmlParserDefinition;
export 'xml/utils/attribute_type.dart' show XmlAttributeType;
export 'xml/utils/name.dart' show XmlName;
export 'xml/utils/named.dart' show XmlNamed;
export 'xml/utils/node_type.dart' show XmlNodeType;
export 'xml/utils/owned.dart' show XmlOwned;
export 'xml/utils/writable.dart' show XmlWritable;
export 'xml/visitors/transformer.dart' show XmlTransformer;
export 'xml/visitors/visitable.dart' show XmlVisitable;
export 'xml/visitors/visitor.dart' show XmlVisitor;

final Parser _parser = new XmlParserDefinition().build();

/// Return an [XmlDocument] for the given `input` string, or throws an
/// [ArgumentError] if the input is invalid.
XmlDocument parse(String input) {
  var result = _parser.parse(input);
  if (result.isFailure) {
    throw new ArgumentError(new ParserError(result).toString());
  }
  return result.value;
}
