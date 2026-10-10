import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

class _CustomAtomic extends XPathAtomic {
  const new(this.value);

  @override
  final Object value;

  @override
  XPathType get type => xsAnyAtomicType;

  @override
  bool get effectiveBooleanValue => true;

  @override
  String get stringValue => value.toString();
}

void main() {
  group('XPathAtomic base', () {
    test('atomize returns itself', () {
      const atomic = _CustomAtomic('foo');
      check(atomic.atomize()).identicalTo(atomic);
    });

    test('isNumeric defaults to false', () {
      const atomic = _CustomAtomic('foo');
      check(atomic.isNumeric).isFalse();
    });

    test('compareTo default throws evaluation exception', () {
      const a = _CustomAtomic('a');
      const b = _CustomAtomic('b');
      check(() => a.compareTo(b))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('toString delegates to stringValue', () {
      const atomic = _CustomAtomic('hello');
      check(atomic.toString()).equals('hello');
    });
  });
}
