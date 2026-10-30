import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/accessor.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:node-name', () {
    test('returns name of element', () {
      final a = document.findAllElements('a').first;
      check(fnNodeName(const XPathConfiguration.raw().context(a), []))
          .isXPathSequence([a.name]);
      check(fnNodeName(context, [seq(a)])).isXPathSequence([a.name]);
    });

    test('returns name of processing-instruction', () {
      final pi = XmlProcessing('target', 'value');
      check(fnNodeName(context, [seq(pi)])).isXPathSequence([
        (Subject<Object?> s) =>
            s.isA<XmlName>().has((n) => n.local, 'local').equals('target'),
      ]);
    });

    test('returns empty for empty sequence', () {
      check(fnNodeName(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:nilled', () {
    test('returns empty for document', () {
      check(fnNilled(context, [seq(document)])).isXPathSequence(isEmpty);
    });

    test('returns false for element without xsi:nil', () {
      check(fnNilled(context, [seq(document.rootElement)]))
          .isXPathSequence([false]);
    });

    test('returns true for element with xsi:nil="true" or xsi:nil="1"', () {
      final doc = XmlDocument.parse(
        '<r xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        '<a xsi:nil="true"/>'
        '<b xsi:nil="1"/>'
        '<c xsi:nil="false"/>'
        '<d xsi:nil="0"/>'
        '</r>',
      );
      final a = doc.findAllElements('a').first;
      final b = doc.findAllElements('b').first;
      final c = doc.findAllElements('c').first;
      final d = doc.findAllElements('d').first;
      check(fnNilled(context, [seq(a)])).isXPathSequence([true]);
      check(fnNilled(context, [seq(b)])).isXPathSequence([true]);
      check(fnNilled(context, [seq(c)])).isXPathSequence([false]);
      check(fnNilled(context, [seq(d)])).isXPathSequence([false]);
    });

    test('returns false for context element (0-arg)', () {
      final elemContext = const XPathConfiguration.raw().context(
        document.rootElement,
      );
      check(fnNilled(elemContext, [])).isXPathSequence([false]);
    });

    test('returns empty for empty sequence', () {
      check(fnNilled(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });
  });

  group('fn:string', () {
    test('returns string value', () {
      check(fnString(context, [seq('foo')])).isXPathSequence(['foo']);
    });

    test('returns empty for empty sequence', () {
      check(fnString(context, [XPathSequence.empty])).isXPathSequence(['']);
    });

    test('returns string value of context node', () {
      check(
        fnString(
          const XPathConfiguration.raw().context(
            document.findAllElements('a').first,
          ),
          [],
        ),
      ).isXPathSequence(['1']);
    });
  });

  group('fn:data', () {
    test('returns empty for empty sequence', () {
      check(fnData(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('returns atomic value', () {
      check(fnData(context, [seq(123)])).isXPathSequence([123]);
    });

    test('returns list value', () {
      check(
        fnData(context, [
          seq([1, 2, 3]),
        ]),
      ).isXPathSequence([1, 2, 3]);
    });

    test('returns string value of context node', () {
      check(fnData(context, []))
          .isXPathSequence([const XPathUntypedAtomic('12')]);
    });
  });

  group('fn:base-uri', () {
    test('returns empty for empty sequence', () {
      check(fnBaseUri(context, const <XPathSequence>[]))
          .isXPathSequence(isEmpty);
    });

    test('returns empty for document', () {
      check(fnBaseUri(context, [seq(document)])).isXPathSequence(isEmpty);
    });

    test('resolves xml:base attributes hierarchy and document base', () {
      final baseDoc = XmlDocument.parse(
        '<doc xml:base="http://example.com/dir/">'
        '  <sub xml:base="sub/"/>'
        '</doc>',
      );
      final subElem = baseDoc.findAllElements('sub').first;
      check(fnBaseUri(context, [seq(subElem)]))
          .isXPathSequence(['http://example.com/dir/sub/']);
    });

    test('uses document URI from configuration', () {
      final doc = XmlDocument.parse('<doc><item/></doc>');
      final config = XPathConfiguration.raw(
        documents: {'http://example.com/test.xml': doc},
      );
      final ctx = config.context(doc.rootElement);
      check(fnBaseUri(ctx, [seq(doc.findAllElements('item').first)]))
          .isXPathSequence(['http://example.com/test.xml']);
    });
  });

  group('fn:document-uri', () {
    test('returns empty for empty sequence', () {
      check(fnDocumentUri(context, const <XPathSequence>[]))
          .isXPathSequence(isEmpty);
    });

    test('returns empty for document', () {
      check(fnDocumentUri(context, [seq(document)])).isXPathSequence(isEmpty);
    });

    test('returns URI for registered document', () {
      final doc = XmlDocument.parse('<doc/>');
      final config = XPathConfiguration.raw(
        documents: {'https://example.com/doc.xml': doc},
      );
      final ctx = config.context(doc);
      check(fnDocumentUri(ctx, [seq(doc)]))
          .isXPathSequence(['https://example.com/doc.xml']);
    });
  });

  group('fn:parse-xml', () {
    test('parses xml string', () {
      check(fnParseXml(context, [seq('<r><a>1</a></r>')]))
          .isXPathSequence([isA<XmlDocument>()]);
    });

    test('returns empty for empty sequence', () {
      check(fnParseXml(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });

    test('throws exception on invalid xml', () {
      check(() => fnParseXml(context, [seq('<r>unclosed')]))
          .throws<XmlException>();
    });
  });

  group('fn:parse-xml-fragment', () {
    test('parses xml fragment string', () {
      check(fnParseXmlFragment(context, [seq('<a>1</a><b>2</b>')]))
          .isXPathSequence([isA<XmlDocumentFragment>()]);
    });

    test('returns empty for empty sequence', () {
      check(fnParseXmlFragment(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });

    test('throws exception on invalid xml fragment', () {
      check(() => fnParseXmlFragment(context, [seq('<r>unclosed')]))
          .throws<XmlException>();
    });
  });
}
