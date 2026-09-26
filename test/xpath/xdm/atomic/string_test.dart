import 'package:test/test.dart';
import 'package:xml/xpath.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathString', () {
    test('construction and empty singleton', () {
      expect(XPathString.empty.value, equals(''));
      expect(XPathString.empty.stringValue, equals(''));
      expect(XPathString.empty.effectiveBooleanValue, isFalse);

      const s = XPathString('hello');
      expect(s.type, equals(xsString));
      expect(s.value, equals('hello'));
      expect(s.stringValue, equals('hello'));
      expect(s.effectiveBooleanValue, isTrue);
      expect(s.toString(), equals('hello'));
    });

    test('equality and comparisons with string types and Dart String', () {
      const s = XPathString('abc');
      const u = XPathUntypedAtomic('abc');
      const uri = XPathAnyUri('abc');

      expect(s == ('abc' as Object), isTrue);
      expect(s == const XPathString('abc'), isTrue);
      expect(s == u, isTrue);
      expect(s == uri, isTrue);
      expect(s == ('other' as Object), isFalse);
      expect(s == Object(), isFalse);

      expect(s.compareTo(const XPathString('abc')), equals(0));
      expect(s.compareTo(const XPathString('abd')), lessThan(0));
      expect(s.compareTo(u), equals(0));
      expect(s.compareTo(uri), equals(0));
      expect(
        () => s.compareTo(XPathInteger.fromInt(1)),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('XPathUntypedAtomic', () {
    test('construction and properties', () {
      const u = XPathUntypedAtomic('123');
      expect(u.type, equals(xsUntypedAtomic));
      expect(u.value, equals('123'));
      expect(u.stringValue, equals('123'));
      expect(u.effectiveBooleanValue, isTrue);
      expect(const XPathUntypedAtomic('').effectiveBooleanValue, isFalse);
      expect(u.toString(), equals('123'));
    });

    test('equality and comparisons', () {
      const u = XPathUntypedAtomic('xyz');
      expect(u == ('xyz' as Object), isTrue);
      expect(u == const XPathString('xyz'), isTrue);
      expect(u == const XPathAnyUri('xyz'), isTrue);
      expect(u == const XPathUntypedAtomic('xyz'), isTrue);
      expect(u.hashCode, equals('xyz'.hashCode));
      expect(u.compareTo(const XPathUntypedAtomic('xyz')), equals(0));
      expect(u.compareTo(const XPathString('xya')), greaterThan(0));
      expect(u.compareTo(const XPathAnyUri('xyz')), equals(0));
      expect(
        () => u.compareTo(XPathInteger.fromInt(1)),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('XPathAnyUri', () {
    test('construction and properties', () {
      const uri = XPathAnyUri('http://example.com');
      expect(uri.type, equals(xsAnyURI));
      expect(uri.value, equals('http://example.com'));
      expect(uri.stringValue, equals('http://example.com'));
      expect(uri.effectiveBooleanValue, isTrue);
      expect(const XPathAnyUri('').effectiveBooleanValue, isFalse);
      expect(uri.toString(), equals('http://example.com'));
    });

    test('equality and comparisons', () {
      const uri = XPathAnyUri('test');
      expect(uri == ('test' as Object), isTrue);
      expect(uri == const XPathString('test'), isTrue);
      expect(uri == const XPathUntypedAtomic('test'), isTrue);
      expect(uri == const XPathAnyUri('test'), isTrue);
      expect(uri.hashCode, equals('test'.hashCode));
      expect(uri.compareTo(const XPathAnyUri('test')), equals(0));
      expect(uri.compareTo(const XPathString('test')), equals(0));
      expect(uri.compareTo(const XPathUntypedAtomic('test')), equals(0));
      expect(
        () => uri.compareTo(XPathInteger.fromInt(1)),
        throwsA(isXPathEvaluationException()),
      );
    });
  });
}
