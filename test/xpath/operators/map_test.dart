import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/map.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opSameKey', () {
    test('same string', () {
      expect(
        opSameKey(
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('a')),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('same NaN', () {
      expect(
        opSameKey(
          const XPathSequence.single(XPathDouble(double.nan)),
          const XPathSequence.single(XPathDouble(double.nan)),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('different string', () {
      expect(
        opSameKey(
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ),
        XPathSequence.falseSequence,
      );
    });
  });
}
