/// Dart XML Events is an event based library to asynchronously parse XML
/// documents and to convert them to other representations.
library xml_events;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/iterable.dart';

export 'package:xml/src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'package:xml/src/xml/utils/node_type.dart' show XmlNodeType;
export 'package:xml/src/xml_events/codec/event_codec.dart' show XmlEventCodec;
export 'package:xml/src/xml_events/codec/node_codec.dart' show XmlNodeCodec;
export 'package:xml/src/xml_events/converters/event_decoder.dart'
    show XmlEventDecoder;
export 'package:xml/src/xml_events/converters/event_encoder.dart'
    show XmlEventEncoder;
export 'package:xml/src/xml_events/converters/node_decoder.dart'
    show XmlNodeDecoder;
export 'package:xml/src/xml_events/converters/node_encoder.dart'
    show XmlNodeEncoder;
export 'package:xml/src/xml_events/converters/normalizer.dart'
    show XmlNormalizer;
export 'package:xml/src/xml_events/event.dart' show XmlEvent;
export 'package:xml/src/xml_events/events/cdata_event.dart' show XmlCDATAEvent;
export 'package:xml/src/xml_events/events/comment_event.dart'
    show XmlCommentEvent;
export 'package:xml/src/xml_events/events/doctype_event.dart'
    show XmlDoctypeEvent;
export 'package:xml/src/xml_events/events/end_element_event.dart'
    show XmlEndElementEvent;
export 'package:xml/src/xml_events/events/processing_event.dart'
    show XmlProcessingEvent;
export 'package:xml/src/xml_events/events/start_element_event.dart'
    show XmlStartElementEvent, XmlElementAttribute;
export 'package:xml/src/xml_events/events/text_event.dart' show XmlTextEvent;
export 'package:xml/src/xml_events/visitor.dart' show XmlEventVisitor;

/// Returns an [Iterable] of [XmlEvent] instances over the provided [String].
///
/// Iteration can throw an `XmlParserException`, if the input is malformed and
/// cannot be properly parsed. However, otherwise no validation is performed and
/// iteration can be resumed even after an error. The parsing is simply retried
/// at the next possible input position.
///
/// Iteration is lazy, meaning that none of the `input` is parsed and none of
/// the events are created unless requested.
///
/// The iterator terminates when the complete `input` is consumed.
///
/// For example, to print all trimmed non-empty text elements one would write:
///
///    parseEvents(bookstoreXml)
///        .whereType<XmlTextEvent>()
///        .map((event) => event.text.trim())
///        .where((text) => text.isNotEmpty)
///        .forEach(print);
///
Iterable<XmlEvent> parseEvents(String input) => XmlEventIterable(input);
