library xml.production;

import 'package:petitparser/petitparser.dart';

import 'entities/entity_mapping.dart';
import 'utils/character_data_parser.dart';
import 'utils/token.dart';

/// XML parser that defines standard actions to the the XML tree.
class XmlProductionDefinition extends GrammarDefinition {
  static const String _nameStartChars =
      ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001'
      '\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD';
  static const String _nameChars =
      '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$_nameStartChars';

  final XmlEntityMapping entityMapping;

  XmlProductionDefinition(this.entityMapping);

  @override
  Parser start() => ref(document).end();

  Parser attribute() => ref(qualified)
      .seq(ref(spaceOptional))
      .seq(XmlToken.equals.toParser())
      .seq(ref(spaceOptional))
      .seq(ref(attributeValue));

  Parser attributeValue() =>
      ref(attributeValueDouble).or(ref(attributeValueSingle));

  Parser attributeValueDouble() => XmlToken.doubleQuote
      .toParser()
      .seq(XmlCharacterDataParser(entityMapping, XmlToken.doubleQuote, 0))
      .seq(XmlToken.doubleQuote.toParser());

  Parser attributeValueSingle() => XmlToken.singleQuote
      .toParser()
      .seq(XmlCharacterDataParser(entityMapping, XmlToken.singleQuote, 0))
      .seq(XmlToken.singleQuote.toParser());

  Parser attributes() => ref(space).seq(ref(attribute)).pick(1).star();

  Parser comment() => XmlToken.openComment
      .toParser()
      .seq(any()
          .starLazy(XmlToken.closeComment.toParser())
          .flatten('Expected comment content'))
      .seq(XmlToken.closeComment.toParser());

  Parser cdata() => XmlToken.openCDATA
      .toParser()
      .seq(any()
          .starLazy(XmlToken.closeCDATA.toParser())
          .flatten('Expected CDATA content'))
      .seq(XmlToken.closeCDATA.toParser());

  Parser content() => ref(characterData)
      .or(ref(element))
      .or(ref(processing))
      .or(ref(comment))
      .or(ref(cdata))
      .star();

  Parser declaration() => XmlToken.openDeclaration
      .toParser()
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(XmlToken.closeDeclaration.toParser());

  Parser doctype() => XmlToken.openDoctype
      .toParser()
      .seq(ref(space))
      .seq(ref(nameToken)
          .or(ref(attributeValue))
          .or(any()
              .starLazy(XmlToken.openDoctypeBlock.toParser())
              .seq(XmlToken.openDoctypeBlock.toParser())
              .seq(any().starLazy(XmlToken.closeDoctypeBlock.toParser()))
              .seq(XmlToken.closeDoctypeBlock.toParser()))
          .separatedBy(ref(space))
          .flatten('Expected doctype content'))
      .seq(ref(spaceOptional))
      .seq(XmlToken.closeDoctype.toParser());

  Parser document() => ref(declaration)
      .optional()
      .seq(ref(misc))
      .seq(ref(doctype).optional())
      .seq(ref(misc))
      .seq(ref(element))
      .seq(ref(misc));

  Parser documentFragment() => ref(content);

  Parser element() => XmlToken.openElement
      .toParser()
      .seq(ref(qualified))
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(XmlToken.closeEndElement.toParser().or(XmlToken.closeElement
          .toParser()
          .seq(ref(content))
          .seq(XmlToken.openEndElement.toParser().token())
          .seq(ref(qualified))
          .seq(ref(spaceOptional))
          .seq(XmlToken.closeElement.toParser())));

  Parser processing() => XmlToken.openProcessing
      .toParser()
      .seq(ref(nameToken))
      .seq(ref(space)
          .seq(any()
              .starLazy(XmlToken.closeProcessing.toParser())
              .flatten('Expected processing instruction content'))
          .pick(1)
          .optional(''))
      .seq(XmlToken.closeProcessing.toParser());

  Parser qualified() => ref(nameToken);

  Parser characterData() =>
      XmlCharacterDataParser(entityMapping, XmlToken.openElement, 1);

  Parser misc() => ref(spaceText).or(ref(comment)).or(ref(processing)).star();

  Parser space() => whitespace().plus();

  Parser spaceText() => ref(space).flatten('Expected whitespace');

  Parser spaceOptional() => whitespace().star();

  Parser nameToken() =>
      ref(nameStartChar).seq(ref(nameChar).star()).flatten('Expected name');

  Parser nameStartChar() => pattern(_nameStartChars);

  Parser nameChar() => pattern(_nameChars);
}
