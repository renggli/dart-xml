import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  group('op:hexBinary-equal', () {
    test('same content', () {
      expect(
        opHexBinaryEqual(
          const XPathSequence.single('AB'),
          const XPathSequence.single('AB'),
        ),
        [true],
      );
    });
    test('different content', () {
      expect(
        opHexBinaryEqual(
          const XPathSequence.single('AB'),
          const XPathSequence.single('AC'),
        ),
        [false],
      );
    });
  });

  group('op:hexBinary-less-than', () {
    test('less than', () {
      expect(
        opHexBinaryLessThan(
          const XPathSequence.single('AA'),
          const XPathSequence.single('BB'),
        ),
        [true],
      );
    });
  });

  group('op:hexBinary-greater-than', () {
    test('greater than', () {
      expect(
        opHexBinaryGreaterThan(
          const XPathSequence.single('BB'),
          const XPathSequence.single('AA'),
        ),
        [true],
      );
    });
  });

  group('op:base64Binary-equal', () {
    test('same content', () {
      expect(
        opBase64BinaryEqual(
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AA=='),
        ),
        [true],
      );
    });
  });

  group('op:base64Binary-less-than', () {
    test('less than', () {
      expect(
        opBase64BinaryLessThan(
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AQ=='),
        ),
        [true],
      );
    });
  });

  group('op:base64Binary-greater-than', () {
    test('greater than', () {
      expect(
        opBase64BinaryGreaterThan(
          const XPathSequence.single('AQ=='),
          const XPathSequence.single('AA=='),
        ),
        [true],
      );
    });
  });
}
