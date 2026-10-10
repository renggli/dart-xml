import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathString', () {
    test('construction and empty singleton', () {
      check(XPathString.empty.value).equals('');
      check(XPathString.empty.stringValue).equals('');
      check(XPathString.empty.effectiveBooleanValue).isFalse();

      const s = XPathString('hello');
      check(s.type).equals(xsString);
      check(s.value).equals('hello');
      check(s.stringValue).equals('hello');
      check(s.effectiveBooleanValue).isTrue();
      check(s.toString()).equals('hello');
    });

    test('equality and comparisons with string types and Dart String', () {
      const s = XPathString('abc');
      const u = XPathUntypedAtomic('abc');
      const uri = XPathAnyUri('abc');

      check(s == ('abc' as Object)).isTrue();
      check(s == const XPathString('abc')).isTrue();
      check(s == u).isTrue();
      check(s == uri).isTrue();
      check(s == ('other' as Object)).isFalse();
      check(s == Object()).isFalse();

      check(s.compareTo(const XPathString('abc'))).equals(0);
      check(s.compareTo(const XPathString('abd'))).isLessThan(0);
      check(s.compareTo(u)).equals(0);
      check(s.compareTo(uri)).equals(0);
      check(() => s.compareTo(XPathInteger.fromInt(1)))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('XPathUntypedAtomic', () {
    test('construction and properties', () {
      const u = XPathUntypedAtomic('123');
      check(u.type).equals(xsUntypedAtomic);
      check(u.value).equals('123');
      check(u.stringValue).equals('123');
      check(u.effectiveBooleanValue).isTrue();
      check(const XPathUntypedAtomic('').effectiveBooleanValue).isFalse();
      check(u.toString()).equals('123');
    });

    test('equality and comparisons', () {
      const u = XPathUntypedAtomic('xyz');
      check(u == ('xyz' as Object)).isTrue();
      check(u == const XPathString('xyz')).isTrue();
      check(u == const XPathAnyUri('xyz')).isTrue();
      check(u == const XPathUntypedAtomic('xyz')).isTrue();
      check(u.hashCode).equals('xyz'.hashCode);
      check(u.compareTo(const XPathUntypedAtomic('xyz'))).equals(0);
      check(u.compareTo(const XPathString('xya'))).isGreaterThan(0);
      check(u.compareTo(const XPathAnyUri('xyz'))).equals(0);
      check(() => u.compareTo(XPathInteger.fromInt(1)))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('XPathAnyUri', () {
    test('construction and properties', () {
      const uri = XPathAnyUri('http://example.com');
      check(uri.type).equals(xsAnyURI);
      check(uri.value).equals('http://example.com');
      check(uri.stringValue).equals('http://example.com');
      check(uri.effectiveBooleanValue).isTrue();
      check(const XPathAnyUri('').effectiveBooleanValue).isFalse();
      check(uri.toString()).equals('http://example.com');
    });

    test('equality and comparisons', () {
      const uri = XPathAnyUri('test');
      check(uri == ('test' as Object)).isTrue();
      check(uri == const XPathString('test')).isTrue();
      check(uri == const XPathUntypedAtomic('test')).isTrue();
      check(uri == const XPathAnyUri('test')).isTrue();
      check(uri.hashCode).equals('test'.hashCode);
      check(uri.compareTo(const XPathAnyUri('test'))).equals(0);
      check(uri.compareTo(const XPathString('test'))).equals(0);
      check(uri.compareTo(const XPathUntypedAtomic('test'))).equals(0);
      check(() => uri.compareTo(XPathInteger.fromInt(1)))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });
}
