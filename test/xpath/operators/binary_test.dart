import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/binary.dart';
import 'package:xml/xpath.dart';

void main() {
  group('op:hexBinary-equal', () {
    test('same content', () {
      expect(
        opHexBinaryEqual(
          XPathSequence.single(XPathHexBinary.fromHex('AB')),
          XPathSequence.single(XPathHexBinary.fromHex('AB')),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('different content', () {
      expect(
        opHexBinaryEqual(
          XPathSequence.single(XPathHexBinary.fromHex('AB')),
          XPathSequence.single(XPathHexBinary.fromHex('AC')),
        ),
        XPathSequence.falseSequence,
      );
    });
  });

  group('op:hexBinary-less-than', () {
    test('less than', () {
      expect(
        opHexBinaryLessThan(
          XPathSequence.single(XPathHexBinary.fromHex('AA')),
          XPathSequence.single(XPathHexBinary.fromHex('BB')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:hexBinary-greater-than', () {
    test('greater than', () {
      expect(
        opHexBinaryGreaterThan(
          XPathSequence.single(XPathHexBinary.fromHex('BB')),
          XPathSequence.single(XPathHexBinary.fromHex('AA')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-equal', () {
    test('same content', () {
      expect(
        opBase64BinaryEqual(
          XPathSequence.single(XPathBase64Binary.fromBase64('AA==')),
          XPathSequence.single(XPathBase64Binary.fromBase64('AA==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-less-than', () {
    test('less than', () {
      expect(
        opBase64BinaryLessThan(
          XPathSequence.single(XPathBase64Binary.fromBase64('AA==')),
          XPathSequence.single(XPathBase64Binary.fromBase64('AQ==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });

  group('op:base64Binary-greater-than', () {
    test('greater than', () {
      expect(
        opBase64BinaryGreaterThan(
          XPathSequence.single(XPathBase64Binary.fromBase64('AQ==')),
          XPathSequence.single(XPathBase64Binary.fromBase64('AA==')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });
}
