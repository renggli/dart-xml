library xml.test.benchmark;

import 'package:xml/xml.dart';

import 'examples.dart';

double benchmark(Function function, [int warmUp = 5, int milliseconds = 2500]) {
  final watch = Stopwatch();
  var count = 0;
  var elapsed = 0;
  while (warmUp-- > 0) {
    function();
  }
  watch.start();
  while (elapsed < milliseconds) {
    function();
    elapsed = watch.elapsedMilliseconds;
    count++;
  }
  return elapsed / count;
}

String characterData() {
  final string = '''a&bc<def"gehi'jklm>nopqr''';
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
  return builder.build().toString();
}

final benchmarks = <String, String>{
  'books': booksXml,
  'bookstore': bookstoreXml,
  'atom': atomXml,
  'shiporder': shiporderXsd,
  'decoding': characterData(),
};

void main() {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0"');
  builder.element('benchmarks', nest: () {
    for (var name in benchmarks.keys) {
      builder.element(name, nest: () {
        final source = benchmarks[name];
        builder.text(benchmark(() => parse(source)));
      });
    }
  });
  print(builder.build().toXmlString(pretty: true));
}
