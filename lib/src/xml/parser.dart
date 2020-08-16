import 'entities/entity_mapping.dart';
import 'grammar.dart';
import 'nodes/attribute.dart';
import 'nodes/cdata.dart';
import 'nodes/comment.dart';
import 'nodes/declaration.dart';
import 'nodes/doctype.dart';
import 'nodes/document.dart';
import 'nodes/document_fragment.dart';
import 'nodes/element.dart';
import 'nodes/node.dart';
import 'nodes/processing.dart';
import 'nodes/text.dart';
import 'utils/attribute_type.dart';
import 'utils/name.dart';

/// XML parser that defines standard actions to the the XML tree.
class XmlParserDefinition extends XmlGrammarDefinition<XmlNode, XmlName> {
  XmlParserDefinition(XmlEntityMapping entityMapping) : super(entityMapping);

  @override
  XmlAttribute createAttribute(
          XmlName name, String text, XmlAttributeType type) =>
      XmlAttribute(name, text, type);

  @override
  XmlComment createComment(String text) => XmlComment(text);

  @override
  XmlCDATA createCDATA(String text) => XmlCDATA(text);

  @override
  XmlDeclaration createDeclaration(Iterable<XmlNode> attributes) =>
      XmlDeclaration(attributes.cast<XmlAttribute>());

  @override
  XmlDoctype createDoctype(String text) => XmlDoctype(text);

  @override
  XmlDocument createDocument(Iterable<XmlNode> children) =>
      XmlDocument(children);

  @override
  XmlNode createDocumentFragment(Iterable<XmlNode> children) =>
      XmlDocumentFragment(children);

  @override
  XmlElement createElement(XmlName name, Iterable<XmlNode> attributes,
          Iterable<XmlNode> children, [bool isSelfClosing = true]) =>
      XmlElement(
          name, attributes.cast<XmlAttribute>(), children, isSelfClosing);

  @override
  XmlProcessing createProcessing(String target, String text) =>
      XmlProcessing(target, text);

  @override
  XmlName createQualified(String name) => XmlName.fromString(name);

  @override
  XmlText createText(String text) => XmlText(text);
}
