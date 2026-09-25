import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:position', () {
    test('returns position', () {
      expect(fnPosition(context, []), isXPathSequence([1]));
    });
  });

  group('fn:last', () {
    test('returns last position', () {
      expect(fnLast(context, []), isXPathSequence([1]));
    });
  });

  group('fn:current-dateTime', () {
    test('returns current date time', () {
      expect(fnCurrentDateTime(context, []).first, isA<XPathDateTime>());
    });
  });

  group('fn:current-date', () {
    test('returns current date', () {
      final date = fnCurrentDate(context, []).first;
      expect(date, isA<XPathDateTime>());
      expect((date as XPathDateTime).type, xsDate);
    });
  });

  group('fn:current-time', () {
    test('returns current time', () {
      final time = fnCurrentTime(context, []).first;
      expect(time, isA<XPathDateTime>());
      expect((time as XPathDateTime).type, xsTime);
    });
  });

  group('fn:implicit-timezone', () {
    test('returns implicit timezone', () {
      final tz = fnImplicitTimezone(context, []).first;
      expect(tz, isA<XPathDuration>());
      expect((tz as XPathDuration).type, xsDayTimeDuration);
    });
  });

  group('fn:default-collation', () {
    test('returns default collation', () {
      expect(
        fnDefaultCollation(context, []),
        isXPathSequence([
          'http://www.w3.org/2005/xpath-functions/collation/codepoint',
        ]),
      );
    });
  });

  group('fn:default-language', () {
    test('returns default language', () {
      expect(fnDefaultLanguage(context, []), isXPathSequence(['en']));
    });
  });

  group('fn:static-base-uri', () {
    test('returns static base uri', () {
      expect(fnStaticBaseUri(context, []), isXPathSequence(isEmpty));
    });
    test('returns configured base uri', () {
      final contextWithBase = const XPathConfiguration.raw(
        baseUri: 'http://example.com/',
      ).context(document);
      expect(
        fnStaticBaseUri(contextWithBase, []),
        isXPathSequence(['http://example.com/']),
      );
    });
  });
}
