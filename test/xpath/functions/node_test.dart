import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/node.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:name', () {
    test('returns name of element', () {
      final a = document.findAllElements('a').first;
      check(fnName(context, [seq(a)])).isXPathSequence(['a']);
    });

    test('returns target of processing instruction', () {
      final pi = XmlProcessing('target', 'data');
      check(fnName(context, [seq(pi)])).isXPathSequence(['target']);
    });

    test('returns name of attribute with prefix', () {
      final attr = XmlAttribute(const XmlName('lang', 'xml'), 'en');
      check(fnName(context, [seq(attr)])).isXPathSequence(['xml:lang']);
    });

    test('returns name of attribute without prefix', () {
      final attr = XmlAttribute(const XmlName('id'), '1');
      check(fnName(context, [seq(attr)])).isXPathSequence(['id']);
    });

    test('throws XPDY0002 on absent context item', () {
      final emptyCtx = context.copy(item: XPathSequence.empty);
      check(() => fnName(emptyCtx, []))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPDY0002),
          );
    });

    test('throws XPTY0004 on non-node context item', () {
      final nonNodeCtx = context.copy(item: XPathInteger.fromInt(42));
      check(() => fnName(nonNodeCtx, []))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('returns empty string for document', () {
      check(fnName(context, [seq(document)])).isXPathSequence(['']);
    });

    test('returns empty string for empty sequence', () {
      check(fnName(context, [XPathSequence.empty])).isXPathSequence(['']);
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
      check(fnLocalName(context, [seq(a)])).isXPathSequence(['a']);
    });

    test('returns target of processing instruction', () {
      final pi = XmlProcessing('target', 'data');
      check(fnLocalName(context, [seq(pi)])).isXPathSequence(['target']);
    });

    test('returns local name of attribute', () {
      final attr = XmlAttribute(const XmlName('a'), '1');
      check(fnLocalName(context, [seq(attr)])).isXPathSequence(['a']);
    });

    test('returns empty string for empty sequence', () {
      check(fnLocalName(context, [XPathSequence.empty])).isXPathSequence(['']);
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
      check(fnNamespaceUri(context, [seq(a)])).isXPathSequence(['']);
    });

    test('returns namespace uri of attribute', () {
      final attr = XmlAttribute(const XmlName('a'), '1');
      check(fnNamespaceUri(context, [seq(attr)])).isXPathSequence(['']);
    });

    test('returns empty string for empty sequence', () {
      check(fnNamespaceUri(context, [XPathSequence.empty]))
          .isXPathSequence(['']);
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
      check(fnRoot(context, [seq(a)])).isXPathSequence([document]);
    });

    test('returns empty sequence for empty sequence', () {
      check(fnRoot(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });
  });

  group('fn:innermost', () {
    test('returns innermost nodes', () {
      final a = document.findAllElements('a').first;
      check(
        fnInnermost(context, [
          seq([document, a]),
        ]),
      ).isXPathSequence([a]);
    });
  });

  group('fn:outermost', () {
    test('returns outermost nodes', () {
      final a = document.findAllElements('a').first;
      check(
        fnOutermost(context, [
          seq([document, a]),
        ]),
      ).isXPathSequence([document]);
    });
  });

  group('fn:path', () {
    test('returns path of element', () {
      final a = document.findAllElements('a').first;
      check(fnPath(context, [seq(a)])).isXPathSequence(['/Q{}r[1]/Q{}a[1]']);
    });

    test('returns / for document', () {
      check(fnPath(context, [seq(document)])).isXPathSequence(['/']);
    });

    test('returns empty sequence for empty sequence', () {
      check(fnPath(context, [XPathSequence.empty])).isXPathSequence(isEmpty);
    });

    test('handles multiple elements with same name', () {
      final doc2 = XmlDocument.parse('<r><a>1</a><a>2</a></r>');
      final a2 = doc2.findAllElements('a').last;
      check(fnPath(context, [seq(a2)])).isXPathSequence(['/Q{}r[1]/Q{}a[2]']);
    });

    test('handles attribute node', () {
      final doc3 = XmlDocument.parse('<r a="1"/>');
      final attr = doc3.rootElement.attributes.first;
      check(fnPath(context, [seq(attr)])).isXPathSequence(['/Q{}r[1]/@a']);
    });
  });

  group('fn:generate-id', () {
    test('generates unique ids', () {
      final ids = document.descendants
          .map((node) => fnGenerateId(context, [seq(node)]))
          .map((sequence) => sequence.single)
          .toList();
      check(ids).unorderedEquals(ids.toSet());
    });

    test('returns empty string for empty sequence', () {
      check(fnGenerateId(context, [XPathSequence.empty])).isXPathSequence(['']);
    });
  });

  group('fn:has-children', () {
    test('returns true if has children', () {
      final a = document.findAllElements('a').first; // has 1 text child
      check(fnHasChildren(context, [seq(a)])).isXPathSequence([true]);
    });

    test('returns false if empty element', () {
      final emptyEl = XmlElement(const XmlName('e'));
      check(fnHasChildren(context, [seq(emptyEl)])).isXPathSequence([false]);
    });

    test('returns false for empty sequence', () {
      check(fnHasChildren(context, [XPathSequence.empty]))
          .isXPathSequence([false]);
    });
  });

  group('fn:id', () {
    test('throws for empty sequence node argument', () {
      check(() => fnId(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('integration via xpathEvaluate with DTD', () {
      final xml = XmlDocument.parse('''
<!DOCTYPE IDS [
<!ELEMENT IDS (a, b)>
<!ATTLIST a anId ID #REQUIRED>
]>
<IDS><a anId="id1"/><b anId="id2"/></IDS>
''');
      final a = xml.findAllElements('a').single;
      expectEvaluate(xml, 'id("id1")', isXPathSequence([a]));
      expectEvaluate(xml, 'id("id2")', isXPathSequence(isEmpty));
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
    test('throws for empty sequence node argument', () {
      check(() => fnElementWithId(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('throws for non-node sequence node argument', () {
      check(() => fnElementWithId(context, [seq('a'), seq(123)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.XPTY0004,
              message: 'Expected a node for the argument of fn:element-with-id, got xs:integer',
            ),
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
    test('throws for empty sequence node argument', () {
      check(() => fnIdref(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('integration via xpathEvaluate with DTD', () {
      final xml = XmlDocument.parse('''
<!DOCTYPE IDS [
<!ELEMENT IDS (a)>
<!ATTLIST a anIdRef IDREF #REQUIRED>
]>
<IDS><a anIdRef="id1"/></IDS>
''');
      final a = xml.findAllElements('a').single;
      expectEvaluate(
        xml,
        'idref("id1")',
        isXPathSequence([a.attributes.first]),
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

  group('fn:innermost', () {
    final xml = XmlDocument.parse('<r><a><b/></a><c/></r>');

    test('retains only deepest nodes', () {
      expectEvaluate(
        xml,
        'fn:innermost(//*)',
        isXPathSequence([
          xml.findAllElements('b').single,
          xml.findAllElements('c').single,
        ]),
      );
    });

    test('empty sequence returns empty', () {
      expectEvaluate(xml, 'fn:innermost(())', isXPathSequence(isEmpty));
    });

    test('throws XPTY0004 on non-node item', () {
      check(() => xml.xpathEvaluate('fn:innermost((//*, 1))'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });

  group('fn:outermost', () {
    final xml = XmlDocument.parse('<r><a><b/></a><c/></r>');

    test('retains only shallowest nodes', () {
      expectEvaluate(
        xml,
        'fn:outermost(//*)',
        isXPathSequence([xml.rootElement]),
      );
      expectEvaluate(
        xml,
        'fn:outermost((//a, //b, //c))',
        isXPathSequence([
          xml.findAllElements('a').single,
          xml.findAllElements('c').single,
        ]),
      );
    });

    test('empty sequence returns empty', () {
      expectEvaluate(xml, 'fn:outermost(())', isXPathSequence(isEmpty));
    });

    test('throws XPTY0004 on non-node item', () {
      check(() => xml.xpathEvaluate('fn:outermost((//*, "string"))'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });

  group('fn:path', () {
    final xml = XmlDocument.parse(
      '<r xmlns="http://ns.com" a="1"><!--c--><?pi data?>text</r>',
    );

    test('document returns /', () {
      expectEvaluate(xml, 'fn:path(/)', isXPathSequence(['/']));
    });

    test('context item default', () {
      expectEvaluate(xml, 'fn:path()', isXPathSequence(['/']));
    });

    test('element path includes namespace and index', () {
      expectEvaluate(
        xml,
        'fn:path(/*)',
        isXPathSequence(['/Q{http://ns.com}r[1]']),
      );
    });

    test('attribute path', () {
      expectEvaluate(
        xml,
        'fn:path(/*/@a)',
        isXPathSequence(['/Q{http://ns.com}r[1]/@a']),
      );
    });

    test('comment path', () {
      expectEvaluate(
        xml,
        'fn:path(/*/comment())',
        isXPathSequence(['/Q{http://ns.com}r[1]/comment()[1]']),
      );
    });

    test('processing-instruction path', () {
      expectEvaluate(
        xml,
        'fn:path(/*/processing-instruction())',
        isXPathSequence([
          '/Q{http://ns.com}r[1]/processing-instruction(pi)[1]',
        ]),
      );
    });

    test('text path', () {
      expectEvaluate(
        xml,
        'fn:path(/*/text())',
        isXPathSequence(['/Q{http://ns.com}r[1]/text()[1]']),
      );
    });

    test('unnamed namespace path uses double quotes', () {
      expectEvaluate(
        xml,
        'fn:path(/*/namespace::*[local-name()=""])',
        isXPathSequence([
          '/Q{http://ns.com}r[1]/namespace::*[Q{http://www.w3.org/2005/xpath-functions}local-name()=""]',
        ]),
      );
    });

    test('named namespace path uses prefix', () {
      expectEvaluate(
        xml,
        'fn:path(/*/namespace::*[local-name()="xml"])',
        isXPathSequence(['/Q{http://ns.com}r[1]/namespace::xml']),
      );
    });

    test('attribute with namespace URI', () {
      final docWithNs = XmlDocument.parse(
        '<r xmlns:p="http://example.com" p:attr="1"/>',
      );
      check(docWithNs.xpathEvaluate('fn:path(/*/@*:attr)'))
          .isXPathSequence(['/Q{}r[1]/@Q{http://example.com}attr']);
    });

    test(
      'indexed siblings for text, comments, and processing instructions',
      () {
        final complexDoc = XmlDocument.parse(
          '<r>first<mid/><!--c1--><child/><!--c2--><?pi a?><sub/><?pi b?>last</r>',
        );
        check(complexDoc.xpathEvaluate('fn:path(/r/text()[2])'))
            .isXPathSequence(['/Q{}r[1]/text()[2]']);
        check(complexDoc.xpathEvaluate('fn:path(/r/comment()[2])'))
            .isXPathSequence(['/Q{}r[1]/comment()[2]']);
        check(
          complexDoc.xpathEvaluate('fn:path(/r/processing-instruction(pi)[2])'),
        ).isXPathSequence(['/Q{}r[1]/processing-instruction(pi)[2]']);
      },
    );

    test('empty sequence returns empty', () {
      expectEvaluate(xml, 'fn:path(())', isXPathSequence(isEmpty));
    });

    test('throws XPTY0004 on non-node item', () {
      check(() => xml.xpathEvaluate('fn:path(123)'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });

  group('fn:root', () {
    final xml = XmlDocument.parse('<r><a/></r>');

    test('returns document root', () {
      expectEvaluate(xml, 'fn:root(/*/a)', isXPathSequence([xml]));
    });

    test('zero-argument uses context node', () {
      expectEvaluate(xml, 'fn:root()', isXPathSequence([xml]));
    });

    test('isolated element returns itself', () {
      final elem = XmlElement(const XmlName('isolated'));
      check(elem.xpathEvaluate('fn:root()')).isXPathSequence([elem]);
    });

    test('empty sequence returns empty', () {
      expectEvaluate(xml, 'fn:root(())', isXPathSequence(isEmpty));
    });

    test('throws XPTY0004 on non-node item', () {
      check(() => xml.xpathEvaluate('fn:root("not-a-node")'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });

  group('fn:generate-id', () {
    final xml = XmlDocument.parse('<r><a/><b/></r>');

    test('generates unique identifier for nodes', () {
      final a = xml.findAllElements('a').first;
      final b = xml.findAllElements('b').first;
      final idA = fnGenerateId(context, [seq(a)]).first.stringValue;
      final idB = fnGenerateId(context, [seq(b)]).first.stringValue;
      check(idA).startsWith('autoId');
      check(idB).startsWith('autoId');
      check(idA).not((it) => it.equals(idB));
    });

    test('0-argument uses context node', () {
      final elem = xml.findAllElements('a').first;
      final elemCtx = const XPathConfiguration.raw().context(elem);
      check(fnGenerateId(elemCtx, []).first.stringValue).startsWith('autoId');
    });

    test('empty sequence returns empty string', () {
      check(fnGenerateId(context, [XPathSequence.empty])).isXPathSequence(['']);
    });
  });

  group('fn:has-children', () {
    final xml = XmlDocument.parse('<r><a/><b/></r>');

    test('detects child presence', () {
      expectEvaluate(xml, 'fn:has-children(/r)', isXPathSequence([true]));
      expectEvaluate(xml, 'fn:has-children(/r/a)', isXPathSequence([false]));
    });

    test('0-argument uses context node', () {
      expectEvaluate(xml, 'fn:has-children()', isXPathSequence([true]));
    });

    test('empty sequence returns false', () {
      expectEvaluate(xml, 'fn:has-children(())', isXPathSequence([false]));
    });
  });
}
