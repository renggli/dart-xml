import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/boolean.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('boolean', () {
    test('op:boolean-equal', () {
      expect(
        opBooleanEqual(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opBooleanEqual(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
    });
    test('op:boolean-less-than', () {
      expect(
        opBooleanLessThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opBooleanLessThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
    test('op:boolean-greater-than', () {
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [true],
      );
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
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
      expect(fnTrue(context, const <XPathSequence>[]), [true]);
    });
    test('fn:false', () {
      expect(fnFalse(context, const <XPathSequence>[]), [false]);
    });
    test('fn:lang', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      final newContext = XPathContext(c);
      expect(fnLang(newContext, [const XPathSequence.single('en')]), [true]);
      expect(fnLang(newContext, [const XPathSequence.single('fr')]), [false]);
      expect(fnLang(newContext, [const XPathSequence.single('EN-US')]), [
        false,
      ]);
    });
  });
}
