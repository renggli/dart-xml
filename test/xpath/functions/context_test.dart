import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:position', () {
    test('returns position', () {
      check(fnPosition(context, [])).isXPathSequence([1]);
    });
  });

  group('fn:last', () {
    test('returns last position', () {
      check(fnLast(context, [])).isXPathSequence([1]);
    });
  });

  group('fn:current-dateTime', () {
    test('returns current date time', () {
      check(fnCurrentDateTime(context, []).first).isA<XPathDateTime>();
    });
  });

  group('fn:current-date', () {
    test('returns current date', () {
      final date = fnCurrentDate(context, []).first;
      check(date).isA<XPathDateTime>();
      check((date as XPathDateTime).type).equals(xsDate);
    });
  });

  group('fn:current-time', () {
    test('returns current time', () {
      final time = fnCurrentTime(context, []).first;
      check(time).isA<XPathDateTime>();
      check((time as XPathDateTime).type).equals(xsTime);
    });
  });

  group('fn:implicit-timezone', () {
    test('returns implicit timezone', () {
      final tz = fnImplicitTimezone(context, []).first;
      check(tz).isA<XPathDuration>();
      check((tz as XPathDuration).type).equals(xsDayTimeDuration);
    });
  });

  group('fn:default-collation', () {
    test('returns default collation', () {
      check(fnDefaultCollation(context, [])).isXPathSequence([
        'http://www.w3.org/2005/xpath-functions/collation/codepoint',
      ]);
    });
  });

  group('fn:default-language', () {
    test('returns default language', () {
      check(fnDefaultLanguage(context, [])).isXPathSequence(['en']);
    });
  });

  group('fn:static-base-uri', () {
    test('returns static base uri', () {
      check(fnStaticBaseUri(context, [])).isXPathSequence(isEmpty);
    });
    test('returns configured base uri', () {
      final contextWithBase = const XPathConfiguration.raw(
        baseUri: 'http://example.com/',
      ).context(document);
      check(fnStaticBaseUri(contextWithBase, []))
          .isXPathSequence(['http://example.com/']);
    });
  });
}
