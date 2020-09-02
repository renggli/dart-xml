import 'package:test/test.dart';

import 'assertions.dart';
import 'examples.dart';

void main() {
  test('books', () => assertDocumentParseInvariants(booksXml));
  test('bookstore', () => assertDocumentParseInvariants(bookstoreXml));
  test('atom', () => assertDocumentParseInvariants(atomXml));
  test('shiporder', () => assertDocumentParseInvariants(shiporderXsd));
  test('complicated', () => assertDocumentParseInvariants(complicatedXml));
  test('unicode', () => assertDocumentParseInvariants(unicodeXml));
}
