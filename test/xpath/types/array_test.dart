import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/array.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('xsArray', () {
    test('name', () {
      expect(xsArray.name, 'array(*)');
    });
    test('matches', () {
      expect(xsArray.matches([1, 2]), isTrue);
      expect(xsArray.matches('foo'), isFalse);
    });
    group('cast', () {
      test('from array', () {
        final array = [1, 2, 3];
        expect(xsArray.cast(array), same(array));
      });
      test('from sequence (single array)', () {
        final array = [1, 2];
        expect(xsArray.cast(XPathSequence.single(array)), same(array));
      });
      test('from sequence (empty)', () {
        expect(
          () => xsArray.cast(XPathSequence.empty),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from other', () {
        expect(
          () => xsArray.cast(123),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
}
