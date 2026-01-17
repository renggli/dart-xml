import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../xpath_test.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('map', () {
    test('empty', () {
      expectEvaluate(xml, 'map {}', [<Object, Object>{}]);
    });
    test('simple', () {
      expectEvaluate(xml, 'map { "a": 1, "b": 2 }', [
        {'a': 1, 'b': 2},
      ]);
    });
  });
  group('array', () {
    test('square empty', () {
      expectEvaluate(xml, '[]', [<Object>[]]);
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
      expectEvaluate(xml, 'array {}', [<Object>[]]);
    });
    test('curly flatten', () {
      expectEvaluate(xml, 'array { (1, 2), 3 }', [
        [1, 2, 3],
      ]);
    });
  });
}
