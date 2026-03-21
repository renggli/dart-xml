import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
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

  group('unary lookup', () {
    test('array ? integer', () {
      expectEvaluate(xml, '[4, 5, 6] ! ?2', [5]);
    });
    test('array ? *', () {
      expectEvaluate(xml, '[4, 5, 6] ! ?*', [4, 5, 6]);
    });
    test('array index out of bounds', () {
      expect(
        () => xml.xpathEvaluate('[4, 5, 6] ! ?4'),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 4'),
        ),
      );
    });
    test('map ? NCName', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2} ! ?a', [1]);
    });
    test('map ? *', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2} ! ?*', [1, 2]);
    });
    test('map ? missing key', () {
      expectEvaluate(xml, 'map {"a": 1} ! ?b', isEmpty);
    });
    test('invalid type', () {
      expect(
        () => xml.xpathEvaluate('1 ! ?*'),
        throwsA(
          isXPathEvaluationException(
            message: 'Lookup requires a map or array, but got int',
          ),
        ),
      );
    });
    test('invalid type with key', () {
      expect(
        () => xml.xpathEvaluate('1 ! ?a'),
        throwsA(
          isXPathEvaluationException(
            message: 'Lookup requires a map or array, but got int',
          ),
        ),
      );
    });
  });
}
