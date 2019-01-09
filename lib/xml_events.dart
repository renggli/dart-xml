library xml_events;

import 'src/xml_events/event.dart';
import 'src/xml_events/iterable.dart';

export 'src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'src/xml/utils/node_type.dart' show XmlNodeType;
export 'src/xml_events/event.dart' show XmlEvent;
export 'src/xml_events/events/cdata_event.dart' show XmlCDATAEvent;
export 'src/xml_events/events/comment_event.dart' show XmlCommentEvent;
export 'src/xml_events/events/doctype_event.dart' show XmlDoctypeEvent;
export 'src/xml_events/events/end_element_event.dart' show XmlEndElementEvent;
export 'src/xml_events/events/processing_event.dart' show XmlProcessingEvent;
export 'src/xml_events/events/start_element_event.dart'
    show XmlStartElementEvent;
export 'src/xml_events/events/text_event.dart' show XmlTextEvent;

/// Returns an [Iterable] of [XmlEvent] instances of the provided [String].
///
/// Iteration can throw an `XmlParserException`, if the input is malformed and
/// cannot be properly parsed. However, otherwise no validation is performed and
/// iteration can be resumed even after an error. The parsing is simply retried
/// at the next possible input position.
///
/// The iterator terminates when the complete `input` is consumed.
///
/// For example, to print printing all trimmed non-empty text elements one
/// would write:
///
///    parseEvents(bookstoreXml)
///       .whereType<XmlTextEvent>()
///       .map((event) => event.text.trim())
///       .where((text) => text.isNotEmpty)
///       .forEach(print);
///
Iterable<XmlEvent> parseEvents(String input) => XmlEventIterable(input);
