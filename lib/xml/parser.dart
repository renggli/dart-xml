library xml.parser;

import 'package:xml/xml/grammar.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/cdata.dart';
import 'package:xml/xml/nodes/comment.dart';
import 'package:xml/xml/nodes/doctype.dart';
import 'package:xml/xml/nodes/document.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/nodes/node.dart';
import 'package:xml/xml/nodes/processing.dart';
import 'package:xml/xml/nodes/text.dart';
import 'package:xml/xml/utils/attribute_type.dart';
import 'package:xml/xml/utils/name.dart';

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
