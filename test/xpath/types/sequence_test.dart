import 'package:test/test.dart';
import 'package:xml/src/xpath/definitions/cardinality.dart';
import 'package:xml/src/xpath/types/any.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';

import '../../utils/matchers.dart';

void main() {
  group('XPathSequence', () {
    test('empty', () {
      const sequence = XPathSequence.empty;
      expect(sequence, isEmpty);
      expect(sequence, hasLength(0));
      expect(sequence, isXPathSequence(isEmpty));
      expect(sequence.toAtomicValue(), same(sequence));
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isFalse);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isFalse);
      expect(sequence.toString(), '()');
    });
    test('true ', () {
      const sequence = XPathSequence.trueSequence;
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence, isXPathSequence([true]));
      expect(sequence.toAtomicValue(), isTrue);
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isTrue);
      expect(sequence.toString(), '(true)');
    });
    test('false', () {
      const sequence = XPathSequence.falseSequence;
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence, isXPathSequence([false]));
      expect(sequence.toAtomicValue(), isFalse);
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isTrue);
      expect(sequence.toString(), '(false)');
    });
    test('single', () {
      const sequence = XPathSequence.single(123);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence, isXPathSequence([123]));
      expect(sequence.toAtomicValue(), 123);
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isTrue);
      expect(sequence.toString(), '(123)');
    });
    test('multiple (empty)', () {
      const sequence = XPathSequence<Object>([]);
      expect(sequence, isEmpty);
      expect(sequence, hasLength(0));
      expect(sequence, isXPathSequence(isEmpty));
      expect(sequence.toAtomicValue(), same(sequence));
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isFalse);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isFalse);
      expect(sequence.toString(), '()');
    });
    test('multiple (single)', () {
      const sequence = XPathSequence([123]);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence, isXPathSequence([123]));
      expect(sequence.toAtomicValue(), 123);
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isTrue);
      expect(sequence.toString(), '(123)');
    });
    test('multiple (many)', () {
      const sequence = XPathSequence([1, 2, 3]);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(3));
      expect(sequence, isXPathSequence([1, 2, 3]));
      expect(sequence.toAtomicValue(), same(sequence));
      expect(sequence.toXPathSequence(), same(sequence));
      expect(sequence.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.zeroOrOne), isFalse);
      expect(sequence.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(sequence.hasCardinality(XPathCardinality.exactlyOne), isFalse);
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
      expect(sequence, isXPathSequence([1, 2, 3]));
      expect(sequence.toString(), '(1, 2, 3)');
      expect(iteratorCount, 3, reason: 'iterated once');
      expect(sequence, isXPathSequence([1, 2, 3]));
      expect(iteratorCount, 3, reason: 'no more iteration');
      expect(sequence.toString(), '(1, 2, 3)');
    });
    test('range', () {
      final sequence = XPathSequence.range(1, 3);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(3));
      expect(sequence, isXPathSequence([1, 2, 3]));
      expect(sequence.toString(), '(1, 2, 3)');
    });
    test('range (singular)', () {
      final sequence = XPathSequence.range(3, 3);
      expect(sequence, isNotEmpty);
      expect(sequence, hasLength(1));
      expect(sequence, isXPathSequence([3]));
      expect(sequence.toString(), '(3)');
    });
    test('range (empty)', () {
      final sequence = XPathSequence.range(3, 1);
      expect(sequence, isEmpty);
      expect(sequence, hasLength(0));
      expect(sequence, isXPathSequence(isEmpty));
      expect(sequence.toString(), '()');
    });
  });

  group('xsEmptySequence', () {
    test('name', () {
      expect(xsEmptySequence.name, 'empty-sequence()');
    });
    test('matches', () {
      expect(xsEmptySequence.matches(XPathSequence.empty), isTrue);
      expect(xsEmptySequence.matches(XPathSequence.trueSequence), isFalse);
      expect(xsEmptySequence.matches(''), isFalse);
    });
    test('cast', () {
      expect(xsEmptySequence.cast(XPathSequence.empty), XPathSequence.empty);
      expect(
        () => xsEmptySequence.cast(XPathSequence.trueSequence),
        throwsA(
          isXPathEvaluationException(
            message: 'Unsupported cast from (true) to empty-sequence()',
          ),
        ),
      );
    });
  });

  group('xsSequence', () {
    test('name', () {
      expect(xsSequence.name, 'item()*');
    });
    test('matches', () {
      expect(xsSequence.matches(XPathSequence.empty), isTrue);
      expect(xsSequence.matches(XPathSequence.trueSequence), isTrue);
      expect(xsSequence.matches(''), isFalse);
      expect(xsSequence.matches(123), isFalse);
    });
    group('cardinality', () {
      test('zero-or-more', () {
        const type = XPathSequenceType(
          type: xsAny,
          cardinality: XPathCardinality.zeroOrMore,
        );
        expect(type.matches(const XPathSequence<int>([])), isTrue);
        expect(type.matches(const XPathSequence<int>([1])), isTrue);
        expect(type.matches(const XPathSequence<int>([1, 2])), isTrue);
      });
      test('zero-or-one', () {
        const type = XPathSequenceType(
          type: xsAny,
          cardinality: XPathCardinality.zeroOrOne,
        );
        expect(type.matches(const XPathSequence<int>([])), isTrue);
        expect(type.matches(const XPathSequence<int>([1])), isTrue);
        expect(type.matches(const XPathSequence<int>([1, 2])), isFalse);
      });
      test('one-or-more', () {
        const type = XPathSequenceType(
          type: xsAny,
          cardinality: XPathCardinality.oneOrMore,
        );
        expect(type.matches(const XPathSequence<int>([])), isFalse);
        expect(type.matches(const XPathSequence<int>([1])), isTrue);
        expect(type.matches(const XPathSequence<int>([1, 2])), isTrue);
      });
      test('exactly-one', () {
        const type = XPathSequenceType(
          type: xsAny,
          cardinality: XPathCardinality.exactlyOne,
        );
        expect(type.matches(const XPathSequence<int>([])), isFalse);
        expect(type.matches(const XPathSequence<int>([1])), isTrue);
        expect(type.matches(const XPathSequence<int>([1, 2])), isFalse);
      });
    });
    group('cast', () {
      test('from sequence', () {
        expect(xsSequence.cast(XPathSequence.empty), XPathSequence.empty);
        const seq = XPathSequence.single(1);
        expect(xsSequence.cast(seq), seq);
      });
      test('with type', () {
        const type = XPathSequenceType(type: xsString);
        const sequence = XPathSequence([1, 2, 3]);
        expect(type.cast(sequence), const ['1', '2', '3']);
      });
    });
  });
  group('extensions', () {
    test('toAtomicValue', () {
      expect(42.toAtomicValue(), 42);
      expect([42].toAtomicValue(), [42]);
      expect(const XPathSequence.single(42).toAtomicValue(), 42);
      for (final sequence in const [
        XPathSequence.empty,
        XPathSequence([4, 2]),
      ]) {
        expect(sequence.toAtomicValue(), same(sequence));
      }
    });
    test('toXPathSequence', () {
      expect(42.toXPathSequence(), isXPathSequence([42]));
      expect(
        [42].toXPathSequence(),
        isXPathSequence([
          [42],
        ]),
      );
      for (final sequence in const [
        XPathSequence.empty,
        XPathSequence([42]),
        XPathSequence([4, 2]),
      ]) {
        expect(sequence.toXPathSequence(), same(sequence));
      }
    });
  });
}
