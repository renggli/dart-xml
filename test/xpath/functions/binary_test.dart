import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/binary.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('binary', () {
    test('op:hexBinary-equal', () {
      expect(
        opHexBinaryEqual(context, [
          const XPathSequence.single('AB'),
          const XPathSequence.single('AB'),
        ]),
        [true],
      );
      expect(
        opHexBinaryEqual(context, [
          const XPathSequence.single('AB'),
          const XPathSequence.single('AC'),
        ]),
        [false],
      );
    });
    test('op:hexBinary-less-than', () {
      expect(
        opHexBinaryLessThan(context, [
          const XPathSequence.single('AA'),
          const XPathSequence.single('BB'),
        ]),
        [true],
      );
    });
    test('op:hexBinary-greater-than', () {
      expect(
        opHexBinaryGreaterThan(context, [
          const XPathSequence.single('BB'),
          const XPathSequence.single('AA'),
        ]),
        [true],
      );
    });
    test('op:base64Binary-equal', () {
      expect(
        opBase64BinaryEqual(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AA=='),
        ]),
        [true],
      );
    });
    test('op:base64Binary-less-than', () {
      expect(
        opBase64BinaryLessThan(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AQ=='),
        ]),
        [true],
      );
    });
    test('op:base64Binary-greater-than', () {
      expect(
        opBase64BinaryGreaterThan(context, [
          const XPathSequence.single('AQ=='),
          const XPathSequence.single('AA=='),
        ]),
        [true],
      );
    });
  });
}
