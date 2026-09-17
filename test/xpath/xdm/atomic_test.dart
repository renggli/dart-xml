import 'package:test/test.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/types.dart';

import '../../utils/matchers.dart';

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
      expect(atomic.atomize(), same(atomic));
    });

    test('isNumeric defaults to false', () {
      const atomic = _CustomAtomic('foo');
      expect(atomic.isNumeric, isFalse);
    });

    test('compareTo default throws evaluation exception', () {
      const a = _CustomAtomic('a');
      const b = _CustomAtomic('b');
      expect(() => a.compareTo(b), throwsA(isXPathEvaluationException()));
    });

    test('toString delegates to stringValue', () {
      const atomic = _CustomAtomic('hello');
      expect(atomic.toString(), equals('hello'));
    });
  });
}
