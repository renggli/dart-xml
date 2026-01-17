import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/accessor.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:node-name', () {
    final a = document.findAllElements('a').first;
    expect(fnNodeName(XPathContext(a), []), [a.name]);
    expect(fnNodeName(context, [XPathSequence.single(a)]), [a.name]);
    expect(fnNodeName(context, [XPathSequence.empty]), isEmpty);
  });
  test('fn:node-name (processing-instruction)', () {
    final pi = XmlProcessing('target', 'value');
    expect(
      fnNodeName(context, [XPathSequence.single(pi)]).first.toString(),
      'target',
    );
  });
  test('fn:nilled', () {
    expect(fnNilled(context, [XPathSequence.single(document)]), isEmpty);
    expect(fnNilled(context, [XPathSequence.single(document.rootElement)]), [
      false,
    ]);
    expect(fnNilled(context, [XPathSequence.empty]), isEmpty);
  });
  test('fn:string', () {
    expect(fnString(context, [const XPathSequence.single('foo')]), [
      const v31.XPathString('foo'),
    ]);
    expect(fnString(context, [XPathSequence.empty]), [v31.XPathString.empty]);
    expect(fnString(XPathContext(document.findAllElements('a').first), []), [
      const v31.XPathString('1'),
    ]);
  });
  test('fn:data', () {
    expect(fnData(context, [XPathSequence.empty]), isEmpty);
    expect(fnData(context, [const XPathSequence.single(123)]), [123]);
    expect(
      fnData(context, [
        const XPathSequence.single([1, 2, 3]),
      ]),
      [1, 2, 3],
    );
  });
  test('fn:base-uri', () {
    expect(fnBaseUri(context, const <XPathSequence>[]), isEmpty);
    expect(fnBaseUri(context, [XPathSequence.single(document)]), isEmpty);
  });
  test('fn:document-uri', () {
    expect(fnDocumentUri(context, const <XPathSequence>[]), isEmpty);
    expect(fnDocumentUri(context, [XPathSequence.single(document)]), isEmpty);
  });
}
