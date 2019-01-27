library xml.grammar;

import 'package:petitparser/petitparser.dart' show Parser, Token;
import 'package:xml/src/xml/production.dart';
import 'package:xml/src/xml/utils/attribute_type.dart';
import 'package:xml/src/xml/utils/exceptions.dart';
import 'package:xml/src/xml/utils/token.dart';

/// XML grammar definition with [TNode] and [TName].
abstract class XmlGrammarDefinition<TNode, TName>
    extends XmlProductionDefinition {
  // Callbacks used to build the XML AST.
  TNode createAttribute(TName name, String text, XmlAttributeType type);
  TNode createComment(String text);
  TNode createCDATA(String text);
  TNode createDoctype(String text);
  TNode createDocument(Iterable<TNode> children);
  TNode createElement(TName name, Iterable<TNode> attributes,
      Iterable<TNode> children, bool isSelfClosing);
  TNode createProcessing(String target, String text);
  TName createQualified(String name);
  TNode createText(String text);

  // Connects the productions and the XML AST callbacks.

  @override
  Parser attribute() => super
      .attribute()
      .map((each) => createAttribute(each[0], each[4][0], each[4][1]));

  @override
  Parser attributeValueDouble() => super
      .attributeValueDouble()
      .map((each) => [each[1], XmlAttributeType.DOUBLE_QUOTE]);

  @override
  Parser attributeValueSingle() => super
      .attributeValueSingle()
      .map((each) => [each[1], XmlAttributeType.SINGLE_QUOTE]);

  @override
  Parser comment() => super.comment().map((each) => createComment(each[1]));

  @override
  Parser cdata() => super.cdata().map((each) => createCDATA(each[1]));

  @override
  Parser doctype() => super.doctype().map((each) => createDoctype(each[2]));

  @override
  Parser document() => super.document().map((each) {
        final nodes = [];
        nodes.addAll(each[0]);
        if (each[1] != null) {
          nodes.add(each[1]);
        }
        nodes.addAll(each[2]);
        nodes.add(each[3]);
        nodes.addAll(each[4]);
        return createDocument(List.castFrom<dynamic, TNode>(nodes));
      });

  @override
  Parser element() => super.element().map((list) {
        final TName name = list[1];
        final attributes = List.castFrom<dynamic, TNode>(list[2]);
        if (list[4] == XmlToken.closeEndElement) {
          return createElement(name, attributes, [], true);
        } else {
          if (list[1] == list[4][3]) {
            final children = List.castFrom<dynamic, TNode>(list[4][1]);
            return createElement(
                name, attributes, children, children.isNotEmpty);
          } else {
            final Token token = list[4][2];
            throw XmlParserException(
                'Expected </${list[1]}>, but found </${list[4][3]}>',
                token.line,
                token.column);
          }
        }
      });

  @override
  Parser processing() =>
      super.processing().map((each) => createProcessing(each[1], each[2]));

  @override
  Parser qualified() => super.qualified().cast<String>().map(createQualified);

  @override
  Parser characterData() =>
      super.characterData().cast<String>().map(createText);

  @override
  Parser spaceText() => super.spaceText().cast<String>().map(createText);
}
