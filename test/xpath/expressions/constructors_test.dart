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
        throwsA(
          isXPathEvaluationException(
            message:
                'map:constructor key must be exactly one item, but got (1, 2)',
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
