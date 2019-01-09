library xml_events;

import 'src/xml_events/event.dart';
import 'src/xml_events/iterator.dart';

export 'src/xml_events/event.dart' show XmlEvent;
export 'src/xml_events/events/cdata_event.dart' show XmlCDATAEvent;
export 'src/xml_events/events/comment_event.dart' show XmlCommentEvent;
export 'src/xml_events/events/doctype_event.dart' show XmlDoctypeEvent;
export 'src/xml_events/events/end_element_event.dart' show XmlEndElementEvent;
export 'src/xml_events/events/processing_event.dart' show XmlProcessingEvent;
export 'src/xml_events/events/start_element_event.dart'
    show XmlStartElementEvent;
export 'src/xml_events/events/text_event.dart' show XmlTextEvent;

/// Returns a lazy [Iterator] over the given `input` string.
///
/// The iteration throws an `XmlParserException`, if the input in malformed
/// along the way. If iteration is resumed, the parsing is retried at the next
/// possible input position.
///
/// The iterator terminates when the complete `input` string is consumed.
Iterator<XmlEvent> parseIterator(String input) => XmlEventIterator(input);
