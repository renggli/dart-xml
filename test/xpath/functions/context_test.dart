import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:position', () {
    expect(fnPosition(context, []), [1]);
  });
  test('fn:last', () {
    expect(fnLast(context, []), [1]);
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
    expect(fnImplicitTimezone(context, []), [Duration.zero]);
  });
  test('fn:default-collation', () {
    expect(fnDefaultCollation(context, []), [
      'http://www.w3.org/2005/xpath-functions/collation/codepoint',
    ]);
  });
  test('fn:default-language', () {
    expect(fnDefaultLanguage(context, []), ['en']);
  });
  test('fn:static-base-uri', () {
    expect(fnStaticBaseUri(context, []), isEmpty);
  });
}
