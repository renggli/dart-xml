library xml.test.query_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'examples.dart';

void main() {
  group('elements', () {
    var bookstore = parse(bookstoreXml).rootElement;
    var shiporder = parse(shiporderXsd).rootElement;
    var xsd = 'http://www.w3.org/2001/XMLSchema';
    test('invalid', () {
      expect(() => bookstore.findElements(null), throwsArgumentError);
    });
    test('name defined, namespace undefined', () {
      var books = bookstore.findElements('book');
      expect(books.length, 2);
      var orders = shiporder.findElements('element');
      expect(orders.length, 0);
    });
    test('name defined, namespace wildcard', () {
      var books = bookstore.findElements('book', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findElements('element', namespace: '*');
      expect(orders.length, 2);
    });
    test('name defined, namespace defined', () {
      var books = bookstore.findElements('book', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findElements('element', namespace: xsd);
      expect(orders.length, 2);
    });
    test('name wildcard, namespace undefined', () {
      var books = bookstore.findElements('*');
      expect(books.length, 2);
      var orders = shiporder.findElements('*');
      expect(orders.length, 7);
    });
    test('name wildcard, namespace wildcard', () {
      var books = bookstore.findElements('*', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findElements('*', namespace: '*');
      expect(orders.length, 7);
    });
    test('name wildcard, namespace defined', () {
      var books = bookstore.findElements('*', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findElements('*', namespace: xsd);
      expect(orders.length, 7);
    });
  });
  group('all elements', () {
    var bookstore = parse(bookstoreXml);
    var shiporder = parse(shiporderXsd);
    var xsd = 'http://www.w3.org/2001/XMLSchema';
    test('invalid', () {
      expect(() => bookstore.findAllElements(null), throwsArgumentError);
    });
    test('name defined, namespace undefined', () {
      var books = bookstore.findAllElements('book');
      expect(books.length, 2);
      var orders = shiporder.findAllElements('element');
      expect(orders.length, 0);
    });
    test('name defined, namespace wildcard', () {
      var books = bookstore.findAllElements('book', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findAllElements('element', namespace: '*');
      expect(orders.length, 17);
    });
    test('name defined, namespace defined', () {
      var books = bookstore.findAllElements('book', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findAllElements('element', namespace: xsd);
      expect(orders.length, 17);
    });
    test('name wildcard, namespace undefined', () {
      var books = bookstore.findAllElements('*');
      expect(books.length, 7);
      var orders = shiporder.findAllElements('*');
      expect(orders.length, 37);
    });
    test('name wildcard, namespace wildcard', () {
      var books = bookstore.findAllElements('*', namespace: '*');
      expect(books.length, 7);
      var orders = shiporder.findAllElements('*', namespace: '*');
      expect(orders.length, 37);
    });
    test('name wildcard, namespace defined', () {
      var books = bookstore.findAllElements('*', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findAllElements('*', namespace: xsd);
      expect(orders.length, 37);
    });
  });
}
