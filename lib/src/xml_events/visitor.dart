import 'event.dart';
import 'events/cdata.dart';
import 'events/comment.dart';
import 'events/declaration.dart';
import 'events/doctype.dart';
import 'events/end_element.dart';
import 'events/processing.dart';
import 'events/start_element.dart';
import 'events/text.dart';

/// Basic visitor over [XmlEvent] nodes.
mixin XmlEventVisitor {
  /// Dispatches the provided [event] onto this visitor.
  void visit(XmlEvent event) => event.accept(this);

  /// Visits an [XmlCDATAEvent] event.
  void visitCDATAEvent(XmlCDATAEvent event) {}

  /// Visits an [XmlCommentEvent] event.
  void visitCommentEvent(XmlCommentEvent event) {}

  /// Visits an [XmlDeclarationEvent] event.
  void visitDeclarationEvent(XmlDeclarationEvent event) {}

  /// Visits an [XmlDoctypeEvent] event.
  void visitDoctypeEvent(XmlDoctypeEvent event) {}

  /// Visits an [XmlEndElementEvent] event.
  void visitEndElementEvent(XmlEndElementEvent event) {}

  /// Visits an [XmlProcessingEvent] event.
  void visitProcessingEvent(XmlProcessingEvent event) {}

  /// Visits an [XmlStartElementEvent] event.
  void visitStartElementEvent(XmlStartElementEvent event) {}

  /// Visits an [XmlTextEvent] event.
  void visitTextEvent(XmlTextEvent event) {}
}
