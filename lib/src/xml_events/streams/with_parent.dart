import 'dart:convert' show ChunkedConversionSink;

import '../../xml/exceptions/tag_exception.dart';
import '../annotations/has_parent.dart';
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
import '../visitor.dart';

extension XmlWithParentEventsExtension on Stream<List<XmlEvent>> {
  /// Annotates a stream of [XmlEvent] objects with parent events. The parent
  /// events are thereafter accessible through [XmlHasParent.parent].
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
    Sink<List<XmlEvent>> sink,
  ) => _XmlWithParentEventsSink(sink);
}

class _XmlWithParentEventsSink
    with XmlEventVisitor
    implements ChunkedConversionSink<List<XmlEvent>> {
  _XmlWithParentEventsSink(this.sink);

  final Sink<List<XmlEvent>> sink;
  XmlStartElementEvent? currentParent;

  @override
  void add(List<XmlEvent> events) {
    events.forEach(visit);
    sink.add(events);
  }

  @override
  void close() {
    final parent = currentParent;
    if (parent != null) {
      throw XmlTagException.missingClosingTag(
        parent.name,
        buffer: parent.buffer,
        position: parent.start,
      );
    }
    sink.close();
  }

  @override
  void visitCDATAEvent(XmlCDATAEvent event) =>
      event.attachParent(currentParent);

  @override
  void visitCommentEvent(XmlCommentEvent event) =>
      event.attachParent(currentParent);

  @override
  void visitDeclarationEvent(XmlDeclarationEvent event) =>
      event.attachParent(currentParent);

  @override
  void visitDoctypeEvent(XmlDoctypeEvent event) =>
      event.attachParent(currentParent);

  @override
  void visitEndElementEvent(XmlEndElementEvent event) {
    final parent = currentParent;
    if (parent == null) {
      throw XmlTagException.unexpectedClosingTag(
        event.name,
        buffer: event.buffer,
        position: event.start,
      );
    } else if (parent.name != event.name) {
      throw XmlTagException.mismatchClosingTag(
        parent.name,
        event.name,
        buffer: event.buffer,
        position: event.start,
      );
    }
    event.attachParent(parent);
    currentParent = parent.parent;
  }

  @override
  void visitProcessingEvent(XmlProcessingEvent event) =>
      event.attachParent(currentParent);

  @override
  void visitStartElementEvent(XmlStartElementEvent event) {
    event.attachParent(currentParent);
    for (final attribute in event.attributes) {
      attribute.attachParent(event);
    }
    if (!event.isSelfClosing) {
      currentParent = event;
    }
  }

  @override
  void visitTextEvent(XmlTextEvent event) => event.attachParent(currentParent);
}
