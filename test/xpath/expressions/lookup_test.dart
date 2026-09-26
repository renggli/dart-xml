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
    test('map ? key sequence of length > 1', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2, "c": 3}?("a", "c")', [1, 3]);
    });
    test('map ? empty key sequence', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2}?()', isEmpty);
    });
    test('array ? key sequence of length > 1', () {
      expectEvaluate(xml, '[4, 5, 6]?(1, 3)', [4, 6]);
    });
    test('array ? empty key sequence', () {
      expectEvaluate(xml, '[4, 5, 6]?()', isEmpty);
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
      expectEvaluate(xml, '[4, 5, 6] ! ?4', isEmpty);
    });
    test('map ? NCName', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2} ! ?a', [1]);
    });
    test('map ? key sequence of length > 1', () {
      expectEvaluate(xml, 'map {"a": 1, "b": 2, "c": 3} ! ?("a", "c")', [1, 3]);
    });
    test('map ? empty key sequence', () {
      expectEvaluate(xml, 'map {"a": 1} ! ?()', isEmpty);
    });
    test('array ? key sequence of length > 1', () {
      expectEvaluate(xml, '[4, 5, 6] ! ?(1, 3)', [4, 6]);
    });
    test('array ? empty key sequence', () {
      expectEvaluate(xml, '[4, 5, 6] ! ?()', isEmpty);
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
        throwsA(isXPathEvaluationException()),
      );
    });
    test('invalid type with key', () {
      expect(
        () => xml.xpathEvaluate('1 ! ?a'),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('native Dart Map ? key', () {
      expectEvaluate(
        xml,
        r'$map?a',
        [1],
        variables: {
          'map': {'a': 1, 'b': 2},
        },
      );
    });
    test('native Dart Map ? *', () {
      expectEvaluate(
        xml,
        r'$map?*',
        [1, 2],
        variables: {
          'map': {'a': 1, 'b': 2},
        },
      );
    });
    test('native Dart List ? index', () {
      expectEvaluate(
        xml,
        r'$list?2',
        [5],
        variables: {
          'list': [4, 5, 6],
        },
      );
    });
    test('native Dart List ? *', () {
      expectEvaluate(
        xml,
        r'$list?*',
        [4, 5, 6],
        variables: {
          'list': [4, 5, 6],
        },
      );
    });
    test('unary lookup without context item throws XPDY0002', () {
      expect(
        () => const XPathConfiguration.raw().context().evaluate('?*'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPDY0002,
            message: contains('Context item is undefined'),
          ),
        ),
      );
    });
    test('array lookup with non-numeric key throws XPTY0004', () {
      expect(
        () => xml.xpathEvaluate('[1, 2]?("a")'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains('Array lookup key must be an integer'),
          ),
        ),
      );
    });
  });
}
