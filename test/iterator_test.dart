library xml.test.iterator_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'examples.dart';

void main() {
  test('example', () {
    final iterator = XmlIterator(bookstoreXml);
    while (iterator.moveNext()) {
      print(iterator.current);
    }
  });
}
