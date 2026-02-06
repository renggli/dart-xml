import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/boolean.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('boolean', () {
    test('fn:boolean', () {
      expect(
        fnBoolean(context, [const XPathSequence.single(true)]),
        XPathSequence.trueSequence,
      );
      expect(
        fnBoolean(context, [XPathSequence.empty]),
        XPathSequence.falseSequence,
      );
      expect(fnBoolean(context, [const XPathSequence.single(1)]), [true]);
    });
    test('fn:not', () {
      expect(
        fnNot(context, [const XPathSequence.single(true)]),
        XPathSequence.falseSequence,
      );
    });
    test('fn:true', () {
      expect(fnTrue(context, []), [true]);
    });
    test('fn:false', () {
      expect(fnFalse(context, []), [false]);
    });
    test('fn:lang', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      final newContext = XPathContext(c);
      // fn:lang is in node.dart
      expect(fnLang(newContext, [const XPathSequence.single('en')]), [true]);
      expect(fnLang(newContext, [const XPathSequence.single('fr')]), [false]);
      expect(fnLang(newContext, [const XPathSequence.single('EN-US')]), [
        false,
      ]);
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('boolean(nodes)', () {
      expectEvaluate(xml, 'boolean(.)', [true]);
      expectEvaluate(xml, 'boolean(//a)', [true]);
      expectEvaluate(xml, 'boolean(//absent)', [false]);
    });
    test('boolean(string)', () {
      expectEvaluate(xml, 'boolean("")', [false]);
      expectEvaluate(xml, 'boolean("a")', [true]);
      expectEvaluate(xml, 'boolean("ab")', [true]);
    });
    test('boolean(number)', () {
      expectEvaluate(xml, 'boolean(0)', [false]);
      expectEvaluate(xml, 'boolean(1)', [true]);
      expectEvaluate(xml, 'boolean(-1)', [true]);
      expectEvaluate(xml, 'boolean(0 div 0)', [false]);
      expectEvaluate(xml, 'boolean(1 div 0)', [true]);
    });
    test('boolean(boolean)', () {
      expectEvaluate(xml, 'boolean(true())', [true]);
      expectEvaluate(xml, 'boolean(false())', [false]);
    });
    test('not(boolean)', () {
      expectEvaluate(xml, 'not(true())', [false]);
      expectEvaluate(xml, 'not(false())', [true]);
    });
    test('true()', () {
      expectEvaluate(xml, 'true()', [true]);
    });
    test('false()', () {
      expectEvaluate(xml, 'false()', [false]);
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
        expectEvaluate(start, 'lang("en")', [true]);
      }
      final negatives = [
        '<para/>',
        '<para xml:lang=""/>',
        '<para xml:lang="de"/>',
      ];
      for (final positive in negatives) {
        final xml = XmlDocument.parse(positive);
        final start = xml.findAllElements('para').first;
        expectEvaluate(start, 'lang("en")', [false]);
      }
    });
  });
}
