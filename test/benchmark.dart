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
  builder.processing('xml', 'version="1.0"');
  builder.element('benchmarks', nest: () {
    for (final name in benchmarks.keys) {
      builder.element('measure', attributes: {'name': name}, nest: () {
        final source = benchmarks[name];
        final parser = benchmark(() => XmlDocument.parse(source));
        final events = benchmark(() => parseEvents(source).length);
        final speedup = percentChange(parser, events);
        builder.element('parser', nest: parser.toStringAsFixed(6));
        builder.element('events', nest: events.toStringAsFixed(6));
        builder.element('speedup', nest: speedup.toStringAsFixed(2));
      });
    }
  });
  print(builder.buildDocument().toXmlString(pretty: true));
}
