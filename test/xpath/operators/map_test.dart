import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('opSameKey', () {
    test('same string', () {
      expect(
        opSameKey(
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('same NaN', () {
      expect(
        opSameKey(
          const XPathSequence.single(double.nan),
          const XPathSequence.single(double.nan),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('different string', () {
      expect(
        opSameKey(
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ),
        XPathSequence.falseSequence,
      );
    });
  });
}
