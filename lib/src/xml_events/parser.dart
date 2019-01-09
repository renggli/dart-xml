library xml_events.parser;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';

import 'events/attribute_event.dart';
import 'events/cdata_event.dart';
import 'events/comment_event.dart';
import 'events/doctype_event.dart';
import 'events/end_element_event.dart';
import 'events/processing_event.dart';
import 'events/start_element_event.dart';
import 'events/text_event.dart';

class XmlEventDefinition extends XmlProductionDefinition {
  @override
  Parser start() => ref(characterData)
      .or(ref(startElement))
      .or(ref(endElement))
      .or(ref(comment))
      .or(ref(cdata))
      .or(ref(processing))
      .or(ref(doctype));

  @override
  Parser characterData() =>
      super.characterData().map((each) => XmlTextEvent(each));

  Parser startElement() => char(XmlToken.openElement)
      .seq(ref(qualified))
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeElement).or(string(XmlToken.closeEndElement)))
      .map((each) => XmlStartElementEvent(
          each[1],
          List.castFrom<dynamic, XmlElementAttribute>(each[2]),
          each[4] == XmlToken.closeEndElement));

  @override
  Parser attribute() => super.attribute().map((each) => XmlElementAttribute(
      each[0],
      each[4][1],
      each[4][0] == '"'
          ? XmlAttributeType.DOUBLE_QUOTE
          : XmlAttributeType.SINGLE_QUOTE));

  Parser endElement() => string(XmlToken.openEndElement)
      .seq(ref(qualified))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeElement))
      .map((each) => XmlEndElementEvent(each[1]));

  @override
  Parser comment() => super.comment().map((each) => XmlCommentEvent(each[1]));

  @override
  Parser cdata() => super.cdata().map((each) => XmlCDATAEvent(each[1]));

  @override
  Parser processing() =>
      super.processing().map((each) => XmlProcessingEvent(each[1], each[2]));

  @override
  Parser doctype() => super.doctype().map((each) => XmlDoctypeEvent(each[2]));
}
