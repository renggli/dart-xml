import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('map', () {
    test('cast from map', () {
      final map = {'a': 1};
      expect(map.toXPathMap(), map);
    });
    test('cast from sequence', () {
      final map = {'a': 1};
      expect(XPathSequence.single(map).toXPathMap(), map);
      expect(
        () => XPathSequence.empty.toXPathMap(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(() => 123.toXPathMap(), throwsA(isA<XPathEvaluationException>()));
    });
  });
}
