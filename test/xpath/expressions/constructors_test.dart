import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('map', () {
    test('empty', () {
      expectEvaluate(xml, 'map {}', XPathSequence.emptyMap);
    });
    test('simple', () {
      expectEvaluate(xml, 'map { "a": 1, "b": 2 }', [
        {'a': 1, 'b': 2},
      ]);
    });
    test('invalid key', () {
      expect(
        () => xml.xpathEvaluate('map { (1, 2): "value" }'),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('duplicate key', () {
      expect(
        () => xml.xpathEvaluate('map { "a": 1, "a": 2 }'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XQDY0137,
            message: contains('Duplicate key in map constructor: a'),
          ),
        ),
      );
    });
  });
  group('array', () {
    test('square empty', () {
      expectEvaluate(xml, '[]', XPathSequence.emptyArray);
    });
    test('square simple', () {
      expectEvaluate(xml, '[1, 2]', [
        [1, 2],
      ]);
    });
    test('square nested', () {
      expectEvaluate(xml, '[(1, 2), 3]', [
        [
          [1, 2],
          3,
        ],
      ]);
    });
    test('curly empty', () {
      expectEvaluate(xml, 'array {}', XPathSequence.emptyArray);
    });
    test('curly flatten', () {
      expectEvaluate(xml, 'array { (1, 2), 3 }', [
        [1, 2, 3],
      ]);
    });
  });
}
