import 'package:petitparser/petitparser.dart';

import 'entities/entity_mapping.dart';
import 'utils/character_data_parser.dart';
import 'utils/token.dart';

/// XML parser that defines standard actions to the the XML tree.
class XmlProductionDefinition extends GrammarDefinition {
  // https://en.wikipedia.org/wiki/QName
  static const String _nameStartChars = ':A-Z_a-z'
      '\u00c0-\u00d6'
      '\u00d8-\u00f6'
      '\u00f8-\u02ff'
      '\u0370-\u037d'
      '\u037f-\u1fff'
      '\u200c-\u200d'
      '\u2070-\u218f'
      '\u2c00-\u2fef'
      '\u3001-\ud7ff'
      '\uf900-\ufdcf'
      '\ufdf0-\ufffd';
  static const String _nameChars = '$_nameStartChars'
      '-.0-9'
      '\u00b7'
      '\u0300-\u036f'
      '\u203f-\u2040';

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

  Parser documentFragment() => ref(characterData)
      .or(ref(element))
      .or(ref(comment))
      .or(ref(cdata))
      .or(ref(declaration))
      .or(ref(processing))
      .or(ref(doctype))
      .star();

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
