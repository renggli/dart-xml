library xml_events.converters.node_encoder;

import 'dart:convert' show Converter, ChunkedConversionSink;

import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/events/cdata_event.dart';
import 'package:xml/src/xml_events/events/comment_event.dart';
import 'package:xml/src/xml_events/events/doctype_event.dart';
import 'package:xml/src/xml_events/events/end_element_event.dart';
import 'package:xml/src/xml_events/events/processing_event.dart';
import 'package:xml/src/xml_events/events/start_element_event.dart';
import 'package:xml/src/xml_events/events/text_event.dart';
import 'package:xml/xml.dart'
    show
        XmlCDATA,
        XmlComment,
        XmlDoctype,
        XmlElement,
        XmlNode,
        XmlProcessing,
        XmlText,
        XmlVisitor;

/// A converter that decodes a forest of [XmlNode] objects to a sequence of
/// [XmlEvent] objects.
class XmlNodeEncoder extends Converter<List<XmlNode>, List<XmlEvent>> {
  const XmlNodeEncoder();

  @override
  List<XmlEvent> convert(List<XmlNode> input) {
    final accumulator = AccumulatorSink<List<XmlEvent>>();
    final converter = startChunkedConversion(accumulator);
    converter.add(input);
    converter.close();
    return accumulator.events.expand((list) => list).toList(growable: false);
  }

  @override
  ChunkedConversionSink<List<XmlNode>> startChunkedConversion(
          Sink<List<XmlEvent>> sink) =>
      _XmlNodeEncoderSink(sink);
}

class _XmlNodeEncoderSink extends ChunkedConversionSink<List<XmlNode>>
    with XmlVisitor {
  _XmlNodeEncoderSink(this.sink);

  final Sink<List<XmlEvent>> sink;

  @override
  void add(List<XmlNode> chunk) => chunk.forEach(visit);

  @override
  void close() => sink.close();

  @override
  void visitElement(XmlElement node) {
    final isSelfClosing = node.isSelfClosing && node.children.isEmpty;
    sink.add([
      XmlStartElementEvent(
          node.name.qualified,
          node.attributes
              .map((attribute) => XmlElementAttribute(
                    attribute.name.qualified,
                    attribute.value,
                    attribute.attributeType,
                  ))
              .toList(growable: false),
          isSelfClosing)
    ]);
    if (!isSelfClosing) {
      node.children.forEach(visit);
      sink.add([XmlEndElementEvent(node.name.qualified)]);
    }
  }

  @override
  void visitCDATA(XmlCDATA node) => sink.add([XmlCDATAEvent(node.text)]);

  @override
  void visitComment(XmlComment node) => sink.add([XmlCommentEvent(node.text)]);

  @override
  void visitDoctype(XmlDoctype node) => sink.add([XmlDoctypeEvent(node.text)]);

  @override
  void visitProcessing(XmlProcessing node) =>
      sink.add([XmlProcessingEvent(node.target, node.text)]);

  @override
  void visitText(XmlText node) => sink.add([XmlTextEvent(node.text)]);
}
