library xml.test.example_test;

import 'package:test/test.dart';

import 'assertions.dart';
import 'examples.dart';

void main() {
  test('books', () => assertParseInvariants(booksXml));
  test('bookstore', () => assertParseInvariants(bookstoreXml));
  test('atom', () => assertParseInvariants(atomXml));
  test('shiporder', () => assertParseInvariants(shiporderXsd));
  test('complicated', () => assertParseInvariants(complicatedXml));
}
