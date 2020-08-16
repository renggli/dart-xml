library xml_events.converters.node_encoder;

import 'dart:convert' show ChunkedConversionSink;

import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/declaration.dart';
import '../../xml/nodes/doctype.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/node_list.dart';
import '../../xml/visitors/visitor.dart';
import '../event.dart';
import '../events/cdata_event.dart';
import '../events/comment_event.dart';
import '../events/declaration_event.dart';
import '../events/doctype_event.dart';
import '../events/end_element_event.dart';
import '../events/event_attribute.dart';
import '../events/processing_event.dart';
import '../events/start_element_event.dart';
import '../events/text_event.dart';
import 'list_converter.dart';

extension XmlNodeEncoderExtension on Stream<List<XmlNode>> {
  /// Converts a sequence of [XmlNode] objects to [XmlEvent] objects.
  Stream<List<XmlEvent>> toXmlEvents() => transform(const XmlNodeEncoder());
}

/// A converter that encodes a forest of [XmlNode] objects to a sequence of
/// [XmlEvent] objects.
class XmlNodeEncoder extends XmlListConverter<XmlNode, XmlEvent> {
  const XmlNodeEncoder();

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
      XmlStartElementEvent(node.name.qualified,
          convertAttributes(node.attributes), isSelfClosing)
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
  void visitDeclaration(XmlDeclaration node) =>
      sink.add([XmlDeclarationEvent(convertAttributes(node.attributes))]);

  @override
  void visitDoctype(XmlDoctype node) => sink.add([XmlDoctypeEvent(node.text)]);

  @override
  void visitProcessing(XmlProcessing node) =>
      sink.add([XmlProcessingEvent(node.target, node.text)]);

  @override
  void visitText(XmlText node) => sink.add([XmlTextEvent(node.text)]);

  List<XmlEventAttribute> convertAttributes(
          XmlNodeList<XmlAttribute> attributes) =>
      attributes
          .map((attribute) => XmlEventAttribute(
                attribute.name.qualified,
                attribute.value,
                attribute.attributeType,
              ))
          .toList(growable: false);
}
