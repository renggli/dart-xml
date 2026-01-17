import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:position', () {
    expect(fnPosition(context, const <XPathSequence>[]), [1]);
  });
  test('fn:last', () {
    expect(fnLast(context, const <XPathSequence>[]), [1]);
  });
  test('fn:current-dateTime', () {
    expect(
      fnCurrentDateTime(context, const <XPathSequence>[]).first,
      isA<DateTime>(),
    );
  });
  test('fn:current-date', () {
    expect(
      fnCurrentDate(context, const <XPathSequence>[]).first,
      isA<DateTime>(),
    );
  });
  test('fn:current-time', () {
    expect(
      fnCurrentTime(context, const <XPathSequence>[]).first,
      isA<DateTime>(),
    );
  });
  test('fn:implicit-timezone', () {
    expect(fnImplicitTimezone(context, const <XPathSequence>[]), [
      Duration.zero,
    ]);
  });
  test('fn:default-collation', () {
    expect(fnDefaultCollation(context, const <XPathSequence>[]), [
      'http://www.w3.org/2005/xpath-functions/collation/codepoint',
    ]);
  });
  test('fn:default-language', () {
    expect(fnDefaultLanguage(context, const <XPathSequence>[]), ['en']);
  });
  test('fn:static-base-uri', () {
    expect(fnStaticBaseUri(context, const <XPathSequence>[]), isEmpty);
  });
}
