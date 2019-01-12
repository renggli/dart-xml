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
      _XmlEncoderSink(this, sink);
}

/// A conversion sink for chunked [XmlEvent] encoding.
class _XmlEncoderSink extends ChunkedConversionSink<List<XmlEvent>> {
  _XmlEncoderSink(this._encoder, this._sink);

  final XmlEncoder _encoder;
  final Sink<String> _sink;

  @override
  void add(List<XmlEvent> chunk) => _sink.add(_encoder.convert(chunk));

  @override
  void close() => _sink.close();
}
