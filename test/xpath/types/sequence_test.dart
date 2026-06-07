import 'package:test/test.dart';
import 'package:xml/src/xpath/definitions/cardinality.dart';
import 'package:xml/src/xpath/types/any.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';

import 'package:xml/src/xpath/values/sequence.dart';
import '../../utils/matchers.dart';

void main() {
  group('xsEmptySequence', () {
    test('name', () {
      expect(xsEmptySequence.name, 'empty-sequence()');
    });
    test('isAtomic', () {
      expect(xsEmptySequence.isAtomic, isFalse);
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
    test('isAtomic', () {
      expect(xsSequence.isAtomic, isFalse);
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
      test('unsupported cardinality', () {
        const type = XPathSequenceType(
          type: xsAny,
          cardinality: XPathCardinality.exactlyOne,
        );
        expect(
          () => type.cast(const XPathSequence([1, 2])),
          throwsA(isXPathEvaluationException()),
        );
      });
    });
  });
}
