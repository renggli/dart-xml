// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class XPathBenchmark extends BenchmarkBase {
  final XmlDocument document;
  final String expression;

  XPathBenchmark(this.document, this.expression) : super('XPath($expression)');

  @override
  void run() {
    document.xpath(expression);
  }

  @override
  void exercise() => run(); // Just run once per exercise
}

String _generateXml(int itemCount) {
  final buffer = StringBuffer();
  buffer.writeln('<root>');

  for (var i = 0; i < itemCount; i++) {
    buffer.writeln('  <item id="$i">');
    buffer.writeln('    <name>Item $i</name>');
    buffer.writeln('    <value>$i</value>');
    buffer.writeln('    <description>This is item number $i</description>');
    buffer.writeln('  </item>');
  }

  buffer.writeln('</root>');
  return buffer.toString();
}

void main(List<String> args) {
  var n = 1000;
  if (args.isNotEmpty) {
    n = int.parse(args[0]);
  }
  final xmlString = _generateXml(n);
  stdout.writeln('Generated XML with $n items.');
  final document = XmlDocument.parse(xmlString);
  XPathBenchmark(document, '//item').report();
  XPathBenchmark(document, '//item[100]').report();
  XPathBenchmark(document, '//*').report();
  XPathBenchmark(document, '//*[100]').report();
}
