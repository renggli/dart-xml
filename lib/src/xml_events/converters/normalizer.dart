library xml_events.converters.normalizer;

import 'dart:convert' show Converter, ChunkedConversionSink;

import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/events/text_event.dart';

/// A converter that normalizes sequences of [XmlEvent]s, namely combines
/// adjacent and removes empty text events.
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

class _XmlNormalizerSink extends ChunkedConversionSink<List<XmlEvent>> {
  _XmlNormalizerSink(this.sink);

  final Sink<List<XmlEvent>> sink;
  final List<XmlEvent> buffer = <XmlEvent>[];

  @override
  void add(List<XmlEvent> chunk) {
    // Filter out empty text nodes.
    buffer.addAll(chunk.where((event) {
      if (event is XmlTextEvent) {
        return event.text.isNotEmpty;
      } else {
        return true;
      }
    }));
    // Merge adjacent text nodes.
    for (var i = 0; i < buffer.length - 1; i++) {
      final event1 = buffer[i + 0], event2 = buffer[i + 1];
      if (event1 is XmlTextEvent && event2 is XmlTextEvent) {
        buffer[i] = XmlTextEvent(event1.text + event2.text);
        buffer.removeAt(++i);
      }
    }
    // Move to sink whatever is possible.
    if (buffer.isNotEmpty) {
      if (buffer.last is XmlTextEvent) {
        sink.add(buffer.sublist(0, buffer.length - 1));
        buffer.removeRange(0, buffer.length - 1);
      } else {
        sink.add(buffer.toList(growable: false));
        buffer.clear();
      }
    }
  }

  @override
  void close() {
    if (buffer.isNotEmpty) {
      sink.add(buffer.toList(growable: false));
      buffer.clear();
    }
    sink.close();
  }
}
