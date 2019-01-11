library xml_events.decoder;

import 'dart:convert';

import 'event.dart';
import 'iterable.dart';

/// A converter that decodes [XmlEvent] objects from strings.
class XmlDecoder extends Converter<String, List<XmlEvent>> {
  const XmlDecoder();

  @override
  List<XmlEvent> convert(String input, [int start = 0, int end]) {
    end = RangeError.checkValidRange(start, end, input.length);
    if (start == end) {
      return <XmlEvent>[];
    }
    return XmlEventIterable(input.substring(start, end))
        .toList(growable: false);
  }

  @override
  StringConversionSink startChunkedConversion(Sink<Iterable<XmlEvent>> sink) =>
      XmlDecoderSink(this, sink);
}

/// A conversion sink for chunked [XmlEvent] decoding.
class XmlDecoderSink extends StringConversionSinkBase {
  XmlDecoderSink(this.decoder, this.sink);

  final XmlDecoder decoder;
  final Sink<Iterable<XmlEvent>> sink;

  StringBuffer buffer = StringBuffer();

  @override
  void add(String str) {
    if (str.isEmpty) {
      return;
    }
    buffer.write(str);
    sink.add(decoder.convert(buffer.toString()));
    buffer.clear();
  }

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      return;
    }
    buffer.write(str.substring(start, end));
    sink.add(decoder.convert(buffer.toString()));
    buffer.clear();
    if (isLast) {
      sink.close();
    }
  }

  @override
  void close() => sink.close();
}
