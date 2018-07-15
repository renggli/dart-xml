library xml.grammar;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/utils/attribute_type.dart';
import 'package:xml/xml/utils/entities.dart';
import 'package:xml/xml/utils/token.dart';

/// XML grammar definition with [TNode] and [TName].
abstract class XmlGrammarDefinition<TNode, TName> extends GrammarDefinition {
  // name patterns
  static const String NAME_START_CHARS =
      ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001\uD7FF'
      '\uF900-\uFDCF\uFDF0-\uFFFD';
  static const String NAME_CHARS =
      '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$NAME_START_CHARS';
  static const String CHAR_DATA = '^<';

  // parser callbacks
  TNode createAttribute(TName name, String text, XmlAttributeType type);
  TNode createComment(String text);
  TNode createCDATA(String text);
  TNode createDoctype(String text);
  TNode createDocument(Iterable<TNode> children);
  TNode createElement(TName name, Iterable<TNode> attributes, Iterable<TNode> children);
  TNode createProcessing(String target, String text);
  TName createQualified(String name);
  TNode createText(String text);

  // productions
  @override
  Parser start() => ref(document).end();

  Parser attribute() => ref(qualified)
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.equals))
      .seq(ref(spaceOptional))
      .seq(ref(attributeValue))
      .map((each) => createAttribute(each[0] as TName, each[4][0], each[4][1]));
  Parser attributeValue() =>
      ref(attributeValueDouble).or(ref(attributeValueSingle));
  Parser attributeValueDouble() => char(XmlToken.doubleQuote)
      .seq(new XmlCharacterDataParser(XmlToken.doubleQuote, 0))
      .seq(char(XmlToken.doubleQuote))
      .map((each) => [each[1], XmlAttributeType.DOUBLE_QUOTE]);
  Parser attributeValueSingle() => char(XmlToken.singleQuote)
      .seq(new XmlCharacterDataParser(XmlToken.singleQuote, 0))
      .seq(char(XmlToken.singleQuote))
      .map((each) => [each[1], XmlAttributeType.SINGLE_QUOTE]);
  Parser attributes() => ref(space).seq(ref(attribute)).pick(1).star();
  Parser comment() => string(XmlToken.openComment)
      .seq(any().starLazy(string(XmlToken.closeComment)).flatten())
      .seq(string(XmlToken.closeComment))
      .map((each) => createComment(each[1]));
  Parser cdata() => string(XmlToken.openCDATA)
      .seq(any().starLazy(string(XmlToken.closeCDATA)).flatten())
      .seq(string(XmlToken.closeCDATA))
      .map((each) => createCDATA(each[1]));
  Parser content() => ref(characterData)
      .or(ref(element))
      .or(ref(processing))
      .or(ref(comment))
      .or(ref(cdata))
      .star();
  Parser doctype() => string(XmlToken.openDoctype)
      .seq(ref(space))
      .seq(ref(nameToken)
          .or(ref(attributeValue))
          .or(any()
              .starLazy(char(XmlToken.openDoctypeBlock))
              .seq(char(XmlToken.openDoctypeBlock))
              .seq(any().starLazy(char(XmlToken.closeDoctypeBlock)))
              .seq(char(XmlToken.closeDoctypeBlock)))
          .separatedBy(ref(space))
          .flatten())
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeDoctype))
      .map((each) => createDoctype(each[2]));
  Parser document() => ref(misc)
          .seq(ref(doctype).optional())
          .seq(ref(misc))
          .seq(ref(element))
          .seq(ref(misc))
          .map((each) {
        var nodes = [];
        nodes.addAll(each[0]);
        if (each[1] != null) {
          nodes.add(each[1]);
        }
        nodes.addAll(each[2]);
        nodes.add(each[3]);
        nodes.addAll(each[4]);
        return createDocument(new List<TNode>.from(nodes));
      });
  Parser element() => char(XmlToken.openElement)
          .seq(ref(qualified))
          .seq(ref(attributes))
          .seq(ref(spaceOptional))
          .seq(string(XmlToken.closeEndElement).or(char(XmlToken.closeElement)
              .seq(ref(content))
              .seq(string(XmlToken.openEndElement))
              .seq(ref(qualified))
              .seq(ref(spaceOptional))
              .seq(char(XmlToken.closeElement))))
          .map((list) {
        if (list[4] == XmlToken.closeEndElement) {
          return createElement(
              list[1] as TName, new List<TNode>.from(list[2]), []);
        } else {
          if (list[1] == list[4][3]) {
            return createElement(
                list[1] as TName,
                new List<TNode>.from(list[2]),
                new List<TNode>.from(list[4][1]));
          } else {
            throw new ArgumentError(
                'Expected </${list[1]}>, but found </${list[4][3]}>');
          }
        }
      });
  Parser processing() => string(XmlToken.openProcessing)
      .seq(ref(nameToken))
      .seq(ref(space)
          .seq(any().starLazy(string(XmlToken.closeProcessing)).flatten())
          .pick(1)
          .optional(''))
      .seq(string(XmlToken.closeProcessing))
      .map((each) => createProcessing(each[1], each[2]));
  Parser qualified() => ref(nameToken).map(createQualified);

  Parser characterData() =>
      new XmlCharacterDataParser(XmlToken.openElement, 1).map(createText);
  Parser misc() => ref(spaceText).or(ref(comment)).or(ref(processing)).star();
  Parser space() => whitespace().plus();
  Parser spaceText() => ref(space).flatten().map(createText);
  Parser spaceOptional() => whitespace().star();

  Parser nameToken() => ref(nameStartChar).seq(ref(nameChar).star()).flatten();
  Parser nameStartChar() => pattern(NAME_START_CHARS, 'Expected name');
  Parser nameChar() => pattern(NAME_CHARS);
}
