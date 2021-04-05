import 'package:petitparser/petitparser.dart';

import '../xml/entities/entity_mapping.dart';
import '../xml/production.dart';
import '../xml/utils/attribute_type.dart';
import '../xml/utils/cache.dart';
import '../xml/utils/token.dart';
import 'events/cdata.dart';
import 'events/comment.dart';
import 'events/declaration.dart';
import 'events/doctype.dart';
import 'events/end_element.dart';
import 'events/processing.dart';
import 'events/start_element.dart';
import 'events/text.dart';
import 'utils/event_attribute.dart';

class XmlEventDefinition extends XmlProductionDefinition {
  XmlEventDefinition(XmlEntityMapping entityMapping) : super(entityMapping);

  @override
  Parser start() => ref0(characterData)
      .or(ref0(startElement))
      .or(ref0(endElement))
      .or(ref0(comment))
      .or(ref0(cdata))
      .or(ref0(declaration))
      .or(ref0(processing))
      .or(ref0(doctype));

  @override
  Parser characterData() =>
      super.characterData().map((each) => XmlTextEvent(each));

  Parser startElement() => XmlToken.openElement
      .toParser()
      .seq(ref0(qualified))
      .seq(ref0(attributes))
      .seq(ref0(spaceOptional))
      .seq(XmlToken.closeElement
          .toParser()
          .or(XmlToken.closeEndElement.toParser()))
      .map((each) => XmlStartElementEvent(
          each[1],
          each[2].cast<XmlEventAttribute>(),
          each[4] == XmlToken.closeEndElement));

  @override
  Parser attribute() => super.attribute().map((each) => XmlEventAttribute(
      each[0],
      each[4][1],
      each[4][0] == '"'
          ? XmlAttributeType.DOUBLE_QUOTE
          : XmlAttributeType.SINGLE_QUOTE));

  Parser endElement() => XmlToken.openEndElement
      .toParser()
      .seq(ref0(qualified))
      .seq(ref0(spaceOptional))
      .seq(XmlToken.closeElement.toParser())
      .map((each) => XmlEndElementEvent(each[1]));

  @override
  Parser comment() => super.comment().map((each) => XmlCommentEvent(each[1]));

  @override
  Parser cdata() => super.cdata().map((each) => XmlCDATAEvent(each[1]));

  @override
  Parser declaration() => super
      .declaration()
      .map((each) => XmlDeclarationEvent(each[1].cast<XmlEventAttribute>()));

  @override
  Parser processing() =>
      super.processing().map((each) => XmlProcessingEvent(each[1], each[2]));

  @override
  Parser doctype() => super.doctype().map((each) => XmlDoctypeEvent(each[2]));
}

final XmlCache<XmlEntityMapping, Parser> eventParserCache =
    XmlCache((entityMapping) => XmlEventDefinition(entityMapping).build(), 5);
