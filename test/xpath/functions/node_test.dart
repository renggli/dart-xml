import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/node.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('node', () {
    test('op:union', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opUnion(context, [XPathSequence.single(a), XPathSequence.single(b)]),
        XPathSequence([a, b]),
      );
      // Test document order preservation/enforcement
      expect(
        opUnion(context, [XPathSequence.single(b), XPathSequence.single(a)]),
        [a, b],
      );
    });
    test('op:intersect', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opIntersect(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [a],
      );
    });
    test('op:except', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opExcept(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [b],
      );
    });
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(fnName(context, [XPathSequence.single(a)]), [
        const v31.XPathString('a'),
      ]);
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(fnLocalName(context, [XPathSequence.single(a)]), [
        const v31.XPathString('a'),
      ]);
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(fnRoot(context, [XPathSequence.single(a)]), [document]);
    });
    test('fn:innermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, [
          XPathSequence([document, a]),
        ]),
        [a],
      );
    });
    test('fn:outermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, [
          XPathSequence([document, a]),
        ]),
        [document],
      );
    });
    test('fn:path', () {
      final a = document.findAllElements('a').first;
      expect(fnPath(context, [XPathSequence.single(a)]), [
        const v31.XPathString('/r/a'),
      ]);
    });
  });
}
