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
  Parser start() => ref0(document).end('Expected end of input');

  Parser attribute() => ref0(qualified)
      .seq(ref0(spaceOptional))
      .seq(XmlToken.equals.toParser())
      .seq(ref0(spaceOptional))
      .seq(ref0(attributeValue));

  Parser attributeValue() =>
      ref0(attributeValueDouble).or(ref0(attributeValueSingle));

  Parser attributeValueDouble() => XmlToken.doubleQuote
      .toParser()
      .seq(XmlCharacterDataParser(entityMapping, XmlToken.doubleQuote, 0))
      .seq(XmlToken.doubleQuote.toParser());

  Parser attributeValueSingle() => XmlToken.singleQuote
      .toParser()
      .seq(XmlCharacterDataParser(entityMapping, XmlToken.singleQuote, 0))
      .seq(XmlToken.singleQuote.toParser());

  Parser attributes() => ref0(space).seq(ref0(attribute)).pick(1).star();

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

  Parser content() => ref0(characterData)
      .or(ref0(element))
      .or(ref0(processing))
      .or(ref0(comment))
      .or(ref0(cdata))
      .star();

  Parser declaration() => XmlToken.openDeclaration
      .toParser()
      .seq(ref0(attributes))
      .seq(ref0(spaceOptional))
      .seq(XmlToken.closeDeclaration.toParser());

  Parser doctype() => XmlToken.openDoctype
      .toParser()
      .seq(ref0(space))
      .seq(ref0(nameToken)
          .or(ref0(attributeValue))
          .or(any()
              .starLazy(XmlToken.openDoctypeBlock.toParser())
              .seq(XmlToken.openDoctypeBlock.toParser())
              .seq(any().starLazy(XmlToken.closeDoctypeBlock.toParser()))
              .seq(XmlToken.closeDoctypeBlock.toParser()))
          .separatedBy(ref0(space))
          .flatten('Expected doctype content'))
      .seq(ref0(spaceOptional))
      .seq(XmlToken.closeDoctype.toParser());

  Parser document() => ref0(declaration)
      .optional()
      .seq(ref0(misc))
      .seq(ref0(doctype).optional())
      .seq(ref0(misc))
      .seq(ref0(element))
      .seq(ref0(misc));

  Parser documentFragment() => ref0(documentFragmentContent)
      .star()
      .seq(endOfInput('Expected end of input') | ref0(element))
      .pick(0);

  Parser documentFragmentContent() => ref0(characterData)
      .or(ref0(element))
      .or(ref0(comment))
      .or(ref0(cdata))
      .or(ref0(declaration))
      .or(ref0(processing))
      .or(ref0(doctype));

  Parser element() => XmlToken.openElement
      .toParser()
      .seq(ref0(qualified))
      .seq(ref0(attributes))
      .seq(ref0(spaceOptional))
      .seq(XmlToken.closeEndElement.toParser().or(XmlToken.closeElement
          .toParser()
          .seq(ref0(content))
          .seq(XmlToken.openEndElement.toParser().token())
          .seq(ref0(qualified))
          .seq(ref0(spaceOptional))
          .seq(XmlToken.closeElement.toParser())));

  Parser processing() => XmlToken.openProcessing
      .toParser()
      .seq(ref0(nameToken))
      .seq(ref0(space)
          .seq(any()
              .starLazy(XmlToken.closeProcessing.toParser())
              .flatten('Expected processing instruction content'))
          .pick(1)
          .optionalWith(''))
      .seq(XmlToken.closeProcessing.toParser());

  Parser qualified() => ref0(nameToken);

  Parser characterData() =>
      XmlCharacterDataParser(entityMapping, XmlToken.openElement, 1);

  Parser misc() =>
      ref0(spaceText).or(ref0(comment)).or(ref0(processing)).star();

  Parser space() => whitespace().plus();

  Parser spaceText() => ref0(space).flatten('Expected whitespace');

  Parser spaceOptional() => whitespace().star();

  Parser nameToken() =>
      ref0(nameStartChar).seq(ref0(nameChar).star()).flatten('Expected name');

  Parser nameStartChar() => pattern(_nameStartChars);

  Parser nameChar() => pattern(_nameChars);
}
