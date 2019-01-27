library xml_events.converters.event_decoder;

import 'dart:convert'
    show Converter, StringConversionSink, StringConversionSinkBase;

import 'package:petitparser/petitparser.dart' show Success, Result;
import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/iterable.dart';
import 'package:xml/src/xml_events/parser.dart';
import 'package:xml/xml.dart' show XmlParserException;

/// A converter that decodes a [String] to a sequence of [XmlEvent] objects.
class XmlEventDecoder extends Converter<String, List<XmlEvent>> {
  const XmlEventDecoder();

  @override
  List<XmlEvent> convert(String input, [int start = 0, int end]) {
    end = RangeError.checkValidRange(start, end, input.length);
    return XmlEventIterable(input.substring(start, end))
        .toList(growable: false);
  }

  @override
  StringConversionSink startChunkedConversion(Sink<List<XmlEvent>> sink) =>
      _XmlEventDecoderSink(sink);
}

class _XmlEventDecoderSink extends StringConversionSinkBase {
  _XmlEventDecoderSink(this.sink);

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
      close();
    }
  }

  @override
  void close() {
    if (carry.isNotEmpty) {
      throw XmlParserException('Unable to parse remaining input: $carry', 0, 0);
    }
    sink.close();
  }
}
