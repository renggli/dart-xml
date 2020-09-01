import 'dart:convert' show ChunkedConversionSink;

import '../converters/list_converter.dart';
import '../event.dart';
import '../events/text.dart';

extension XmlNormalizerExtension on Stream<List<XmlEvent>> {
  /// Normalizes a sequence of [XmlEvent] objects by removing empty and
  /// combining adjacent text events.
  Stream<List<XmlEvent>> normalizeEvents() => transform(const XmlNormalizer());
}

/// A converter that normalizes sequences of [XmlEvent] objects, namely combines
/// adjacent and removes empty text events.
class XmlNormalizer extends XmlListConverter<XmlEvent, XmlEvent> {
  const XmlNormalizer();

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
