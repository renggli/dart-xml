import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'examples.dart';

/// Measures the time it takes to run [function] in microseconds.
///
/// It does so in two steps:
///
///  - the code is warmed up for the duration of [warmup]; and
///  - the code is benchmarked for the duration of [measure].
///
/// The resulting duration is the average time measured to run [function] once.
double benchmark(Function function,
    {Duration warmup = const Duration(milliseconds: 200),
    Duration measure = const Duration(seconds: 2)}) {
  _benchmark(function, warmup);
  return _benchmark(function, measure);
}

double _benchmark(Function function, Duration duration) {
  final watch = Stopwatch();
  final micros = duration.inMicroseconds;
  var count = 0;
  var elapsed = 0;
  watch.start();
  while (elapsed < micros) {
    function();
    elapsed = watch.elapsedMicroseconds;
    count++;
  }
  return elapsed / count;
}

/// Compare the speedup between [reference] and [comparison] in percentage.
///
/// A result of 0 means that both reference and comparison run at the same
/// speed. A positive number signifies a speedup, a negative one a slowdown.
double percentChange(double reference, double comparison) =>
    100 * (reference - comparison) / reference;

String characterData() {
  const string = '''a&bc<def"gehi'jklm>nopqr''';
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0"');
  builder.element('character', nest: () {
    for (var i = 0; i < 20; i++) {
      builder.text('$string$string$string$string$string$string');
      builder.element('foo', nest: () {
        builder.attribute('key', '$string$string$string$string');
      });
    }
  });
  return builder.buildDocument().toString();
}

final Map<String, String> benchmarks = {
  'atom': atomXml,
  'books': booksXml,
  'bookstore': bookstoreXml,
  'complicated': complicatedXml,
  'shiporder': shiporderXsd,
  'decoding': characterData(),
};

void main() {
  final builder = XmlBuilder();
  addBenchmarks(builder);
  print(builder.buildDocument().toXmlString(pretty: true));
}

void addBenchmarks(XmlBuilder builder) {
  builder.processing('xml', 'version="1.0"');
  builder.element('benchmarks', nest: () {
    for (final entry in benchmarks.entries) {
      addBenchmark(builder, entry);
    }
  });
}

void addBenchmark(XmlBuilder builder, MapEntry<String, String> entry) {
  builder.element('benchmark', attributes: {'name': entry.key}, nest: () {
    final source = entry.value;
    final parser = benchmark(() => XmlDocument.parse(source));
    final stream = benchmark(() => XmlEventDecoder().convert(source));
    final iterator = benchmark(() => parseEvents(source).toList());
    addMeasure(builder, 'parser', parser);
    addMeasure(builder, 'stream', stream, parser);
    addMeasure(builder, 'iterator', iterator, parser);
  });
}

void addMeasure(XmlBuilder builder, String name, double measure,
    [double? reference]) {
  builder.element('measure', attributes: {'name': name}, nest: () {
    builder.element('time', nest: measure.toStringAsFixed(6));
    if (reference != null) {
      final speedup = percentChange(reference, measure);
      builder.element('speedup', nest: speedup.toStringAsFixed(2));
    }
  });
}
