library xml.production;

import 'package:petitparser/petitparser.dart'
    show any, char, pattern, whitespace, string;
import 'package:petitparser/petitparser.dart' show Parser, GrammarDefinition;
import 'package:xml/src/xml/utils/entities.dart';
import 'package:xml/src/xml/utils/token.dart';

/// XML parser that defines standard actions to the the XML tree.
class XmlProductionDefinition extends GrammarDefinition {
  static const String _nameStartChars =
      ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001'
      '\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD';
  static const String _nameChars =
      '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$_nameStartChars';

  @override
  Parser start() => ref(document).end();

  Parser attribute() => ref(qualified)
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.equals))
      .seq(ref(spaceOptional))
      .seq(ref(attributeValue));
  Parser attributeValue() =>
      ref(attributeValueDouble).or(ref(attributeValueSingle));
  Parser attributeValueDouble() => char(XmlToken.doubleQuote)
      .seq(XmlCharacterDataParser(XmlToken.doubleQuote, 0))
      .seq(char(XmlToken.doubleQuote));
  Parser attributeValueSingle() => char(XmlToken.singleQuote)
      .seq(XmlCharacterDataParser(XmlToken.singleQuote, 0))
      .seq(char(XmlToken.singleQuote));
  Parser attributes() => ref(space).seq(ref(attribute)).pick(1).star();
  Parser comment() => string(XmlToken.openComment)
      .seq(any()
          .starLazy(string(XmlToken.closeComment))
          .flatten('Expected comment content'))
      .seq(string(XmlToken.closeComment));
  Parser cdata() => string(XmlToken.openCDATA)
      .seq(any()
          .starLazy(string(XmlToken.closeCDATA))
          .flatten('Expected CDATA content'))
      .seq(string(XmlToken.closeCDATA));
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
          .flatten('Expected doctype content'))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeDoctype));
  Parser document() => ref(misc)
      .seq(ref(doctype).optional())
      .seq(ref(misc))
      .seq(ref(element))
      .seq(ref(misc));
  Parser element() => char(XmlToken.openElement)
      .seq(ref(qualified))
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(string(XmlToken.closeEndElement).or(char(XmlToken.closeElement)
          .seq(ref(content))
          .seq(string(XmlToken.openEndElement).token())
          .seq(ref(qualified))
          .seq(ref(spaceOptional))
          .seq(char(XmlToken.closeElement))));
  Parser processing() => string(XmlToken.openProcessing)
      .seq(ref(nameToken))
      .seq(ref(space)
          .seq(any()
              .starLazy(string(XmlToken.closeProcessing))
              .flatten('Expected processing instruction content'))
          .pick(1)
          .optional(''))
      .seq(string(XmlToken.closeProcessing));
  Parser qualified() => ref(nameToken);

  Parser characterData() => XmlCharacterDataParser(XmlToken.openElement, 1);
  Parser misc() => ref(spaceText).or(ref(comment)).or(ref(processing)).star();
  Parser space() => whitespace().plus();
  Parser spaceText() => ref(space).flatten('Expected whitespace');
  Parser spaceOptional() => whitespace().star();

  Parser nameToken() =>
      ref(nameStartChar).seq(ref(nameChar).star()).flatten('Expected name');
  Parser nameStartChar() => pattern(_nameStartChars);
  Parser nameChar() => pattern(_nameChars);
}
