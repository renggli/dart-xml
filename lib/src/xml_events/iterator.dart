library xml_events.iterator;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';

import 'event.dart';
import 'events/cdata_event.dart';
import 'events/comment_event.dart';
import 'events/doctype_event.dart';
import 'events/end_element_event.dart';
import 'events/processing_event.dart';
import 'events/start_element_event.dart';
import 'events/text_event.dart';

/// Grammar definition to read XML data event based.
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

/// Parser to read XML data event based.
final _eventParser = XmlEventDefinition().build();

/// Lazily iterates over and input [String] and produces [XmlEvent]s.
class XmlEventIterator extends Iterator<XmlEvent> {
  XmlEventIterator(String input) : context = Success(input, 0, null);

  Result context;

  @override
  XmlEvent current;

  @override
  bool moveNext() {
    final result = _eventParser.parseOn(context);
    if (result.isSuccess) {
      context = result;
      current = result.value;
      return true;
    } else {
      if (context.position < context.buffer.length) {
        // In case of an error, skip one character and throw an exception.
        context = context.failure(context.message, context.position + 1);
        current = null;
        final position = Token.lineAndColumnOf(result.buffer, result.position);
        throw XmlParserException(result.message, position[0], position[1]);
      } else {
        // In case of reaching the end, terminate the iterator.
        context = null;
        current = null;
        return false;
      }
    }
  }
}
