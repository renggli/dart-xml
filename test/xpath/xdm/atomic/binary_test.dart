import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/xpath.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathBinary base64', () {
    test('construction and parsing fromBase64', () {
      final b64 = XPathBinary.fromBase64('  SGVsbG8= \n');
      expect(b64.type, equals(xsBase64Binary));
      expect(b64.stringValue, equals('SGVsbG8='));
      expect(b64.value, equals(Uint8List.fromList([72, 101, 108, 108, 111])));
      expect(b64.toString(), equals('SGVsbG8='));
    });

    test('effectiveBooleanValue throws', () {
      final b64 = XPathBinary.fromBase64('SGVsbG8=');
      expect(
        () => b64.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });

    test('equality, hashCode, and comparisons', () {
      final b1 = XPathBinary.fromBase64('AA==');
      final b2 = XPathBinary.fromBase64('AA==');
      final b3 = XPathBinary.fromBase64('AQ==');
      final b4 = XPathBinary.fromBase64('AAA=');

      expect(b1, equals(b2));
      expect(b1.hashCode, equals(b2.hashCode));
      expect(b1 == b3, isFalse);
      expect(b1.compareTo(b2), equals(0));
      expect(b1.compareTo(b3), lessThan(0));
      expect(b3.compareTo(b1), greaterThan(0));
      expect(b1.compareTo(b4), lessThan(0));
    });
  });

  group('XPathBinary hex', () {
    test('construction and parsing fromHex', () {
      final hex = XPathBinary.fromHex(' 48 65 6c 6c 6f ');
      expect(hex.type, equals(xsHexBinary));
      expect(hex.stringValue, equals('48656C6C6F'));
      expect(hex.value, equals(Uint8List.fromList([72, 101, 108, 108, 111])));
      expect(hex.toString(), equals('48656C6C6F'));
    });

    test('odd length throws evaluation exception', () {
      expect(
        () => XPathBinary.fromHex('123'),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('effectiveBooleanValue throws', () {
      final hex = XPathBinary.fromHex('4865');
      expect(
        () => hex.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });

    test('equality and comparisons', () {
      final h1 = XPathBinary.fromHex('00');
      final h2 = XPathBinary.fromHex('00');
      final h3 = XPathBinary.fromHex('01');

      expect(h1, equals(h2));
      expect(h1 == h3, isFalse);
      expect(h1.compareTo(h2), equals(0));
      expect(h1.compareTo(h3), lessThan(0));
      expect(h3.compareTo(h1), greaterThan(0));
      expect(
        () => h1.compareTo(const XPathString('00')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
