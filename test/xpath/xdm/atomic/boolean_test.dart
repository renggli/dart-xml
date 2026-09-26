import 'package:test/test.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathBoolean', () {
    test('constants and singletons', () {
      expect(XPathBoolean.trueInstance.value, isTrue);
      expect(XPathBoolean.falseInstance.value, isFalse);
      expect(XPathBoolean(true), same(XPathBoolean.trueInstance));
      expect(XPathBoolean(false), same(XPathBoolean.falseInstance));
      expect(XPathBoolean.from(true), same(XPathBoolean.trueInstance));
      expect(XPathBoolean.fromBool(false), same(XPathBoolean.falseInstance));
    });

    test('properties', () {
      const t = XPathBoolean.trueInstance;
      expect(t.type, equals(xsBoolean));
      expect(t.stringValue, equals('true'));
      expect(t.effectiveBooleanValue, isTrue);

      const f = XPathBoolean.falseInstance;
      expect(f.type, equals(xsBoolean));
      expect(f.stringValue, equals('false'));
      expect(f.effectiveBooleanValue, isFalse);
    });

    test('compareTo', () {
      const t = XPathBoolean.trueInstance;
      const f = XPathBoolean.falseInstance;

      expect(f.compareTo(t), equals(-1));
      expect(t.compareTo(f), equals(1));
      expect(t.compareTo(XPathBoolean(true)), equals(0));
      expect(
        () => t.compareTo(XPathInteger.fromInt(1)),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('compareTo incompatible type throws', () {
      const t = XPathBoolean.trueInstance;
      expect(
        () => t.compareTo(const XPathString('true')),
        throwsA(isA<Exception>()),
      );
    });

    test('equality with bool and Object', () {
      const t = XPathBoolean.trueInstance;
      expect(t == (true as Object), isTrue);
      expect(t == (false as Object), isFalse);
      expect(t == XPathBoolean(true), isTrue);
      expect(t == XPathBoolean(false), isFalse);
      expect(t == Object(), isFalse);
      expect(t.hashCode, equals(true.hashCode));
    });
  });
}
