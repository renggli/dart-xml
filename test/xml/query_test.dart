import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../utils/examples.dart';

void main() {
  group('elements', () {
    final bookstore = XmlDocument.parse(bookstoreXml).rootElement;
    final shiporder = XmlDocument.parse(shiporderXsd).rootElement;
    const xsd = 'http://www.w3.org/2001/XMLSchema';
    test('name defined, namespace undefined', () {
      final books = bookstore.findElements('book');
      expect(books, hasLength(2));
      final orders = shiporder.findElements('element');
      expect(orders, hasLength(0));
    });
    test('name defined, namespace wildcard', () {
      final books = bookstore.findElements('book', namespaceUri: '*');
      expect(books, hasLength(2));
      final orders = shiporder.findElements('element', namespaceUri: '*');
      expect(orders, hasLength(2));
    });
    test('name defined, namespace defined', () {
      final books = bookstore.findElements('book', namespaceUri: xsd);
      expect(books, hasLength(0));
      final orders = shiporder.findElements('element', namespaceUri: xsd);
      expect(orders, hasLength(2));
    });
    test('name wildcard, namespace undefined', () {
      final books = bookstore.findElements('*');
      expect(books, hasLength(2));
      final orders = shiporder.findElements('*');
      expect(orders, hasLength(7));
    });
    test('name wildcard, namespace wildcard', () {
      final books = bookstore.findElements('*', namespaceUri: '*');
      expect(books, hasLength(2));
      final orders = shiporder.findElements('*', namespaceUri: '*');
      expect(orders, hasLength(7));
    });
    test('name wildcard, namespace defined', () {
      final books = bookstore.findElements('*', namespaceUri: xsd);
      expect(books, hasLength(0));
      final orders = shiporder.findElements('*', namespaceUri: xsd);
      expect(orders, hasLength(7));
    });
  });
  group('all elements', () {
    final bookstore = XmlDocument.parse(bookstoreXml);
    final shiporder = XmlDocument.parse(shiporderXsd);
    const xsd = 'http://www.w3.org/2001/XMLSchema';
    test('name defined, namespace undefined', () {
      final books = bookstore.findAllElements('book');
      expect(books, hasLength(2));
      final orders = shiporder.findAllElements('element');
      expect(orders, hasLength(0));
    });
    test('name defined, namespace wildcard', () {
      final books = bookstore.findAllElements('book', namespaceUri: '*');
      expect(books, hasLength(2));
      final orders = shiporder.findAllElements('element', namespaceUri: '*');
      expect(orders, hasLength(17));
    });
    test('name defined, namespace defined', () {
      final books = bookstore.findAllElements('book', namespaceUri: xsd);
      expect(books, hasLength(0));
      final orders = shiporder.findAllElements('element', namespaceUri: xsd);
      expect(orders, hasLength(17));
    });
    test('name wildcard, namespace undefined', () {
      final books = bookstore.findAllElements('*');
      expect(books, hasLength(7));
      final orders = shiporder.findAllElements('*');
      expect(orders, hasLength(37));
    });
    test('name wildcard, namespace wildcard', () {
      final books = bookstore.findAllElements('*', namespaceUri: '*');
      expect(books, hasLength(7));
      final orders = shiporder.findAllElements('*', namespaceUri: '*');
      expect(orders, hasLength(37));
    });
    test('name wildcard, namespace defined', () {
      final books = bookstore.findAllElements('*', namespaceUri: xsd);
      expect(books, hasLength(0));
      final orders = shiporder.findAllElements('*', namespaceUri: xsd);
      expect(orders, hasLength(37));
    });
  });
}
