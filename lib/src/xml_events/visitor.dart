library xml.events.visitor;

import 'event.dart';
import 'events/cdata_event.dart';
import 'events/comment_event.dart';
import 'events/doctype_event.dart';
import 'events/end_element_event.dart';
import 'events/processing_event.dart';
import 'events/start_element_event.dart';
import 'events/text_event.dart';

/// Basic visitor over [XmlEvent] nodes.
abstract class XmlEventVisitor {
  /// Helper to visit an [XmlEvent] using this visitor by dispatching
  /// through the provided [event].
  T visit<T>(XmlEvent event) => event.accept(this);

  /// Visit an [XmlCDATAEvent] event.
  dynamic visitCDATAEvent(XmlCDATAEvent event) => null;

  /// Visit an [XmlCommentEvent] event.
  dynamic visitCommentEvent(XmlCommentEvent event) => null;

  /// Visit an [XmlDoctypeEvent] event.
  dynamic visitDoctypeEvent(XmlDoctypeEvent event) => null;

  /// Visit an [XmlEndElementEvent] event.
  dynamic visitEndElementEvent(XmlEndElementEvent event) => null;

  /// Visit an [XmlCommentEvent] event.
  dynamic visitProcessingEvent(XmlProcessingEvent event) => null;

  /// Visit an [XmlCommentEvent] event.
  dynamic visitStartElementEvent(XmlStartElementEvent event) => null;

  /// Visit an [XmlCommentEvent] event.
  dynamic visitTextEvent(XmlTextEvent event) => null;
}
