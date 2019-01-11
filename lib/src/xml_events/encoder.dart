library xml_events.encoder;

import 'dart:convert';

import 'event.dart';

/// A converter that encodes [XmlEvent] iterables into strings.
class XmlEncoder extends Converter<List<XmlEvent>, String> {
  const XmlEncoder();

  @override
  String convert(List<XmlEvent> input) {
    final buffer = StringBuffer();
    for (var event in input) {
      event.encode(buffer);
    }
    return buffer.toString();
  }

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<String> sink) =>
      XmlEncoderSink(this, sink);
}

/// A conversion sink for chunked [XmlEvent] encoding.
class XmlEncoderSink extends ChunkedConversionSink<List<XmlEvent>> {
  XmlEncoderSink(this.encoder, this.sink);

  final XmlEncoder encoder;
  final Sink<String> sink;

  @override
  void add(List<XmlEvent> chunk) => sink.add(encoder.convert(chunk));

  @override
  void close() => sink.close();
}
