library xml_events.converters.decoder;

import 'dart:convert';

import 'package:petitparser/petitparser.dart';

import '../event.dart';
import '../iterable.dart';
import '../parser.dart';

/// A converter that decodes [XmlEvent] objects from strings.
class XmlDecoder extends Converter<String, List<XmlEvent>> {
  const XmlDecoder();

  @override
  List<XmlEvent> convert(String input, [int start = 0, int end]) {
    end = RangeError.checkValidRange(start, end, input.length);
    return XmlEventIterable(input.substring(start, end))
        .toList(growable: false);
  }

  @override
  StringConversionSink startChunkedConversion(Sink<List<XmlEvent>> sink) =>
      _XmlDecoderSink(sink);
}

/// A conversion sink for chunked [XmlEvent] decoding.
class _XmlDecoderSink extends StringConversionSinkBase {
  _XmlDecoderSink(this.sink);

  final Sink<List<XmlEvent>> sink;

  String carry = '';

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      return;
    }
    final result = <XmlEvent>[];
    Result previous = Success(carry + str.substring(start, end), 0, null);
    for (;;) {
      final current = eventDefinitionParser.parseOn(previous);
      if (current.isSuccess) {
        result.add(current.value);
        previous = current;
      } else {
        carry = previous.buffer.substring(previous.position);
        break;
      }
    }
    if (result.isNotEmpty) {
      sink.add(result);
    }
    if (isLast) {
      sink.close();
    }
  }

  @override
  void close() => sink.close();
}
