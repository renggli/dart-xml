import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathBoolean', () {
    test('constants and singletons', () {
      check(XPathBoolean.trueInstance.value).isTrue();
      check(XPathBoolean.falseInstance.value).isFalse();
      check(XPathBoolean(true)).identicalTo(XPathBoolean.trueInstance);
      check(XPathBoolean(false)).identicalTo(XPathBoolean.falseInstance);
      check(XPathBoolean.from(true)).identicalTo(XPathBoolean.trueInstance);
      check(XPathBoolean.fromBool(false))
          .identicalTo(XPathBoolean.falseInstance);
    });

    test('properties', () {
      const t = XPathBoolean.trueInstance;
      check(t.type).equals(xsBoolean);
      check(t.stringValue).equals('true');
      check(t.effectiveBooleanValue).isTrue();

      const f = XPathBoolean.falseInstance;
      check(f.type).equals(xsBoolean);
      check(f.stringValue).equals('false');
      check(f.effectiveBooleanValue).isFalse();
    });

    test('compareTo', () {
      const t = XPathBoolean.trueInstance;
      const f = XPathBoolean.falseInstance;

      check(f.compareTo(t)).equals(-1);
      check(t.compareTo(f)).equals(1);
      check(t.compareTo(XPathBoolean(true))).equals(0);
      check(() => t.compareTo(XPathInteger.fromInt(1)))
          .throws<XPathEvaluationException>();
    });

    test('compareTo incompatible type throws', () {
      const t = XPathBoolean.trueInstance;
      check(() => t.compareTo(const XPathString('true'))).throws<Exception>();
    });

    test('equality with bool and Object', () {
      const t = XPathBoolean.trueInstance;
      check(t == (true as Object)).isTrue();
      check(t == (false as Object)).isFalse();
      check(t == XPathBoolean(true)).isTrue();
      check(t == XPathBoolean(false)).isFalse();
      check(t == Object()).isFalse();
      check(t.hashCode).equals(true.hashCode);
    });
  });
}
