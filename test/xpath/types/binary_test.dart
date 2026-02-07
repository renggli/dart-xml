import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('xsBase64Binary', () {
    test('name', () {
      expect(xsBase64Binary.name, 'xs:base64Binary');
    });
    test('matches', () {
      expect(xsBase64Binary.matches(XPathBase64Binary(Uint8List(0))), isTrue);
      expect(xsBase64Binary.matches(Uint8List(0)), isFalse);
    });
    group('cast', () {
      test('from XPathBase64Binary', () {
        final binary = XPathBase64Binary(Uint8List.fromList([1]));
        expect(xsBase64Binary.cast(binary), same(binary));
      });
      test('from Uint8List', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final binary = xsBase64Binary.cast(bytes);
        expect(binary, [1, 2, 3]);
        expect(binary, isA<XPathBase64Binary>());
      });
      test('from List<int>', () {
        final list = [1, 2, 3];
        final binary = xsBase64Binary.cast(list);
        expect(binary, [1, 2, 3]);
        expect(binary, isA<XPathBase64Binary>());
      });
      test('from String', () {
        // AQID is base64 for [1, 2, 3]
        final binary = xsBase64Binary.cast('AQID');
        expect(binary, [1, 2, 3]);
      });
      test('from XPathSequence', () {
        final binary = xsBase64Binary.cast(
          XPathSequence.single(Uint8List.fromList([1])),
        );
        expect(binary, [1]);
      });
      test('from unrelated type', () {
        expect(
          () => xsBase64Binary.cast(123),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
  group('xsHexBinary', () {
    test('name', () {
      expect(xsHexBinary.name, 'xs:hexBinary');
    });
    test('matches', () {
      expect(xsHexBinary.matches(XPathHexBinary(Uint8List(0))), isTrue);
      expect(xsHexBinary.matches(Uint8List(0)), isFalse);
    });
    group('cast', () {
      test('from XPathHexBinary', () {
        final binary = XPathHexBinary(Uint8List.fromList([1]));
        expect(xsHexBinary.cast(binary), same(binary));
      });
      test('from Uint8List', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final binary = xsHexBinary.cast(bytes);
        expect(binary, [1, 2, 3]);
        expect(binary, isA<XPathHexBinary>());
      });
      test('from List<int>', () {
        final list = [1, 2, 3];
        final binary = xsHexBinary.cast(list);
        expect(binary, [1, 2, 3]);
        expect(binary, isA<XPathHexBinary>());
      });
      test('from String', () {
        // 010203 is hex for [1, 2, 3]
        final binary = xsHexBinary.cast('010203');
        expect(binary, [1, 2, 3]);
      });
      test('from XPathSequence', () {
        final binary = xsHexBinary.cast(
          XPathSequence.single(Uint8List.fromList([1])),
        );
        expect(binary, [1]);
      });
      test('from unrelated type', () {
        expect(
          () => xsHexBinary.cast(123),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
}
