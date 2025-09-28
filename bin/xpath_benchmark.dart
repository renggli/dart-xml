// ignore_for_file: depend_on_referenced_packages

import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';
import 'benchmark.dart';

const sizes = [100, 1000, 10000];
const queries = [
  '//item',
  '//item/name',
  '/root/item/name',
  '//item[@id=100]',
  '//item[100]',
  '//*',
  '//*/name',
  '//*[@id=100]',
  '//*[100]',
];

XmlDocument createDocument(int size) => XmlDocument.build(
  (builder) => builder.element(
    'root',
    attributes: {'size': size.toString()},
    nest: () {
      for (var i = 0; i < size; i++) {
        builder.element(
          'item',
          nest: () {
            builder.attribute('id', '$i');
            builder.element('name', nest: 'Item $i');
            builder.element('value', nest: '$i');
            builder.element('description', nest: 'This is item number $i');
          },
        );
      }
    },
  ),
);

void main(List<String> args) {
  final documents = sizes.map(createDocument).toList();
  final report = XmlDocument.build(
    createReport(
      queries.map(
        (query) => createBenchmark(
          query,
          documents.map(
            (document) => createMeasure(
              document.rootElement.getAttribute('size')!,
              benchmark(() => document.xpath(query)),
            ),
          ),
        ),
      ),
    ),
  );
  printReport(report, xml: !args.contains('--no-xml'));
}
