import 'dart:convert' show ChunkedConversionSink;

import '../../xml/utils/exceptions.dart';
import '../event.dart';
import '../events/cdata.dart';
import '../events/comment.dart';
import '../events/declaration.dart';
import '../events/doctype.dart';
import '../events/end_element.dart';
import '../events/processing.dart';
import '../events/start_element.dart';
import '../events/text.dart';
import '../utils/list_converter.dart';
import '../utils/parented.dart';
import '../visitor.dart';

extension XmlWithParentEventsExtension on Stream<List<XmlEvent>> {
  /// Annotates a stream of [XmlEvent] objects with parent events. The parent
  /// events are thereafter accessible through [XmlParented.parentEvent].
  ///
  /// [XmlEndElementEvent] are parented to their corresponding
  /// [XmlStartElementEvent]. Throws an [XmlTagException] is the nesting
  /// is invalid.
  Stream<List<XmlEvent>> withParentEvents() =>
      transform(const XmlWithParentEvents());
}

/// A converter that annotates [XmlEvent] objects with their parent events.
class XmlWithParentEvents extends XmlListConverter<XmlEvent, XmlEvent> {
  const XmlWithParentEvents();

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<List<XmlEvent>> sink) =>
      _XmlWithParentEventsSink(sink);
}

class _XmlWithParentEventsSink extends ChunkedConversionSink<List<XmlEvent>>
    with XmlEventVisitor {
  final Sink<List<XmlEvent>> sink;

  XmlStartElementEvent? currentParent;

  _XmlWithParentEventsSink(this.sink);

  @override
  void add(List<XmlEvent> events) {
    events.forEach(visit);
    sink.add(events);
  }

  @override
  void close() {
    if (currentParent != null) {
      throw XmlTagException.missingClosingTag(currentParent!.name);
    }
    sink.close();
  }

  @override
  void visitCDATAEvent(XmlCDATAEvent event) =>
      event.attachParentEvent(currentParent);

  @override
  void visitCommentEvent(XmlCommentEvent event) =>
      event.attachParentEvent(currentParent);

  @override
  void visitDeclarationEvent(XmlDeclarationEvent event) =>
      event.attachParentEvent(currentParent);

  @override
  void visitDoctypeEvent(XmlDoctypeEvent event) =>
      event.attachParentEvent(currentParent);

  @override
  void visitEndElementEvent(XmlEndElementEvent event) {
    if (currentParent == null) {
      throw XmlTagException.unexpectedClosingTag(event.name);
    } else if (currentParent!.name != event.name) {
      throw XmlTagException.mismatchClosingTag(currentParent!.name, event.name);
    }
    event.attachParentEvent(currentParent);
    currentParent = currentParent!.parentEvent;
  }

  @override
  void visitProcessingEvent(XmlProcessingEvent event) =>
      event.attachParentEvent(currentParent);

  @override
  void visitStartElementEvent(XmlStartElementEvent event) {
    event.attachParentEvent(currentParent);
    for (final attribute in event.attributes) {
      attribute.attachParentEvent(event);
    }
    if (!event.isSelfClosing) {
      currentParent = event;
    }
  }

  @override
  void visitTextEvent(XmlTextEvent event) =>
      event.attachParentEvent(currentParent);
}
