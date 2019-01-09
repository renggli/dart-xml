library xml_events.encoder;

import 'dart:convert';

import 'event.dart';

/// Encodes an [Iterable] of [XmlEvent] objects to a [String].
class XmlEncoder extends Converter<Iterable<XmlEvent>, String> {
  const XmlEncoder();

  @override
  String convert(Iterable<XmlEvent> input) {
    final buffer = StringBuffer();
    for (var event in input) {
      event.encode(buffer);
    }
    return buffer.toString();
  }

  @override
  ChunkedConversionSink<Iterable<XmlEvent>> startChunkedConversion(
          Sink<String> sink) =>
      XmlEncoderSink(this, sink);
}

class XmlEncoderSink extends ChunkedConversionSink<Iterable<XmlEvent>> {
  XmlEncoderSink(this.encoder, this.sink);

  final XmlEncoder encoder;
  final Sink<String> sink;

  @override
  void add(Iterable<XmlEvent> chunk) => sink.add(encoder.convert(chunk));

  @override
  void close() => sink.close();
}
