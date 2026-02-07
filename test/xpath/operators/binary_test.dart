import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  test('op:hexBinary-equal', () {
    expect(
      opHexBinaryEqual(
        const XPathSequence.single('AB'),
        const XPathSequence.single('AB'),
      ),
      [true],
    );
    expect(
      opHexBinaryEqual(
        const XPathSequence.single('AB'),
        const XPathSequence.single('AC'),
      ),
      [false],
    );
  });
  test('op:hexBinary-less-than', () {
    expect(
      opHexBinaryLessThan(
        const XPathSequence.single('AA'),
        const XPathSequence.single('BB'),
      ),
      [true],
    );
  });
  test('op:hexBinary-greater-than', () {
    expect(
      opHexBinaryGreaterThan(
        const XPathSequence.single('BB'),
        const XPathSequence.single('AA'),
      ),
      [true],
    );
  });
  test('op:base64Binary-equal', () {
    expect(
      opBase64BinaryEqual(
        const XPathSequence.single('AA=='),
        const XPathSequence.single('AA=='),
      ),
      [true],
    );
  });
  test('op:base64Binary-less-than', () {
    expect(
      opBase64BinaryLessThan(
        const XPathSequence.single('AA=='),
        const XPathSequence.single('AQ=='),
      ),
      [true],
    );
  });
  test('op:base64Binary-greater-than', () {
    expect(
      opBase64BinaryGreaterThan(
        const XPathSequence.single('AQ=='),
        const XPathSequence.single('AA=='),
      ),
      [true],
    );
  });
}
