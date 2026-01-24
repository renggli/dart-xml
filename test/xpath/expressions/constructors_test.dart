import 'package:test/test.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

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
