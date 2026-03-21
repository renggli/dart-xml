import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/qname.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('opQNameEqual', () {
    test('empty sequences', () {
      expect(opQNameEqual(XPathSequence.empty, XPathSequence.empty), isEmpty);
    });
    test('equal QNames', () {
      expect(
        opQNameEqual(
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ),
        [true],
      );
    });
    test('different QNames', () {
      expect(
        opQNameEqual(
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ),
        [false],
      );
    });
  });
}
