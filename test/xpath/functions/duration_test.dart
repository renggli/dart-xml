import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/duration.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

/// Wraps a value in a single-item XPathSequence.
XPathSequence seq(XPathItem value) => XPathSequence.single(value);

void main() {
  group('fn:years-from-duration', () {
    test('returns years from dayTimeDuration', () {
      const d1 = XPathDuration.dayTime(86400000000);
      check(fnYearsFromDuration(context, [seq(d1)])).isXPathSequence([0]);
    });
    test('returns years from yearMonthDuration', () {
      const d = XPathDuration.yearMonth(14); // 1 year 2 months
      check(fnYearsFromDuration(context, [seq(d)])).isXPathSequence([1]);
    });
    test('returns empty for empty sequence', () {
      check(fnYearsFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:months-from-duration', () {
    test('returns months from dayTimeDuration', () {
      const d1 = XPathDuration.dayTime(86400000000);
      check(fnMonthsFromDuration(context, [seq(d1)])).isXPathSequence([0]);
    });
    test('returns months from yearMonthDuration P1Y2M', () {
      const d = XPathDuration.yearMonth(14); // 1 year 2 months → remainder 2
      check(fnMonthsFromDuration(context, [seq(d)])).isXPathSequence([2]);
    });
    test('returns empty for empty sequence', () {
      check(fnMonthsFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:days-from-duration', () {
    test('returns days from dayTimeDuration', () {
      const d1 = XPathDuration.dayTime(86400000000);
      check(fnDaysFromDuration(context, [seq(d1)])).isXPathSequence([1]);
    });
    test('returns 0 from yearMonthDuration', () {
      const d = XPathDuration.yearMonth(12); // 1 year
      check(fnDaysFromDuration(context, [seq(d)])).isXPathSequence([0]);
    });
    test('returns empty for empty sequence', () {
      check(fnDaysFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:hours-from-duration', () {
    test('returns hours', () {
      const d3 = XPathDuration.dayTime(3600000000);
      check(fnHoursFromDuration(context, [seq(d3)])).isXPathSequence([1]);
    });
    test('returns empty for empty sequence', () {
      check(fnHoursFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:minutes-from-duration', () {
    test('returns minutes', () {
      // 90 minutes = 1 hour 30 minutes; fn:minutes-from-duration returns 30.
      const d = XPathDuration.dayTime(5400000000);
      check(fnMinutesFromDuration(context, [seq(d)])).isXPathSequence([30]);
    });
    test('returns empty for empty sequence', () {
      check(fnMinutesFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:seconds-from-duration', () {
    test('returns seconds', () {
      // 90 seconds = 1 min 30 sec; fn:seconds-from-duration returns 30.0.
      const d = XPathDuration.dayTime(90000000);
      check(fnSecondsFromDuration(context, [seq(d)])).isXPathSequence([30.0]);
    });
    test('returns empty for empty sequence', () {
      check(fnSecondsFromDuration(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });
}
