import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathBinary base64', () {
    test('construction and parsing fromBase64', () {
      final b64 = XPathBinary.fromBase64('  SGVsbG8= \n');
      check(b64.type).equals(xsBase64Binary);
      check(b64.stringValue).equals('SGVsbG8=');
      check(b64.value).deepEquals([72, 101, 108, 108, 111]);
      check(b64.toString()).equals('SGVsbG8=');
    });

    test('effectiveBooleanValue throws', () {
      final b64 = XPathBinary.fromBase64('SGVsbG8=');
      check(() => b64.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('equality, hashCode, and comparisons', () {
      final b1 = XPathBinary.fromBase64('AA==');
      final b2 = XPathBinary.fromBase64('AA==');
      final b3 = XPathBinary.fromBase64('AQ==');
      final b4 = XPathBinary.fromBase64('AAA=');

      check(b1).equals(b2);
      check(b1.hashCode).equals(b2.hashCode);
      check(b1 == b3).isFalse();
      check(b1.compareTo(b2)).equals(0);
      check(b1.compareTo(b3)).isLessThan(0);
      check(b3.compareTo(b1)).isGreaterThan(0);
      check(b1.compareTo(b4)).isLessThan(0);
    });
  });

  group('XPathBinary hex', () {
    test('construction and parsing fromHex', () {
      final hex = XPathBinary.fromHex(' 48 65 6c 6c 6f ');
      check(hex.type).equals(xsHexBinary);
      check(hex.stringValue).equals('48656C6C6F');
      check(hex.value).deepEquals([72, 101, 108, 108, 111]);
      check(hex.toString()).equals('48656C6C6F');
    });

    test('odd length throws evaluation exception', () {
      check(() => XPathBinary.fromHex('123'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('effectiveBooleanValue throws', () {
      final hex = XPathBinary.fromHex('4865');
      check(() => hex.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('equality and comparisons', () {
      final h1 = XPathBinary.fromHex('00');
      final h2 = XPathBinary.fromHex('00');
      final h3 = XPathBinary.fromHex('01');

      check(h1).equals(h2);
      check(h1 == h3).isFalse();
      check(h1.compareTo(h2)).equals(0);
      check(h1.compareTo(h3)).isLessThan(0);
      check(h3.compareTo(h1)).isGreaterThan(0);
      check(() => h1.compareTo(const XPathString('00'))).throws<Exception>();
    });
  });
}
