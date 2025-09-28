// ignore_for_file: unnecessary_lambdas

import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../test/utils/examples.dart';
import 'benchmark.dart';

String characterData() {
  const string = '''a&bc<def"gehi'jklm>nopqr''';
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0"');
  builder.element(
    'character',
    nest: () {
      for (var i = 0; i < 20; i++) {
        builder.text('$string$string$string$string$string$string');
        builder.element(
          'foo',
          nest: () {
            builder.attribute('key', '$string$string$string$string');
          },
        );
      }
    },
  );
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

void main(List<String> args) {
  final report = XmlDocument.build(
    createReport(
      benchmarks.entries.map((entry) {
        final source = entry.value;
        final document = XmlDocument.parse(source);
        final parser = benchmark(() => XmlDocument.parse(source));
        final streamEvents = benchmark(() => XmlEventDecoder().convert(source));
        final streamNodes = benchmark(
          () =>
              const XmlNodeDecoder().convert(XmlEventDecoder().convert(source)),
        );
        final iterator = benchmark(() => parseEvents(source).toList());
        final serialize = benchmark(() => document.toXmlString());
        final serializePretty = benchmark(
          () => document.toXmlString(pretty: true),
        );
        return createBenchmark(entry.key, [
          createMeasure('parser', parser),
          createMeasure('streamEvents', streamEvents, parser),
          createMeasure('streamNodes', streamNodes, parser),
          createMeasure('iterator', iterator, parser),
          createMeasure('serialize', serialize),
          createMeasure('serializePretty', serializePretty, serialize),
        ]);
      }),
    ),
  );
  printReport(report, xml: !args.contains('--no-xml'));
}
