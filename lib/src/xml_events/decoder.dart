library xml_events.decoder;

import 'dart:convert';

import 'package:petitparser/petitparser.dart';

import 'event.dart';
import 'iterable.dart';
import 'parser.dart';

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
  StringConversionSink startChunkedConversion(Sink<List<XmlEvent>> sink) =>
      _XmlDecoderSink(sink);
}

/// A conversion sink for chunked [XmlEvent] decoding.
class _XmlDecoderSink extends StringConversionSinkBase {
  _XmlDecoderSink(this._sink);

  final Sink<List<XmlEvent>> _sink;

  String _carry = '';

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      return;
    }
    final result = <XmlEvent>[];
    Result previous = Success(_carry + str.substring(start, end), 0, null);
    for (;;) {
      final current = eventDefinitionParser.parseOn(previous);
      if (current.isSuccess) {
        result.add(current.value);
        previous = current;
      } else {
        _carry = previous.buffer.substring(previous.position);
        break;
      }
    }
    if (result.isNotEmpty) {
      _sink.add(result);
    }
    if (isLast) {
      _sink.close();
    }
  }

  @override
  void close() => _sink.close();
}
