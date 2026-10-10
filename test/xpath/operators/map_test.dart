import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/map.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opSameKey', () {
    test('same string', () {
      check(
        opSameKey(
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('a')),
        ),
      ).equals(XPathSequence.trueSequence);
    });
    test('same NaN', () {
      check(
        opSameKey(
          const XPathSequence.single(XPathDouble(double.nan)),
          const XPathSequence.single(XPathDouble(double.nan)),
        ),
      ).equals(XPathSequence.trueSequence);
    });
    test('different string', () {
      check(
        opSameKey(
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ),
      ).equals(XPathSequence.falseSequence);
    });
  });
}
