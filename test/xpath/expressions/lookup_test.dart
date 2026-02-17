import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<r><a>1</a><b>2</b></r>');

  group('lookup', () {
    test('array ? integer', () {
      expectEvaluate(xml, '[4, 5, 6]?2', [5]);
    });
    test('array ? *', () {
      expectEvaluate(xml, '[4, 5, 6]?*', [4, 5, 6]);
    });
    test('map ? NCName', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2}?a', [1]);
    });
    test('map ? integer key', () {
      expectEvaluate(xml, 'map {1: "x", 2: "y"}?1', ['x']);
    });
    test('map ? *', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2}?*', [1, 2]);
    });
    test('map ? parenthesized expression', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2}?("a")', [1]);
    });
  });
}
