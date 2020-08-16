import 'package:petitparser/petitparser.dart';

import 'entities/entity_mapping.dart';
import 'production.dart';
import 'utils/attribute_type.dart';
import 'utils/exceptions.dart';
import 'utils/token.dart';

/// XML grammar definition with [TNode] and [TName].
abstract class XmlGrammarDefinition<TNode, TName>
    extends XmlProductionDefinition {
  XmlGrammarDefinition(XmlEntityMapping entityMapping) : super(entityMapping);

  // Callbacks used to build the XML AST.
  TNode createAttribute(TName name, String text, XmlAttributeType type);

  TNode createComment(String text);

  TNode createCDATA(String text);

  TNode createDeclaration(Iterable<TNode> attributes);

  TNode createDoctype(String text);

  TNode createDocument(Iterable<TNode> children);

  TNode createDocumentFragment(Iterable<TNode> children);

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
  Parser declaration() => super
      .declaration()
      .map((each) => createDeclaration(each[1].cast<TNode>()));

  @override
  Parser cdata() => super.cdata().map((each) => createCDATA(each[1]));

  @override
  Parser doctype() => super.doctype().map((each) => createDoctype(each[2]));

  @override
  Parser document() => super.document().map((each) {
        final nodes = [];
        if (each[0] != null) {
          nodes.add(each[0]); // declaration
        }
        nodes.addAll(each[1]);
        if (each[2] != null) {
          nodes.add(each[2]); // doctype
        }
        nodes.addAll(each[3]);
        nodes.add(each[4]); // document
        nodes.addAll(each[5]);
        return createDocument(nodes.cast<TNode>());
      });

  @override
  Parser documentFragment() => super
      .documentFragment()
      .map((nodes) => createDocumentFragment(nodes.cast<TNode>()));

  @override
  Parser element() => super.element().map((list) {
        final TName name = list[1];
        final attributes = list[2].cast<TNode>();
        if (list[4] == XmlToken.closeEndElement) {
          return createElement(name, attributes, [], true);
        } else {
          if (list[1] == list[4][3]) {
            final children = list[4][1].cast<TNode>();
            return createElement(
                name, attributes, children, children.isNotEmpty);
          } else {
            final Token token = list[4][2];
            final lineAndColumn =
                Token.lineAndColumnOf(token.buffer, token.start);
            throw XmlParserException(
                'Expected </${list[1]}>, but found </${list[4][3]}>',
                buffer: token.buffer,
                position: token.start,
                line: lineAndColumn[0],
                column: lineAndColumn[1]);
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
