import 'dart:convert' show Converter;

import 'package:convert/convert.dart' show AccumulatorSink;
import 'package:meta/meta.dart';

import '../../xml/utils/flatten.dart';

abstract class XmlListConverter<S, T> extends Converter<List<S>, List<T>> {
  const XmlListConverter();

  @override
  @nonVirtual
  List<T> convert(List<S> input) {
    final accumulator = AccumulatorSink<List<T>>();
    final converter = startChunkedConversion(accumulator);
    converter.add(input);
    converter.close();
    return accumulator.events.flatten().toList(growable: false);
  }
}
