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
  group('fn:boolean', () {
    test('returns true for true', () {
      expect(
        fnBoolean(context, [const XPathSequence.single(true)]),
        XPathSequence.trueSequence,
      );
    });

    test('returns false for empty sequence', () {
      expect(
        fnBoolean(context, [XPathSequence.empty]),
        XPathSequence.falseSequence,
      );
    });

    test('returns true for number 1', () {
      expect(
        fnBoolean(context, [const XPathSequence.single(1)]),
        XPathSequence.trueSequence,
      );
    });

    test('evaluation with nodes', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'boolean(.)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(//a)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(//absent)', isXPathSequence([false]));
    });

    test('evaluation with string', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'boolean("")', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean("a")', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean("ab")', isXPathSequence([true]));
    });

    test('evaluation with number', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'boolean(0)', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean(1)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(-1)', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(0 div 0)', isXPathSequence([false]));
      expectEvaluate(xml, 'boolean(1 div 0)', isXPathSequence([true]));
    });

    test('evaluation with boolean', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'boolean(true())', isXPathSequence([true]));
      expectEvaluate(xml, 'boolean(false())', isXPathSequence([false]));
    });
  });

  group('fn:not', () {
    test('negates boolean value', () {
      expect(
        fnNot(context, [const XPathSequence.single(true)]),
        XPathSequence.falseSequence,
      );
    });

    test('evaluation', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'not(true())', isXPathSequence([false]));
      expectEvaluate(xml, 'not(false())', isXPathSequence([true]));
    });
  });

  group('fn:true', () {
    test('returns true', () {
      expect(fnTrue(context, []), isXPathSequence([true]));
    });

    test('evaluation', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'true()', isXPathSequence([true]));
    });
  });

  group('fn:false', () {
    test('returns false', () {
      expect(fnFalse(context, []), isXPathSequence([false]));
    });

    test('evaluation', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'false()', isXPathSequence([false]));
    });
  });

  group('fn:lang', () {
    test('matches language', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      final newContext = XPathContext.empty(c);
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
      expect(
        fnLang(newContext, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });

    test('evaluation', () {
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
