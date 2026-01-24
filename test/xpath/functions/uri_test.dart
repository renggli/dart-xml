import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:resolve-uri', () {
    expect(
      fnResolveUri(context, [
        const XPathSequence.single('foo'),
        const XPathSequence.single('http://example.com/'),
      ]),
      ['http://example.com/foo'],
    );
    expect(
      () => fnResolveUri(context, [
        const XPathSequence.single('foo'),
        const XPathSequence.single('::invalid::'),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('fn:encode-for-uri', () {
    expect(fnEncodeForUri(context, [const XPathSequence.single(' ')]), ['%20']);
  });
  test('fn:iri-to-uri', () {
    expect(fnIriToUri(context, [const XPathSequence.single(' ')]), ['%20']);
  });
  test('fn:escape-html-uri', () {
    expect(fnEscapeHtmlUri(context, [const XPathSequence.single(' ')]), [
      '%20',
    ]);
  });
}
