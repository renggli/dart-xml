import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../utils/examples.dart';

void main() {
  group('elements', () {
    final bookstore = XmlDocument.parse(bookstoreXml).rootElement;
    final shiporder = XmlDocument.parse(shiporderXsd).rootElement;
    const xsd = 'http://www.w3.org/2001/XMLSchema';
    test('name defined, namespace undefined', () {
      final books = bookstore.findElements('book');
      check(books).length.equals(2);
      final orders = shiporder.findElements('element');
      check(orders).length.equals(0);
    });
    test('name defined, namespace wildcard', () {
      final books = bookstore.findElements('book', namespaceUri: '*');
      check(books).length.equals(2);
      final orders = shiporder.findElements('element', namespaceUri: '*');
      check(orders).length.equals(2);
    });
    test('name defined, namespace defined', () {
      final books = bookstore.findElements('book', namespaceUri: xsd);
      check(books).length.equals(0);
      final orders = shiporder.findElements('element', namespaceUri: xsd);
      check(orders).length.equals(2);
    });
    test('name wildcard, namespace undefined', () {
      final books = bookstore.findElements('*');
      check(books).length.equals(2);
      final orders = shiporder.findElements('*');
      check(orders).length.equals(7);
    });
    test('name wildcard, namespace wildcard', () {
      final books = bookstore.findElements('*', namespaceUri: '*');
      check(books).length.equals(2);
      final orders = shiporder.findElements('*', namespaceUri: '*');
      check(orders).length.equals(7);
    });
    test('name wildcard, namespace defined', () {
      final books = bookstore.findElements('*', namespaceUri: xsd);
      check(books).length.equals(0);
      final orders = shiporder.findElements('*', namespaceUri: xsd);
      check(orders).length.equals(7);
    });
  });
  group('all elements', () {
    final bookstore = XmlDocument.parse(bookstoreXml);
    final shiporder = XmlDocument.parse(shiporderXsd);
    const xsd = 'http://www.w3.org/2001/XMLSchema';
    test('name defined, namespace undefined', () {
      final books = bookstore.findAllElements('book');
      check(books).length.equals(2);
      final orders = shiporder.findAllElements('element');
      check(orders).length.equals(0);
    });
    test('name defined, namespace wildcard', () {
      final books = bookstore.findAllElements('book', namespaceUri: '*');
      check(books).length.equals(2);
      final orders = shiporder.findAllElements('element', namespaceUri: '*');
      check(orders).length.equals(17);
    });
    test('name defined, namespace defined', () {
      final books = bookstore.findAllElements('book', namespaceUri: xsd);
      check(books).length.equals(0);
      final orders = shiporder.findAllElements('element', namespaceUri: xsd);
      check(orders).length.equals(17);
    });
    test('name wildcard, namespace undefined', () {
      final books = bookstore.findAllElements('*');
      check(books).length.equals(7);
      final orders = shiporder.findAllElements('*');
      check(orders).length.equals(37);
    });
    test('name wildcard, namespace wildcard', () {
      final books = bookstore.findAllElements('*', namespaceUri: '*');
      check(books).length.equals(7);
      final orders = shiporder.findAllElements('*', namespaceUri: '*');
      check(orders).length.equals(37);
    });
    test('name wildcard, namespace defined', () {
      final books = bookstore.findAllElements('*', namespaceUri: xsd);
      check(books).length.equals(0);
      final orders = shiporder.findAllElements('*', namespaceUri: xsd);
      check(orders).length.equals(37);
    });
  });
}
