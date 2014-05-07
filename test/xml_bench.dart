library xml_bench;

import 'package:xml/xml.dart';
import 'xml_examples.dart';

void main() {
  var parser = new XmlParser();
  var input = booksXml;

  var stopwatch = new Stopwatch();
  var count = 2000;

  stopwatch.start();
  for (var i = 0; i < count; i++) {
    parse(input);
  }
  stopwatch.stop();

  print('${stopwatch.elapsedMilliseconds / count}ms');
}
