import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/duration.dart';

import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:years-from-duration', () {
    test('returns years', () {
      const d1 = Duration(days: 1);
      expect(
        fnYearsFromDuration(context, [const XPathSequence.single(d1)]),
        isXPathSequence([0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnYearsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:months-from-duration', () {
    test('returns months', () {
      const d1 = Duration(days: 1);
      expect(
        fnMonthsFromDuration(context, [const XPathSequence.single(d1)]),
        isXPathSequence([0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnMonthsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:days-from-duration', () {
    test('returns days', () {
      const d1 = Duration(days: 1);
      expect(
        fnDaysFromDuration(context, [const XPathSequence.single(d1)]),
        isXPathSequence([1]),
      );
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
      const d3 = Duration(hours: 1);
      expect(
        fnHoursFromDuration(context, [const XPathSequence.single(d3)]),
        isXPathSequence([1]),
      );
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
      const d = Duration(minutes: 90);
      expect(
        fnMinutesFromDuration(context, [const XPathSequence.single(d)]),
        isXPathSequence([30]),
      );
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
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(
        fnSecondsFromDuration(context, [const XPathSequence.single(d)]),
        isXPathSequence([30.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnSecondsFromDuration(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
}
