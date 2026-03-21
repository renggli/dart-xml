import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

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
      expect(fnCurrentDateTime(context, []).first, isA<DateTime>());
    });
  });

  group('fn:current-date', () {
    test('returns current date', () {
      expect(fnCurrentDate(context, []).first, isA<DateTime>());
    });
  });

  group('fn:current-time', () {
    test('returns current time', () {
      expect(fnCurrentTime(context, []).first, isA<DateTime>());
    });
  });

  group('fn:implicit-timezone', () {
    test('returns implicit timezone', () {
      expect(fnImplicitTimezone(context, []), isXPathSequence([Duration.zero]));
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
  });
}
