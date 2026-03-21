import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/accessor.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';
import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:node-name', () {
    test('returns name of element', () {
      final a = document.findAllElements('a').first;
      expect(fnNodeName(XPathContext.empty(a), []), isXPathSequence([a.name]));
      expect(
        fnNodeName(context, [XPathSequence.single(a)]),
        isXPathSequence([a.name]),
      );
    });

    test('returns name of processing-instruction', () {
      final pi = XmlProcessing('target', 'value');
      expect(
        fnNodeName(context, [XPathSequence.single(pi)]),
        isXPathSequence([
          isA<XmlName>().having((name) => name.local, 'localName', 'target'),
        ]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnNodeName(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:nilled', () {
    test('returns empty for document', () {
      expect(
        fnNilled(context, [XPathSequence.single(document)]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns false for element', () {
      expect(
        fnNilled(context, [XPathSequence.single(document.rootElement)]),
        isXPathSequence([false]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnNilled(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:string', () {
    test('returns string value', () {
      expect(
        fnString(context, [const XPathSequence.single('foo')]),
        isXPathSequence(['foo']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(fnString(context, [XPathSequence.empty]), isXPathSequence(['']));
    });

    test('returns string value of context node', () {
      expect(
        fnString(XPathContext.empty(document.findAllElements('a').first), []),
        isXPathSequence(['1']),
      );
    });
  });

  group('fn:data', () {
    test('returns empty for empty sequence', () {
      expect(fnData(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });

    test('returns atomic value', () {
      expect(
        fnData(context, [const XPathSequence.single(123)]),
        isXPathSequence([123]),
      );
    });

    test('returns list value', () {
      expect(
        fnData(context, [
          const XPathSequence.single([1, 2, 3]),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });

    test('returns string value of context node', () {
      expect(fnData(context, []), isXPathSequence(['12']));
    });
  });

  group('fn:base-uri', () {
    test('returns empty for empty sequence', () {
      expect(
        fnBaseUri(context, const <XPathSequence>[]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns empty for document', () {
      expect(
        fnBaseUri(context, [XPathSequence.single(document)]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:document-uri', () {
    test('returns empty for empty sequence', () {
      expect(
        fnDocumentUri(context, const <XPathSequence>[]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns empty for document', () {
      expect(
        fnDocumentUri(context, [XPathSequence.single(document)]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:serialize', () {
    test('serializes sequence', () {
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
    });

    test('returns empty string for empty sequence', () {
      expect(
        fnSerialize(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:parse-xml', () {
    test('parses xml string', () {
      expect(
        fnParseXml(context, [const XPathSequence.single('<r><a>1</a></r>')]),
        isXPathSequence([isA<XmlDocument>()]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnParseXml(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('throws exception on invalid xml', () {
      expect(
        () => fnParseXml(context, [const XPathSequence.single('<r>unclosed')]),
        throwsA(isA<XmlException>()),
      );
    });
  });

  group('fn:parse-xml-fragment', () {
    test('parses xml fragment string', () {
      expect(
        fnParseXmlFragment(context, [
          const XPathSequence.single('<a>1</a><b>2</b>'),
        ]),
        isXPathSequence([isA<XmlDocumentFragment>()]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnParseXmlFragment(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('throws exception on invalid xml fragment', () {
      expect(
        () => fnParseXmlFragment(context, [
          const XPathSequence.single('<r>unclosed'),
        ]),
        throwsA(isA<XmlException>()),
      );
    });
  });
}
