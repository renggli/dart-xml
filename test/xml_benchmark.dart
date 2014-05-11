library xml_benchmark;

import 'package:xml/xml.dart';
import 'xml_examples.dart';

double benchmark(Function function, [int milliseconds = 2500]) {
  var count = 0;
  var elapsed = 0;
  var watch = new Stopwatch();
  watch.start();
  while (elapsed < milliseconds) {
    function();
    elapsed = watch.elapsedMilliseconds;
    count++;
  }
  return elapsed / count;
}

void parsing() {
  parse(booksXml);
}

void main() {
  print('Parsing: ${benchmark(parsing)}ms');
}
