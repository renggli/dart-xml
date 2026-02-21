import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/node.dart';

import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:name', () {
    final a = document.findAllElements('a').first;
    expect(fnName(context, [XPathSequence.single(a)]), isXPathSequence(['a']));
  });
  test('fn:local-name', () {
    final a = document.findAllElements('a').first;
    expect(
      fnLocalName(context, [XPathSequence.single(a)]),
      isXPathSequence(['a']),
    );
  });
  test('fn:root', () {
    final a = document.findAllElements('a').first;
    expect(
      fnRoot(context, [XPathSequence.single(a)]),
      isXPathSequence([document]),
    );
  });
  test('fn:innermost', () {
    final a = document.findAllElements('a').first;
    expect(
      fnInnermost(context, [
        XPathSequence([document, a]),
      ]),
      isXPathSequence([a]),
    );
  });
  test('fn:outermost', () {
    final a = document.findAllElements('a').first;
    expect(
      fnOutermost(context, [
        XPathSequence([document, a]),
      ]),
      isXPathSequence([document]),
    );
  });
  test('fn:path', () {
    final a = document.findAllElements('a').first;
    expect(
      fnPath(context, [XPathSequence.single(a)]),
      isXPathSequence(['/r/a']),
    );
  });
  test('fn:generate-id', () {
    final ids = document.descendants
        .map((node) => fnGenerateId(context, [XPathSequence.single(node)]))
        .map((sequence) => sequence.single)
        .toList();
    expect(ids, unorderedEquals(ids.toSet()));
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
    test('count(node-set)', () {
      expectEvaluate(xml, 'count(/*)', isXPathSequence([1]));
      expectEvaluate(xml, 'count(/r/*)', isXPathSequence([2]));
      expectEvaluate(xml, 'count(/r/b/*)', isXPathSequence([1]));
      expectEvaluate(xml, 'count(/r/b/absent)', isXPathSequence([0]));
    });
    test('local-name(node-set?)', () {
      expectEvaluate(xml, 'local-name(/r/a)', isXPathSequence(['a']));
      expectEvaluate(
        xml,
        '/r/*[local-name()="a"]',
        isXPathSequence(xml.findAllElements('a')),
      );
    });
    test('namespace-uri(node-set?)', () {
      expectEvaluate(xml, 'namespace-uri(/r/a)', isXPathSequence(['']));
      expectEvaluate(
        xml,
        '/r/*[namespace-uri()=""]',
        isXPathSequence(xml.rootElement.findElements('*')),
      );
    });
    test('name(node-set?)', () {
      expectEvaluate(xml, 'name(/r/a)', isXPathSequence(['a']));
      expectEvaluate(
        xml,
        '/r/*[name()="a"]',
        isXPathSequence(xml.findAllElements('a')),
      );
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

    test('fn:id', () {
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

    test('fn:element-with-id', () {
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

    test('fn:idref', () {
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
}
