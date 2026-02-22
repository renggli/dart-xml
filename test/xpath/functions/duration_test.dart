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
  test('fn:years-from-duration', () {
    const d1 = Duration(days: 1);
    expect(
      fnYearsFromDuration(context, [const XPathSequence.single(d1)]),
      isXPathSequence([0]),
    );
  });
  test('fn:months-from-duration', () {
    const d1 = Duration(days: 1);
    expect(
      fnMonthsFromDuration(context, [const XPathSequence.single(d1)]),
      isXPathSequence([0]),
    );
  });
  test('fn:days-from-duration', () {
    const d1 = Duration(days: 1);
    expect(
      fnDaysFromDuration(context, [const XPathSequence.single(d1)]),
      isXPathSequence([1]),
    );
  });
  test('fn:hours-from-duration', () {
    const d3 = Duration(hours: 1);
    expect(
      fnHoursFromDuration(context, [const XPathSequence.single(d3)]),
      isXPathSequence([1]),
    );
  });
  test('fn:minutes-from-duration', () {
    const d = Duration(minutes: 90);
    expect(
      fnMinutesFromDuration(context, [const XPathSequence.single(d)]),
      isXPathSequence([30]),
    );
  });
  test('fn:seconds-from-duration', () {
    const d = Duration(seconds: 90); // 1 min 30 sec
    expect(
      fnSecondsFromDuration(context, [const XPathSequence.single(d)]),
      isXPathSequence([30.0]),
    );
  });
}
