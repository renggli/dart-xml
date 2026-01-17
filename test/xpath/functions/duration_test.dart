import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/duration.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('duration', () {
    test('op:duration-equal', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 1);
      const d3 = Duration(days: 2);
      expect(
        opDurationEqual(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
      expect(
        opDurationEqual(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d3),
        ]),
        [false],
      );
    });
    test('op:yearMonthDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationLessThan(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
    });
    test('op:yearMonthDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationGreaterThan(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [true],
      );
    });
    test('op:dayTimeDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationLessThan(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
    });
    test('op:dayTimeDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationGreaterThan(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [true],
      );
    });
    test('op:add-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddYearMonthDurations(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]).first,
        d1 + d2,
      );
    });
    test('op:subtract-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractYearMonthDurations(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]).first,
        d1,
      );
    });
    test('op:multiply-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyYearMonthDuration(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ]).first,
        d2,
      );
    });
    test('op:divide-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ]).first,
        d1,
      );
    });
    test('op:divide-yearMonthDuration-by-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDurationByYearMonthDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [2.0],
      );
    });
    test('op:add-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddDayTimeDurations(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]).first,
        d1 + d2,
      );
    });
    test('op:subtract-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractDayTimeDurations(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]).first,
        d1,
      );
    });
    test('op:multiply-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyDayTimeDuration(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ]).first,
        d2,
      );
    });
    test('op:divide-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ]).first,
        d1,
      );
    });
    test('op:divide-dayTimeDuration-by-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDurationByDayTimeDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [2.0],
      );
    });
    test('fn:years-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnYearsFromDuration(context, [const XPathSequence.single(d1)]), [
        0,
      ]);
    });
    test('fn:months-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnMonthsFromDuration(context, [const XPathSequence.single(d1)]), [
        0,
      ]);
    });
    test('fn:days-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnDaysFromDuration(context, [const XPathSequence.single(d1)]), [
        1,
      ]);
    });
    test('fn:hours-from-duration', () {
      const d3 = Duration(hours: 1);
      expect(fnHoursFromDuration(context, [const XPathSequence.single(d3)]), [
        1,
      ]);
    });
    test('fn:minutes-from-duration', () {
      const d = Duration(minutes: 90);
      expect(fnMinutesFromDuration(context, [const XPathSequence.single(d)]), [
        30,
      ]);
    });
    test('fn:seconds-from-duration', () {
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(fnSecondsFromDuration(context, [const XPathSequence.single(d)]), [
        30.0,
      ]);
    });
  });
}
