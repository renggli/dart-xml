library xml_events.converter.normalizer;

import 'dart:convert';

import 'package:convert/convert.dart';

import '../event.dart';
import '../event/text_event.dart';

/// A converter that encodes [XmlEvent] iterables into strings.
class XmlNormalizer extends Converter<List<XmlEvent>, List<XmlEvent>> {
  const XmlNormalizer();

  @override
  List<XmlEvent> convert(List<XmlEvent> input) {
    final accumulator = AccumulatorSink<List<XmlEvent>>();
    final converter = startChunkedConversion(accumulator);
    converter.add(input);
    converter.close();
    return accumulator.events.expand((list) => list).toList(growable: false);
  }

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<List<XmlEvent>> sink) =>
      _XmlNormalizerSink(sink);
}

/// A conversion sink for chunked [XmlEvent] encoding.
class _XmlNormalizerSink extends ChunkedConversionSink<List<XmlEvent>> {
  _XmlNormalizerSink(this._sink);

  final Sink<List<XmlEvent>> _sink;
  final List<XmlEvent> _buffer = <XmlEvent>[];

  @override
  void add(List<XmlEvent> chunk) {
    // Filter out empty text nodes.
    _buffer.addAll(chunk.where((event) {
      if (event is XmlTextEvent) {
        return event.text.isNotEmpty;
      } else {
        return true;
      }
    }));
    // Merge adjacent text nodes.
    for (var i = 0; i < _buffer.length - 1; i++) {
      final event1 = _buffer[i + 0], event2 = _buffer[i + 1];
      if (event1 is XmlTextEvent && event2 is XmlTextEvent) {
        _buffer[i] = XmlTextEvent(event1.text + event2.text);
        _buffer.removeAt(++i);
      }
    }
    // Move to sink whatever is possible.
    if (_buffer.isNotEmpty) {
      if (_buffer.last is XmlTextEvent) {
        _sink.add(_buffer.sublist(0, _buffer.length - 1));
        _buffer.removeRange(0, _buffer.length - 1);
      } else {
        _sink.add(_buffer.toList(growable: false));
        _buffer.clear();
      }
    }
  }

  @override
  void close() {
    if (_buffer.isNotEmpty) {
      _sink.add(_buffer.toList(growable: false));
      _buffer.clear();
    }
    _sink.close();
  }
}
