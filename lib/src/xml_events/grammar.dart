import 'package:petitparser/petitparser.dart';

import '../xml/entities/entity_mapping.dart';
import '../xml/utils/attribute_type.dart';
import '../xml/utils/cache.dart';
import '../xml/utils/character_data_parser.dart';
import '../xml/utils/token.dart';
import 'event.dart';
import 'events/cdata.dart';
import 'events/comment.dart';
import 'events/declaration.dart';
import 'events/doctype.dart';
import 'events/end_element.dart';
import 'events/processing.dart';
import 'events/start_element.dart';
import 'events/text.dart';
import 'utils/event_attribute.dart';

class XmlEventGrammar extends GrammarDefinition {
  const XmlEventGrammar(this.entityMapping);

  final XmlEntityMapping entityMapping;

  @override
  Parser<XmlEvent> start() => [
        ref0(characterData),
        ref0(startElement),
        ref0(endElement),
        ref0(comment),
        ref0(cdata),
        ref0(declaration),
        ref0(processing),
        ref0(doctype),
      ].toChoiceParser();

  // Events

  Parser<XmlTextEvent> characterData() =>
      XmlCharacterDataParser(entityMapping, XmlToken.openElement, 1)
          .map((each) => XmlTextEvent(each));

  Parser<XmlStartElementEvent> startElement() => [
        XmlToken.openElement.toParser(),
        ref0(nameToken),
        ref0(attributes),
        ref0(spaceOptional),
        [
          XmlToken.closeElement.toParser(),
          XmlToken.closeEndElement.toParser(),
        ].toChoiceParser(),
      ].toSequenceParser().map((each) => XmlStartElementEvent(
          each[1] as String,
          each[2] as List<XmlEventAttribute>,
          each[4] == XmlToken.closeEndElement));

  Parser<List<XmlEventAttribute>> attributes() => ref0(attribute).star();

  Parser<XmlEventAttribute> attribute() => [
        ref0(space),
        ref0(nameToken),
        ref0(spaceOptional),
        XmlToken.equals.toParser(),
        ref0(spaceOptional),
        ref0(attributeValue),
      ].toSequenceParser().map((each) {
        final attributeValue = each[5] as List<String>;
        return XmlEventAttribute(
            each[1] as String,
            attributeValue[1],
            attributeValue[0] == '"'
                ? XmlAttributeType.DOUBLE_QUOTE
                : XmlAttributeType.SINGLE_QUOTE);
      });

  Parser<List<String>> attributeValue() => [
        ref0(attributeValueDouble),
        ref0(attributeValueSingle),
      ].toChoiceParser();

  Parser<List<String>> attributeValueDouble() => [
        XmlToken.doubleQuote.toParser(),
        XmlCharacterDataParser(entityMapping, XmlToken.doubleQuote, 0),
        XmlToken.doubleQuote.toParser(),
      ].toSequenceParser();

  Parser<List<String>> attributeValueSingle() => [
        XmlToken.singleQuote.toParser(),
        XmlCharacterDataParser(entityMapping, XmlToken.singleQuote, 0),
        XmlToken.singleQuote.toParser(),
      ].toSequenceParser();

  Parser<XmlEndElementEvent> endElement() => [
        XmlToken.openEndElement.toParser(),
        ref0(nameToken),
        ref0(spaceOptional),
        XmlToken.closeElement.toParser(),
      ].toSequenceParser().map((each) => XmlEndElementEvent(each[1]));

  Parser<XmlCommentEvent> comment() => [
        XmlToken.openComment.toParser(),
        any()
            .starLazy(XmlToken.closeComment.toParser())
            .flatten('Expected comment content'),
        XmlToken.closeComment.toParser(),
      ].toSequenceParser().map((each) => XmlCommentEvent(each[1]));

  Parser<XmlCDATAEvent> cdata() => [
        XmlToken.openCDATA.toParser(),
        any()
            .starLazy(XmlToken.closeCDATA.toParser())
            .flatten('Expected CDATA content'),
        XmlToken.closeCDATA.toParser(),
      ].toSequenceParser().map((each) => XmlCDATAEvent(each[1]));

  Parser<XmlDeclarationEvent> declaration() => [
        XmlToken.openDeclaration.toParser(),
        ref0(attributes),
        ref0(spaceOptional),
        XmlToken.closeDeclaration.toParser(),
      ].toSequenceParser().map(
          (each) => XmlDeclarationEvent(each[1] as List<XmlEventAttribute>));

  Parser<XmlProcessingEvent> processing() => [
        XmlToken.openProcessing.toParser(),
        ref0(nameToken),
        [
          ref0(space),
          any()
              .starLazy(XmlToken.closeProcessing.toParser())
              .flatten('Expected processing instruction content')
        ].toSequenceParser().pick(1).optionalWith(''),
        XmlToken.closeProcessing.toParser(),
      ].toSequenceParser().map((each) => XmlProcessingEvent(each[1], each[2]));

  Parser<XmlDoctypeEvent> doctype() => [
        XmlToken.openDoctype.toParser(),
        ref0(space),
        [
          ref0(nameToken),
          ref0(attributeValue),
          [
            XmlToken.openDoctypeBlock.toParser(),
            any().starLazy(XmlToken.closeDoctypeBlock.toParser()),
            XmlToken.closeDoctypeBlock.toParser(),
          ].toSequenceParser(),
        ]
            .toChoiceParser()
            .separatedBy(ref0(spaceOptional))
            .flatten('Expected doctype content'),
        ref0(spaceOptional),
        XmlToken.closeDoctype.toParser(),
      ].toSequenceParser().map((each) => XmlDoctypeEvent(each[2]));

  // Tokens

  Parser<String> space() => whitespace().plus().flatten('Expected whitespace');

  Parser<String> spaceOptional() =>
      whitespace().star().flatten('Expected whitespace');

  Parser<String> nameToken() => [
        ref0(nameStartChar),
        ref0(nameChar).star(),
      ].toSequenceParser().flatten('Expected name');

  Parser<String> nameStartChar() => pattern(_nameStartChars);

  Parser<String> nameChar() => pattern(_nameChars);

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
}

final XmlCache<XmlEntityMapping, Parser> eventParserCache =
    XmlCache((entityMapping) => XmlEventGrammar(entityMapping).build(), 5);
