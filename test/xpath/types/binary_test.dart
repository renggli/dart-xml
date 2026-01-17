import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('base64', () {
    test('cast from Uint8List', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final binary = bytes.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathBase64Binary>());
    });
    test('cast from List<int>', () {
      final list = [1, 2, 3];
      final binary = list.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathBase64Binary>());
    });
    test('cast from String', () {
      // AQID is base64 for [1, 2, 3]
      final binary = 'AQID'.toXPathBase64Binary();
      expect(binary, [1, 2, 3]);
    });
    test('cast from XPathSequence', () {
      final binary = XPathSequence.single(
        Uint8List.fromList([1]),
      ).toXPathBase64Binary();
      expect(binary, [1]);
    });
    test('cast from unrelated type', () {
      expect(
        () => 123.toXPathBase64Binary(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
  group('hex', () {
    test('cast from Uint8List', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final binary = bytes.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathHexBinary>());
    });
    test('cast from List<int>', () {
      final list = [1, 2, 3];
      final binary = list.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
      expect(binary, isA<XPathHexBinary>());
    });
    test('cast from String', () {
      // 010203 is hex for [1, 2, 3]
      final binary = '010203'.toXPathHexBinary();
      expect(binary, [1, 2, 3]);
    });
    test('cast from XPathSequence', () {
      final binary = XPathSequence.single(
        Uint8List.fromList([1]),
      ).toXPathHexBinary();
      expect(binary, [1]);
    });
    test('cast from unrelated type', () {
      expect(
        () => 123.toXPathHexBinary(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
