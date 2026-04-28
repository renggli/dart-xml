import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/duration.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

/// Wraps a value in a single-item XPathSequence.
XPathSequence seq(Object value) => XPathSequence.single(value);

void main() {
  group('fn:years-from-duration', () {
    test('returns years from dayTimeDuration', () {
      final d1 = XPathDayTimeDuration(const Duration(days: 1));
      expect(fnYearsFromDuration(context, [seq(d1)]), isXPathSequence([0]));
    });
    test('returns years from yearMonthDuration', () {
      final d = XPathYearMonthDuration(14); // 1 year 2 months
      expect(fnYearsFromDuration(context, [seq(d)]), isXPathSequence([1]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnYearsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:months-from-duration', () {
    test('returns months from dayTimeDuration', () {
      final d1 = XPathDayTimeDuration(const Duration(days: 1));
      expect(fnMonthsFromDuration(context, [seq(d1)]), isXPathSequence([0]));
    });
    test('returns months from yearMonthDuration P1Y2M', () {
      final d = XPathYearMonthDuration(14); // 1 year 2 months → remainder 2
      expect(fnMonthsFromDuration(context, [seq(d)]), isXPathSequence([2]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnMonthsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:days-from-duration', () {
    test('returns days from dayTimeDuration', () {
      final d1 = XPathDayTimeDuration(const Duration(days: 1));
      expect(fnDaysFromDuration(context, [seq(d1)]), isXPathSequence([1]));
    });
    test('returns 0 from yearMonthDuration', () {
      final d = XPathYearMonthDuration(12); // 1 year
      expect(fnDaysFromDuration(context, [seq(d)]), isXPathSequence([0]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnDaysFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:hours-from-duration', () {
    test('returns hours', () {
      final d3 = XPathDayTimeDuration(const Duration(hours: 1));
      expect(fnHoursFromDuration(context, [seq(d3)]), isXPathSequence([1]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnHoursFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:minutes-from-duration', () {
    test('returns minutes', () {
      // 90 minutes = 1 hour 30 minutes; fn:minutes-from-duration returns 30.
      final d = XPathDayTimeDuration(const Duration(minutes: 90));
      expect(fnMinutesFromDuration(context, [seq(d)]), isXPathSequence([30]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnMinutesFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:seconds-from-duration', () {
    test('returns seconds', () {
      // 90 seconds = 1 min 30 sec; fn:seconds-from-duration returns 30.0.
      final d = XPathDayTimeDuration(const Duration(seconds: 90));
      expect(fnSecondsFromDuration(context, [seq(d)]), isXPathSequence([30.0]));
    });
    test('returns empty for empty sequence', () {
      expect(
        fnSecondsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
}
