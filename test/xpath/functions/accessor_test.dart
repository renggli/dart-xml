import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/accessor.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';
import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:node-name', () {
    final a = document.findAllElements('a').first;
    expect(fnNodeName(XPathContext(a), []), isXPathSequence([a.name]));
    expect(
      fnNodeName(context, [XPathSequence.single(a)]),
      isXPathSequence([a.name]),
    );
    expect(
      fnNodeName(context, [XPathSequence.empty]),
      isXPathSequence(isEmpty),
    );
  });
  test('fn:node-name (processing-instruction)', () {
    final pi = XmlProcessing('target', 'value');
    expect(
      fnNodeName(context, [XPathSequence.single(pi)]),
      isXPathSequence([
        isA<XmlName>().having((name) => name.local, 'localName', 'target'),
      ]),
    );
  });
  test('fn:nilled', () {
    expect(
      fnNilled(context, [XPathSequence.single(document)]),
      isXPathSequence(isEmpty),
    );
    expect(
      fnNilled(context, [XPathSequence.single(document.rootElement)]),
      isXPathSequence([false]),
    );
    expect(fnNilled(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
  });
  test('fn:string', () {
    expect(
      fnString(context, [const XPathSequence.single('foo')]),
      isXPathSequence(['foo']),
    );
    expect(fnString(context, [XPathSequence.empty]), isXPathSequence(['']));
    expect(
      fnString(XPathContext(document.findAllElements('a').first), []),
      isXPathSequence(['1']),
    );
  });
  test('fn:data', () {
    expect(fnData(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    expect(
      fnData(context, [const XPathSequence.single(123)]),
      isXPathSequence([123]),
    );
    expect(
      fnData(context, [
        const XPathSequence.single([1, 2, 3]),
      ]),
      isXPathSequence([1, 2, 3]),
    );
  });
  test('fn:base-uri', () {
    expect(
      fnBaseUri(context, const <XPathSequence>[]),
      isXPathSequence(isEmpty),
    );
    expect(
      fnBaseUri(context, [XPathSequence.single(document)]),
      isXPathSequence(isEmpty),
    );
  });
  test('fn:document-uri', () {
    expect(
      fnDocumentUri(context, const <XPathSequence>[]),
      isXPathSequence(isEmpty),
    );
    expect(
      fnDocumentUri(context, [XPathSequence.single(document)]),
      isXPathSequence(isEmpty),
    );
  });
  test('fn:serialize', () {
    expect(
      fnSerialize(context, [
        XPathSequence([
          document.findAllElements('a').first,
          'text',
          document.findAllElements('b').first,
        ]),
      ]),
      isXPathSequence(['<a>1</a>text<b>2</b>']),
    );
    expect(fnSerialize(context, [XPathSequence.empty]), isXPathSequence(['']));
  });
  test('fn:parse-xml', () {
    expect(
      fnParseXml(context, [const XPathSequence.single('<r><a>1</a></r>')]),
      isXPathSequence([isA<XmlDocument>()]),
    );
    expect(
      fnParseXml(context, [XPathSequence.empty]),
      isXPathSequence(isEmpty),
    );
    expect(
      () => fnParseXml(context, [const XPathSequence.single('<r>unclosed')]),
      throwsA(isA<XmlException>()),
    );
  });
  test('fn:parse-xml-fragment', () {
    expect(
      fnParseXmlFragment(context, [
        const XPathSequence.single('<a>1</a><b>2</b>'),
      ]),
      isXPathSequence([isA<XmlDocumentFragment>()]),
    );
    expect(
      fnParseXmlFragment(context, [XPathSequence.empty]),
      isXPathSequence(isEmpty),
    );
    expect(
      () => fnParseXmlFragment(context, [
        const XPathSequence.single('<r>unclosed'),
      ]),
      throwsA(isA<XmlException>()),
    );
  });
}
