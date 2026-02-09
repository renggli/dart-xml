import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:position', () {
    expect(fnPosition(context, []), isXPathSequence([1]));
  });
  test('fn:last', () {
    expect(fnLast(context, []), isXPathSequence([1]));
  });
  test('fn:current-dateTime', () {
    expect(fnCurrentDateTime(context, []).first, isA<DateTime>());
  });
  test('fn:current-date', () {
    expect(fnCurrentDate(context, []).first, isA<DateTime>());
  });
  test('fn:current-time', () {
    expect(fnCurrentTime(context, []).first, isA<DateTime>());
  });
  test('fn:implicit-timezone', () {
    expect(fnImplicitTimezone(context, []), isXPathSequence([Duration.zero]));
  });
  test('fn:default-collation', () {
    expect(
      fnDefaultCollation(context, []),
      isXPathSequence([
        'http://www.w3.org/2005/xpath-functions/collation/codepoint',
      ]),
    );
  });
  test('fn:default-language', () {
    expect(fnDefaultLanguage(context, []), isXPathSequence(['en']));
  });
  test('fn:static-base-uri', () {
    expect(fnStaticBaseUri(context, []), isXPathSequence(isEmpty));
  });
}
