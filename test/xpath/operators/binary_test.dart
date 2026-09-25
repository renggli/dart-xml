import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/binary.dart';
import 'package:xml/xpath.dart';

void main() {
  group('op:hexBinary-equal', () {
    test('same content', () {
      expect(
        opHexBinaryEqual(
          XPathSequence.single(XPathBinary.fromHex('AB')),
          XPathSequence.single(XPathBinary.fromHex('AB')),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('different content', () {
      expect(
        opHexBinaryEqual(
          XPathSequence.single(XPathBinary.fromHex('AB')),
          XPathSequence.single(XPathBinary.fromHex('AC')),
        ),
        XPathSequence.falseSequence,
      );
    });
  });

  group('op:hexBinary-less-than', () {
    test('less than', () {
      expect(
        opHexBinaryLessThan(
          XPathSequence.single(XPathBinary.fromHex('AA')),
          XPathSequence.single(XPathBinary.fromHex('BB')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:hexBinary-greater-than', () {
    test('greater than', () {
      expect(
        opHexBinaryGreaterThan(
          XPathSequence.single(XPathBinary.fromHex('BB')),
          XPathSequence.single(XPathBinary.fromHex('AA')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-equal', () {
    test('same content', () {
      expect(
        opBase64BinaryEqual(
          XPathSequence.single(XPathBinary.fromBase64('AA==')),
          XPathSequence.single(XPathBinary.fromBase64('AA==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-less-than', () {
    test('less than', () {
      expect(
        opBase64BinaryLessThan(
          XPathSequence.single(XPathBinary.fromBase64('AA==')),
          XPathSequence.single(XPathBinary.fromBase64('AQ==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-greater-than', () {
    test('greater than', () {
      expect(
        opBase64BinaryGreaterThan(
          XPathSequence.single(XPathBinary.fromBase64('AQ==')),
          XPathSequence.single(XPathBinary.fromBase64('AA==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });
}
