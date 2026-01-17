import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('uri', () {
    test('fn:resolve-uri', () {
      expect(
        fnResolveUri(context, [
          const XPathSequence.single(v31.XPathString('foo')),
          const XPathSequence.single(v31.XPathString('http://example.com/')),
        ]),
        [const v31.XPathString('http://example.com/foo')],
      );
      expect(
        () => fnResolveUri(context, [
          const XPathSequence.single(v31.XPathString('foo')),
          const XPathSequence.single(v31.XPathString('::invalid::')),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('fn:encode-for-uri', () {
      expect(fnEncodeForUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
    test('fn:iri-to-uri', () {
      expect(fnIriToUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
    test('fn:escape-html-uri', () {
      expect(fnEscapeHtmlUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
  });
}
