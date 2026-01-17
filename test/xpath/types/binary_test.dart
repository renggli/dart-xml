import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('binary', () {
    test('cast from Uint8List (Base64)', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final binary = bytes.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathBase64Binary>());
    });
    test('cast from List<int> (Base64)', () {
      final list = [1, 2, 3];
      final binary = list.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathBase64Binary>());
    });
    test('cast from String (Base64)', () {
      // AQID is base64 for [1, 2, 3]
      final binary = 'AQID'.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
    });
    test('cast from XPathSequence (Base64)', () {
      final binary = XPathSequence.single(
        Uint8List.fromList([1]),
      ).toXPathBase64Binary();
      expect(binary, [1]);
    });
    test('cast from unrelated type (Base64)', () {
      expect(
        () => 123.toXPathBase64Binary(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('cast from Uint8List (Hex)', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final binary = bytes.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathHexBinary>());
    });
    test('cast from List<int> (Hex)', () {
      final list = [1, 2, 3];
      final binary = list.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathHexBinary>());
    });
    test('cast from String (Hex)', () {
      // 010203 is hex for [1, 2, 3]
      final binary = '010203'.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
    });
    test('cast from XPathSequence (Hex)', () {
      final binary = XPathSequence.single(
        Uint8List.fromList([1]),
      ).toXPathHexBinary();
      expect(binary, [1]);
    });
    test('cast from unrelated type (Hex)', () {
      expect(
        () => 123.toXPathHexBinary(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
