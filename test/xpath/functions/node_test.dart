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
  });
}
