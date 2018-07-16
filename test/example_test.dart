library xml.test.example_test;

import 'package:test/test.dart';

import 'assertions.dart';
import 'examples.dart';

void main() {
  test('books', () => assetParseInvariants(booksXml));
  test('bookstore', () => assetParseInvariants(bookstoreXml));
  test('atom', () => assetParseInvariants(atomXml));
  test('shiporder', () => assetParseInvariants(shiporderXsd));
}
