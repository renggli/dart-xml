import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/duration.dart';
import 'package:xml/xpath.dart';

void main() {
  test('op:duration-equal', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 1);
    const d3 = Duration(days: 2);
    expect(
      opDurationEqual(
        const XPathSequence.single(d1),
        const XPathSequence.single(d2),
      ),
      [true],
    );
    expect(
      opDurationEqual(
        const XPathSequence.single(d1),
        const XPathSequence.single(d3),
      ),
      [false],
    );
  });
  test('op:yearMonthDuration-less-than', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opYearMonthDurationLessThan(
        const XPathSequence.single(d1),
        const XPathSequence.single(d2),
      ),
      [true],
    );
  });
  test('op:yearMonthDuration-greater-than', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opYearMonthDurationGreaterThan(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ),
      [true],
    );
  });
  test('op:dayTimeDuration-less-than', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDayTimeDurationLessThan(
        const XPathSequence.single(d1),
        const XPathSequence.single(d2),
      ),
      [true],
    );
  });
  test('op:dayTimeDuration-greater-than', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDayTimeDurationGreaterThan(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ),
      [true],
    );
  });
  test('op:add-yearMonthDurations', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opAddYearMonthDurations(
        const XPathSequence.single(d1),
        const XPathSequence.single(d2),
      ).first,
      d1 + d2,
    );
  });
  test('op:subtract-yearMonthDurations', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opSubtractYearMonthDurations(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ).first,
      d1,
    );
  });
  test('op:multiply-yearMonthDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opMultiplyYearMonthDuration(
        const XPathSequence.single(d1),
        const XPathSequence.single(2),
      ).first,
      d2,
    );
  });
  test('op:divide-yearMonthDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDivideYearMonthDuration(
        const XPathSequence.single(d2),
        const XPathSequence.single(2),
      ).first,
      d1,
    );
  });
  test('op:divide-yearMonthDuration-by-yearMonthDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDivideYearMonthDurationByYearMonthDuration(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ),
      [2.0],
    );
  });
  test('op:add-dayTimeDurations', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opAddDayTimeDurations(
        const XPathSequence.single(d1),
        const XPathSequence.single(d2),
      ).first,
      d1 + d2,
    );
  });
  test('op:subtract-dayTimeDurations', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opSubtractDayTimeDurations(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ).first,
      d1,
    );
  });
  test('op:multiply-dayTimeDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opMultiplyDayTimeDuration(
        const XPathSequence.single(d1),
        const XPathSequence.single(2),
      ).first,
      d2,
    );
  });
  test('op:divide-dayTimeDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDivideDayTimeDuration(
        const XPathSequence.single(d2),
        const XPathSequence.single(2),
      ).first,
      d1,
    );
  });
  test('op:divide-dayTimeDuration-by-dayTimeDuration', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    expect(
      opDivideDayTimeDurationByDayTimeDuration(
        const XPathSequence.single(d2),
        const XPathSequence.single(d1),
      ),
      [2.0],
    );
  });
}
