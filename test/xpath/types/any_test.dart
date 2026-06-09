import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/any.dart';
import 'package:xml/xml.dart';

void main() {
  group('xsAny', () {
    test('name', () {
      expect(xsAny.name, 'item()');
    });
    test('matches', () {
      expect(xsAny.matches(1), isTrue);
      expect(xsAny.matches('abc'), isTrue);
      expect(xsAny.matches(true), isTrue);
      expect(xsAny.matches(Object()), isTrue);
    });
    test('cast', () {
      expect(xsAny.cast(1), 1);
      expect(xsAny.cast('abc'), 'abc');
      final object = Object();
      expect(xsAny.cast(object), same(object));
    });
  });

  group('xsAnyAtomicType', () {
    test('name', () {
      expect(xsAnyAtomicType.name, 'xs:anyAtomicType');
    });
    test('matches', () {
      expect(xsAnyAtomicType.matches(1), isTrue);
      expect(xsAnyAtomicType.matches('abc'), isTrue);
      expect(xsAnyAtomicType.matches(true), isTrue);
      expect(xsAnyAtomicType.matches(Object()), isTrue);
      expect(xsAnyAtomicType.matches(XmlDocument()), isFalse);
    });
    test('cast', () {
      expect(xsAnyAtomicType.cast(1), 1);
      expect(xsAnyAtomicType.cast('abc'), 'abc');
      final object = Object();
      expect(xsAnyAtomicType.cast(object), same(object));
      expect(
        () => xsAnyAtomicType.cast(XmlDocument()),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsError', () {
    test('name', () {
      expect(xsError.name, 'xs:error');
    });
    test('matches', () {
      expect(xsError.matches(1), isFalse);
      expect(xsError.matches('abc'), isFalse);
      expect(xsError.matches(true), isFalse);
      expect(xsError.matches(Object()), isFalse);
    });
    test('cast', () {
      expect(() => xsError.cast(1), throwsA(isA<XPathEvaluationException>()));
      expect(
        () => xsError.cast('abc'),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
