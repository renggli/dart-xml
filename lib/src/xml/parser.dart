library xml.parser;

import 'grammar.dart';
import 'nodes/attribute.dart';
import 'nodes/cdata.dart';
import 'nodes/comment.dart';
import 'nodes/doctype.dart';
import 'nodes/document.dart';
import 'nodes/element.dart';
import 'nodes/node.dart';
import 'nodes/processing.dart';
import 'nodes/text.dart';
import 'utils/attribute_type.dart';
import 'utils/name.dart';

/// XML parser that defines standard actions to the the XML tree.
class XmlParserDefinition extends XmlGrammarDefinition<XmlNode, XmlName> {
  @override
  XmlAttribute createAttribute(
          XmlName name, String text, XmlAttributeType type) =>
      XmlAttribute(name, text, type);

  @override
  XmlComment createComment(String text) => XmlComment(text);

  @override
  XmlCDATA createCDATA(String text) => XmlCDATA(text);

  @override
  XmlDoctype createDoctype(String text) => XmlDoctype(text);

  @override
  XmlDocument createDocument(Iterable<XmlNode> children) =>
      XmlDocument(children);

  @override
  XmlElement createElement(XmlName name, Iterable<XmlNode> attributes,
          Iterable<XmlNode> children, [bool isSelfClosing = true]) =>
      XmlElement(
          name, List<XmlAttribute>.from(attributes), children, isSelfClosing);

  @override
  XmlProcessing createProcessing(String target, String text) =>
      XmlProcessing(target, text);

  @override
  XmlName createQualified(String name) => XmlName.fromString(name);

  @override
  XmlText createText(String text) => XmlText(text);
}
