import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/boolean.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  test('fn:boolean', () {
    expect(
      fnBoolean(context, [const XPathSequence.single(true)]),
      XPathSequence.trueSequence,
    );
    expect(
      fnBoolean(context, [XPathSequence.empty]),
      XPathSequence.falseSequence,
    );
    expect(
      fnBoolean(context, [const XPathSequence.single(1)]),
      XPathSequence.trueSequence,
    );
  });
  test('fn:not', () {
    expect(
      fnNot(context, [const XPathSequence.single(true)]),
      XPathSequence.falseSequence,
    );
  });
  test('fn:true', () {
    expect(fnTrue(context, []), isXPathSequence([true]));
  });
  test('fn:false', () {
    expect(fnFalse(context, []), isXPathSequence([false]));
  });
  test('fn:lang', () {
    final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
    final c = doc.rootElement.children.whereType<XmlElement>().first;
    final newContext = XPathContext.empty(c);
    // fn:lang is in node.dart
    expect(
      fnLang(newContext, [const XPathSequence.single('en')]),
      isXPathSequence([true]),
    );
    expect(
      fnLang(newContext, [const XPathSequence.single('fr')]),
      isXPathSequence([false]),
    );
    expect(
      fnLang(newContext, [const XPathSequence.single('EN-US')]),
      isXPathSequence([false]),
    );
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('boolean(nodes)', () {
      expectEvaluate(xml, 'boolean(.)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(//a)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(//absent)', isXPathSequence([false]));
    });
    test('boolean(string)', () {
      expectEvaluate(xml, 'boolean("")', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean("a")', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean("ab")', isXPathSequence([true]));
    });
    test('boolean(number)', () {
      expectEvaluate(xml, 'boolean(0)', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean(1)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(-1)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(0 div 0)', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean(1 div 0)', isXPathSequence([true]));
    });
    test('boolean(boolean)', () {
      expectEvaluate(xml, 'boolean(true())', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(false())', isXPathSequence([false]));
    });
    test('not(boolean)', () {
      expectEvaluate(xml, 'not(true())', isXPathSequence([false]));
      expectEvaluate(xml, 'not(false())', isXPathSequence([true]));
    });
    test('true()', () {
      expectEvaluate(xml, 'true()', isXPathSequence([true]));
    });
    test('false()', () {
      expectEvaluate(xml, 'false()', isXPathSequence([false]));
    });
    test('lang(string)', () {
      final positives = [
        '<para xml:lang="en"/>',
        '<div xml:lang="en"><para/></div>',
        '<para xml:lang="EN"/>',
        '<para xml:lang="en-us"/>',
      ];
      for (final positive in positives) {
        final xml = XmlDocument.parse(positive);
        final start = xml.findAllElements('para').first;
        expectEvaluate(start, 'lang("en")', isXPathSequence([true]));
      }
      final negatives = [
        '<para/>',
        '<para xml:lang=""/>',
        '<para xml:lang="de"/>',
      ];
      for (final positive in negatives) {
        final xml = XmlDocument.parse(positive);
        final start = xml.findAllElements('para').first;
        expectEvaluate(start, 'lang("en")', isXPathSequence([false]));
      }
    });
  });
}
