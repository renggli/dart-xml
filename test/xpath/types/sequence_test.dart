import 'package:test/test.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('sequence', () {
    test('emtpy', () {
      const sequence = XPathSequence.empty;
      expect(sequence, isEmpty);
      expect(sequence, hasLength(0));
      expect(sequence.toString(), '()');
    });
    test('true ', () {
      const sequence = XPathSequence.trueSequence;
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence.single, isTrue);
      expect(sequence.toString(), '(true)');
    });
    test('false', () {
      const sequence = XPathSequence.falseSequence;
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence.single, isFalse);
      expect(sequence.toString(), '(false)');
    });
    test('single', () {
      const sequence = XPathSequence.single(123);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence.single, 123);
      expect(sequence.toString(), '(123)');
    });
    test('multiple', () {
      const sequence = XPathSequence([1, 2, 3]);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(3));
      expect(sequence, [1, 2, 3]);
      expect(sequence.toString(), '(1, 2, 3)');
    });
    test('cached', () {
      var iteratorCount = 0;
      final iterable = Iterable.generate(3, (i) {
        iteratorCount++;
        return i + 1;
      });
      final sequence = XPathSequence.cached(iterable);

      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(3));
      expect(sequence, [1, 2, 3]);
      expect(iteratorCount, 3); // Iterated once

      // Iterate again
      expect(sequence, [1, 2, 3]);
      expect(iteratorCount, 3); // Should not have iterated again

      expect(sequence.toString(), '(1, 2, 3)');
    });
    test('range', () {
      final sequence = XPathSequence.range(1, 3);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(3));
      expect(sequence, [1, 2, 3]);
      expect(sequence.toString(), '(1, 2, 3)');
    });
    test('range (singular)', () {
      final sequence = XPathSequence.range(3, 3);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence.single, 3);
      expect(sequence.toString(), '(3)');
    });
    test('range (empty)', () {
      final sequence = XPathSequence.range(3, 1);
      expect(sequence, isEmpty);
      expect(sequence, hasLength(0));
      expect(sequence.toString(), '()');
    });
    test('cast to sequence', () {
      expect(XPathSequence.empty.toXPathSequence(), isEmpty);
      expect('abc'.toXPathSequence(), const XPathSequence.single('abc'));
      expect([1, 2].toXPathSequence(), const XPathSequence.single([1, 2]));
      expect(
        XPathSequence.trueSequence.toXPathSequence(),
        XPathSequence.trueSequence,
      );
    });
  });
}
