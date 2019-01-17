library xml_events.converters.dom;

import 'dart:convert';

import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:xml/xml.dart';

import '../event.dart';
import '../events/cdata_event.dart';
import '../events/comment_event.dart';
import '../events/doctype_event.dart';
import '../events/end_element_event.dart';
import '../events/processing_event.dart';
import '../events/start_element_event.dart';
import '../events/text_event.dart';
import '../visitor.dart';

/// A converter that incrementally builds a DOM from events.
class XmlDom extends Converter<List<XmlEvent>, List<XmlNode>> {
  const XmlDom();

  @override
  List<XmlElement> convert(List<XmlEvent> input) {
    final accumulator = AccumulatorSink<List<XmlNode>>();
    final converter = startChunkedConversion(accumulator);
    converter.add(input);
    converter.close();
    return accumulator.events.expand((list) => list).toList(growable: false);
  }

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<List<XmlNode>> sink) =>
      _XmlDomSink(sink);
}

/// A conversion sink for chunked [XmlEvent] encoding.
class _XmlDomSink extends ChunkedConversionSink<List<XmlEvent>>
    with XmlEventVisitor {
  _XmlDomSink(this.sink);

  final Sink<List<XmlNode>> sink;
  XmlElement parent;

  @override
  void add(List<XmlEvent> chunk) => chunk.forEach(visit);

  @override
  void visitCDATAEvent(XmlCDATAEvent event) => commit(XmlCDATA(event.text));

  @override
  void visitCommentEvent(XmlCommentEvent event) =>
      commit(XmlComment(event.text));

  @override
  void visitDoctypeEvent(XmlDoctypeEvent event) =>
      commit(XmlDoctype(event.text));

  @override
  void visitEndElementEvent(XmlEndElementEvent event) {
    if (parent == null) {
      throw XmlException('Unexpected </${event.name}>.');
    }
    if (parent.name.qualified != event.name) {
      throw XmlException(
          'Expected </${parent.name.qualified}>, but found </${event.name}>.');
    }
    if (!parent.hasParent) {
      sink.add([parent]);
    }
    parent = parent.parent;
  }

  @override
  void visitProcessingEvent(XmlProcessingEvent event) =>
      commit(XmlProcessing(event.target, event.text));

  @override
  void visitStartElementEvent(XmlStartElementEvent event) {
    final element = XmlElement(
      XmlName.fromString(event.name),
      event.attributes.map(
          (attr) => XmlAttribute(XmlName.fromString(attr.name), attr.value)),
      [],
      event.isSelfClosing,
    );
    if (event.isSelfClosing) {
      commit(element);
    } else {
      if (parent != null) {
        parent.children.add(element);
      }
      parent = element;
    }
  }

  @override
  void visitTextEvent(XmlTextEvent event) => commit(XmlText(event.text));

  @override
  void close() {
    if (parent != null) {
      throw XmlException('Missing closing </${parent.name.qualified}>');
    }
    sink.close();
  }

  void commit(XmlNode node) {
    if (parent == null) {
      sink.add(<XmlNode>[node]);
    } else {
      parent.children.add(node);
    }
  }
}
