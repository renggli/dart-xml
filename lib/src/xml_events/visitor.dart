library xml_events.visitor;

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
  void visit(XmlEvent event) => event.accept(this);

  /// Visit an [XmlCDATAEvent] event.
  void visitCDATAEvent(XmlCDATAEvent event);

  /// Visit an [XmlCommentEvent] event.
  void visitCommentEvent(XmlCommentEvent event);

  /// Visit an [XmlDoctypeEvent] event.
  void visitDoctypeEvent(XmlDoctypeEvent event);

  /// Visit an [XmlEndElementEvent] event.
  void visitEndElementEvent(XmlEndElementEvent event);

  /// Visit an [XmlCommentEvent] event.
  void visitProcessingEvent(XmlProcessingEvent event);

  /// Visit an [XmlCommentEvent] event.
  void visitStartElementEvent(XmlStartElementEvent event);

  /// Visit an [XmlCommentEvent] event.
  void visitTextEvent(XmlTextEvent event);
}
