import 'dart:io';
import 'package:xml/xml.dart';

/// Measures the time it takes to run [function] in microseconds.
///
/// It does so in two steps:
///
///  - the code is warmed up for the duration of [warmup]; and
///  - the code is benchmarked for the duration of [measure].
///
/// The resulting duration is the average time measured to run [function] once.
double benchmark(
  void Function() function, {
  Duration warmup = const Duration(milliseconds: 200),
  Duration measure = const Duration(seconds: 2),
}) {
  _benchmark(function, warmup);
  return _benchmark(function, measure);
}

double _benchmark(void Function() function, Duration duration) {
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

/// Creates a factory function for benchmark reports.
void Function(XmlBuilder) createReport(Iterable<Object?> benchmarks) =>
    (builder) {
      builder.processing('xml', 'version="1.0"');
      builder.element('benchmarks', nest: benchmarks);
    };

/// Creates a factory function for a single benchmark entry.
void Function(XmlBuilder) createBenchmark(
  String name,
  Iterable<Object?> measures,
) =>
    (builder) => builder.element(
      'benchmark',
      attributes: {'name': name},
      nest: measures,
    );

/// Creates a factory function for a single measure entry.
void Function(XmlBuilder) createMeasure(
  String name,
  double measure, [
  double? reference,
]) =>
    (builder) => builder.element(
      'measure',
      attributes: {'name': name},
      nest: () {
        builder.element('time', nest: measure.toStringAsFixed(6));
        if (reference != null) {
          final speedup = percentChange(reference, measure);
          builder.element('speedup', nest: speedup.toStringAsFixed(2));
        }
      },
    );

/// Prints the results of the benchmark document to the console.
void printReport(XmlDocument document, {bool xml = true}) {
  if (xml) {
    stdout.writeln(document.toXmlString(pretty: true));
  } else {
    stdout.writeln(
      [
        '',
        ...document
            .findAllElements('benchmark')
            .first
            .findAllElements('measure')
            .map((measure) => measure.getAttribute('name')),
      ].join(';'),
    );
    stdout.write(
      document
          .findAllElements('benchmark')
          .map(
            (benchmark) => [
              benchmark.getAttribute('name'),
              ...benchmark
                  .findAllElements('time')
                  .map((time) => time.innerText),
            ].join(';'),
          )
          .join('\n'),
    );
  }
}
