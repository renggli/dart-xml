library xml_events.visitor;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/events/cdata_event.dart';
import 'package:xml/src/xml_events/events/comment_event.dart';
import 'package:xml/src/xml_events/events/doctype_event.dart';
import 'package:xml/src/xml_events/events/end_element_event.dart';
import 'package:xml/src/xml_events/events/processing_event.dart';
import 'package:xml/src/xml_events/events/start_element_event.dart';
import 'package:xml/src/xml_events/events/text_event.dart';

/// Basic visitor over [XmlEvent] nodes.
mixin XmlEventVisitor {
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
