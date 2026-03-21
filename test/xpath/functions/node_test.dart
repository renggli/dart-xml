import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/node.dart';

import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:name', () {
    test('returns name of element', () {
      final a = document.findAllElements('a').first;
      expect(
        fnName(context, [XPathSequence.single(a)]),
        isXPathSequence(['a']),
      );
    });

    test('returns target of processing instruction', () {
      final pi = XmlProcessing('target', 'data');
      expect(
        fnName(context, [XPathSequence.single(pi)]),
        isXPathSequence(['target']),
      );
    });

    test('returns name of attribute', () {
      final attr = XmlAttribute(const XmlName('a'), '1');
      expect(
        fnName(context, [XPathSequence.single(attr)]),
        isXPathSequence(['a']),
      );
    });

    test('returns empty string for document', () {
      expect(
        fnName(context, [XPathSequence.single(document)]),
        isXPathSequence(['']),
      );
    });

    test('returns empty string for empty sequence', () {
      expect(fnName(context, [XPathSequence.empty]), isXPathSequence(['']));
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'name(/r/a)', isXPathSequence(['a']));
      expectEvaluate(
        xml,
        '/r/*[name()="a"]',
        isXPathSequence(xml.findAllElements('a')),
      );
    });
  });

  group('fn:local-name', () {
    test('returns local name of element', () {
      final a = document.findAllElements('a').first;
      expect(
        fnLocalName(context, [XPathSequence.single(a)]),
        isXPathSequence(['a']),
      );
    });

    test('returns target of processing instruction', () {
      final pi = XmlProcessing('target', 'data');
      expect(
        fnLocalName(context, [XPathSequence.single(pi)]),
        isXPathSequence(['target']),
      );
    });

    test('returns local name of attribute', () {
      final attr = XmlAttribute(const XmlName('a'), '1');
      expect(
        fnLocalName(context, [XPathSequence.single(attr)]),
        isXPathSequence(['a']),
      );
    });

    test('returns empty string for empty sequence', () {
      expect(
        fnLocalName(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'local-name(/r/a)', isXPathSequence(['a']));
      expectEvaluate(
        xml,
        '/r/*[local-name()="a"]',
        isXPathSequence(xml.findAllElements('a')),
      );
    });
  });

  group('fn:namespace-uri', () {
    test('returns namespace uri of element', () {
      final a = document.findAllElements('a').first;
      expect(
        fnNamespaceUri(context, [XPathSequence.single(a)]),
        isXPathSequence(['']),
      );
    });

    test('returns namespace uri of attribute', () {
      final attr = XmlAttribute(const XmlName('a'), '1');
      expect(
        fnNamespaceUri(context, [XPathSequence.single(attr)]),
        isXPathSequence(['']),
      );
    });

    test('returns empty string for empty sequence', () {
      expect(
        fnNamespaceUri(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'namespace-uri(/r/a)', isXPathSequence(['']));
      expectEvaluate(
        xml,
        '/r/*[namespace-uri()=""]',
        isXPathSequence(xml.rootElement.findElements('*')),
      );
    });
  });

  group('fn:root', () {
    test('returns root node', () {
      final a = document.findAllElements('a').first;
      expect(
        fnRoot(context, [XPathSequence.single(a)]),
        isXPathSequence([document]),
      );
    });

    test('returns empty sequence for empty sequence', () {
      expect(fnRoot(context, [XPathSequence.empty]), isXPathSequence(isEmpty));
    });
  });

  group('fn:innermost', () {
    test('returns innermost nodes', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, [
          XPathSequence([document, a]),
        ]),
        isXPathSequence([a]),
      );
    });
  });

  group('fn:outermost', () {
    test('returns outermost nodes', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, [
          XPathSequence([document, a]),
        ]),
        isXPathSequence([document]),
      );
    });
  });

  group('fn:path', () {
    test('returns path of element', () {
      final a = document.findAllElements('a').first;
      expect(
        fnPath(context, [XPathSequence.single(a)]),
        isXPathSequence(['/r/a']),
      );
    });

    test('returns empty string for empty sequence', () {
      expect(fnPath(context, [XPathSequence.empty]), isXPathSequence(['']));
    });

    test('handles multiple elements with same name', () {
      final doc2 = XmlDocument.parse('<r><a>1</a><a>2</a></r>');
      final a2 = doc2.findAllElements('a').last;
      expect(
        fnPath(context, [XPathSequence.single(a2)]),
        isXPathSequence(['/r/a[2]']),
      );
    });

    test('handles attribute node', () {
      final doc3 = XmlDocument.parse('<r a="1"/>');
      final attr = doc3.rootElement.attributes.first;
      expect(
        fnPath(context, [XPathSequence.single(attr)]),
        isXPathSequence(['/r/@a']),
      );
    });
  });

  group('fn:generate-id', () {
    test('generates unique ids', () {
      final ids = document.descendants
          .map((node) => fnGenerateId(context, [XPathSequence.single(node)]))
          .map((sequence) => sequence.single)
          .toList();
      expect(ids, unorderedEquals(ids.toSet()));
    });

    test('returns empty string for empty sequence', () {
      expect(
        fnGenerateId(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:has-children', () {
    test('returns true if has children', () {
      final a = document.findAllElements('a').first; // has 1 text child
      expect(
        fnHasChildren(context, [XPathSequence.single(a)]),
        isXPathSequence([true]),
      );
    });

    test('returns false if empty element', () {
      final emptyEl = XmlElement(const XmlName('e'));
      expect(
        fnHasChildren(context, [XPathSequence.single(emptyEl)]),
        isXPathSequence([false]),
      );
    });

    test('returns false for empty sequence', () {
      expect(
        fnHasChildren(context, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:id', () {
    test('throws for invalid document', () {
      expect(
        () => fnId(context, [
          const XPathSequence.single('a'),
          XPathSequence.empty,
        ]),
        throwsA(isXPathEvaluationException(message: 'Invalid document')),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse(
        '<r><a id="1" xml:id="2"/><b id="3"/><c xml:id="5"/><d xml:id="4"/></r>',
      );
      final a = xml.findAllElements('a').single;
      final b = xml.findAllElements('b').single;
      final c = xml.findAllElements('c').single;
      final d = xml.findAllElements('d').single;

      expectEvaluate(xml, 'id("1")', isXPathSequence([a]));
      expectEvaluate(xml, 'id("2")', isXPathSequence([a]));
      expectEvaluate(xml, 'id("3")', isXPathSequence([b]));
      expectEvaluate(xml, 'id("4")', isXPathSequence([d]));
      expectEvaluate(xml, 'id("5")', isXPathSequence([c]));
      expectEvaluate(xml, 'id("1 3")', isXPathSequence([a, b]));
      expectEvaluate(xml, 'id(("1", "5"))', isXPathSequence([a, c]));
      expectEvaluate(xml, 'id("unknown")', isXPathSequence(<XmlNode>[]));
    });
  });

  group('fn:element-with-id', () {
    test('throws for invalid document', () {
      expect(
        () => fnElementWithId(context, [
          const XPathSequence.single('a'),
          XPathSequence.empty,
        ]),
        throwsA(isXPathEvaluationException(message: 'Invalid document')),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse(
        '<r><a id="1" xml:id="2"/><b id="3"/><c xml:id="5"/><d xml:id="4"/></r>',
      );
      final a = xml.findAllElements('a').single;
      final b = xml.findAllElements('b').single;
      final d = xml.findAllElements('d').single;

      expectEvaluate(xml, 'element-with-id("1")', isXPathSequence([a]));
      expectEvaluate(xml, 'element-with-id("2")', isXPathSequence([a]));
      expectEvaluate(xml, 'element-with-id("3")', isXPathSequence([b]));
      expectEvaluate(xml, 'element-with-id("4")', isXPathSequence([d]));
      expectEvaluate(xml, 'element-with-id("1 3")', isXPathSequence([a, b]));
      expectEvaluate(
        xml,
        'element-with-id(("1", "3"))',
        isXPathSequence([a, b]),
      );
    });
  });

  group('fn:idref', () {
    test('throws for invalid document', () {
      expect(
        () => fnIdref(context, [
          const XPathSequence.single('a'),
          XPathSequence.empty,
        ]),
        throwsA(isXPathEvaluationException(message: 'Invalid document')),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse(
        '<r><a idref="1" xml:idref="2"/><b idrefs="3"/><c idref="1 2"/><d xml:idrefs="4"/></r>',
      );

      final aIdref = xml.findAllElements('a').single.attributes[0];
      final aXmlidref = xml.findAllElements('a').single.attributes[1];
      final bIdrefs = xml.findAllElements('b').single.attributes[0];
      final cIdref = xml.findAllElements('c').single.attributes[0];
      final dXmlidrefs = xml.findAllElements('d').single.attributes[0];

      expectEvaluate(xml, 'idref("1")', isXPathSequence([aIdref, cIdref]));
      expectEvaluate(xml, 'idref("2")', isXPathSequence([aXmlidref, cIdref]));
      expectEvaluate(xml, 'idref("3")', isXPathSequence([bIdrefs]));
      expectEvaluate(xml, 'idref("4")', isXPathSequence([dXmlidrefs]));
      expectEvaluate(
        xml,
        'idref("1 3")',
        isXPathSequence([aIdref, bIdrefs, cIdref]),
      );
      expectEvaluate(
        xml,
        'idref(("1", "3"))',
        isXPathSequence([aIdref, bIdrefs, cIdref]),
      );
    });
  });

  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');

    test('last()', () {
      expectEvaluate(xml, 'last()', isXPathSequence([1]));
      expectEvaluate(
        xml,
        '/r/*[last()]',
        isXPathSequence([xml.rootElement.children.last]),
      );
    });

    test('position()', () {
      expectEvaluate(xml, 'position()', isXPathSequence([1]));
      expectEvaluate(
        xml,
        '/r/*[position()]',
        isXPathSequence(xml.rootElement.children),
      );
    });

    test('count()', () {
      expectEvaluate(xml, 'count(/*)', isXPathSequence([1]));
      expectEvaluate(xml, 'count(/r/*)', isXPathSequence([2]));
      expectEvaluate(xml, 'count(/r/b/*)', isXPathSequence([1]));
      expectEvaluate(xml, 'count(/r/b/absent)', isXPathSequence([0]));
    });

    test('predicate', () {
      final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
      final children = xml.rootElement.children;
      expectEvaluate(xml, '(/r/*)[1]', isXPathSequence([children[0]]));
      expectEvaluate(xml, '(/r/*)[last()]', isXPathSequence([children[2]]));
      expectEvaluate(xml, '(/r/*)[position()]', isXPathSequence(children));
      expectEvaluate(xml, '(/r/*)[false()]', isXPathSequence(isEmpty));
      expectEvaluate(xml, '(/r/*)[true()]', isXPathSequence(children));
      expectEvaluate(
        xml,
        '(/r/*)[position()<=2][last()]',
        isXPathSequence([children[1]]),
      );
      expectEvaluate(
        xml,
        '(/r/c/preceding-sibling::*)[last()]',
        isXPathSequence([children[1]]),
      );
    });
  });
}
