/// Dart XML Events is an event based library to asynchronously parse XML
/// documents and to convert them to other representations.
import 'src/xml/entities/default_mapping.dart';
import 'src/xml/entities/entity_mapping.dart';
import 'src/xml_events/event.dart';
import 'src/xml_events/iterable.dart';

export 'src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'src/xml/utils/node_type.dart' show XmlNodeType;
export 'src/xml_events/codec/event_codec.dart' show XmlEventCodec;
export 'src/xml_events/codec/node_codec.dart' show XmlNodeCodec;
export 'src/xml_events/converters/event_decoder.dart'
    show XmlEventDecoderExtension, XmlEventDecoder;
export 'src/xml_events/converters/event_encoder.dart'
    show XmlEventEncoderExtension, XmlEventEncoder;
export 'src/xml_events/converters/node_decoder.dart'
    show XmlNodeDecoderExtension, XmlNodeDecoder;
export 'src/xml_events/converters/node_encoder.dart'
    show XmlNodeEncoderExtension, XmlNodeEncoder;
export 'src/xml_events/event.dart' show XmlEvent;
export 'src/xml_events/events/cdata.dart' show XmlCDATAEvent;
export 'src/xml_events/events/comment.dart' show XmlCommentEvent;
export 'src/xml_events/events/declaration.dart' show XmlDeclarationEvent;
export 'src/xml_events/events/doctype.dart' show XmlDoctypeEvent;
export 'src/xml_events/events/end_element.dart' show XmlEndElementEvent;
export 'src/xml_events/events/processing.dart' show XmlProcessingEvent;
export 'src/xml_events/events/start_element.dart' show XmlStartElementEvent;
export 'src/xml_events/events/text.dart' show XmlTextEvent;
export 'src/xml_events/streams/flatten.dart' show XmlFlattenStreamExtension;
export 'src/xml_events/streams/for_each_event.dart'
    show XmlForEachEventExtension, XmlForEachEventListExtension;
export 'src/xml_events/streams/normalizer.dart'
    show XmlNormalizeEventsExtension, XmlNormalizeEvents;
export 'src/xml_events/streams/subtree_selector.dart'
    show XmlSubtreeSelectorExtension, XmlSubtreeSelector;
export 'src/xml_events/streams/with_parent.dart'
    show XmlWithParentEventsExtension, XmlWithParentEvents;
export 'src/xml_events/utils/event_attribute.dart' show XmlEventAttribute;
export 'src/xml_events/visitor.dart' show XmlEventVisitor;

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
Iterable<XmlEvent> parseEvents(String input,
        {XmlEntityMapping? entityMapping}) =>
    XmlEventIterable(input, entityMapping ?? defaultEntityMapping);
