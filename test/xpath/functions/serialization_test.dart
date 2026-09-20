import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/serialization.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:serialize', () {
    test('serializes sequence', () {
      expect(
        fnSerialize(context, [
          seq([
            document.findAllElements('a').first,
            'text',
            document.findAllElements('b').first,
          ]),
        ]),
        isXPathSequence(['<a>1</a>text<b>2</b>']),
      );
    });

    test('returns empty string for empty sequence in XML method', () {
      expect(
        fnSerialize(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });

    test('serializes with omit-xml-declaration = false', () {
      final params = XPathMap({
        const XPathString('omit-xml-declaration'): const XPathSequence.single(
          XPathBoolean.falseInstance,
        ),
        const XPathString('standalone'): const XPathSequence.single(
          XPathBoolean.trueInstance,
        ),
      });
      final res = fnSerialize(context, [
        seq(document.findAllElements('a').first),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, contains('<?xml'));
      expect(res, contains('standalone="yes"'));
      expect(res, contains('<a>1</a>'));
    });

    test('serializes with cdata-section-elements', () {
      final doc = XmlDocument.parse('<doc><b>bold</b><i>italic</i></doc>');
      final params = XPathMap({
        const XPathString('cdata-section-elements'): const XPathSequence.single(
          XPathQName(XmlName.qualified('b')),
        ),
      });
      final res = fnSerialize(context, [
        seq(doc),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, contains('<![CDATA[bold]]>'));
      expect(res, contains('italic'));
      expect(res, isNot(contains('<![CDATA[italic]]>')));
    });

    test('serializes with use-character-maps', () {
      final charMap = XPathMap({
        const XPathString(r'$'): const XPathSequence.single(XPathString('£')),
      });
      final params = XPathMap({
        const XPathString('use-character-maps'): XPathSequence.single(charMap),
      });
      final res = fnSerialize(context, [
        seq(r'Price is $100'),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, 'Price is £100');
    });

    test('serializes with item-separator', () {
      final params = XPathMap({
        const XPathString('item-separator'): const XPathSequence.single(
          XPathString('|'),
        ),
      });
      final res = fnSerialize(context, [
        seq([1, 2, 3]),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, '1|2|3');
    });

    test('serializes text method', () {
      final params = XPathMap({
        const XPathString('method'): const XPathSequence.single(
          XPathString('text'),
        ),
        const XPathString('item-separator'): const XPathSequence.single(
          XPathString(','),
        ),
      });
      final res = fnSerialize(context, [
        seq([
          document.findAllElements('a').first,
          document.findAllElements('b').first,
        ]),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, '1,2');
    });

    test('serializes html method', () {
      final params = XPathMap({
        const XPathString('method'): const XPathSequence.single(
          XPathString('html'),
        ),
      });
      final res = fnSerialize(context, [
        seq(XmlDocument.parse('<html><body><p>Hi</p></body></html>')),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, contains('<!DOCTYPE html>'));
      expect(res, contains('<p>Hi</p>'));
    });

    test('serializes json method', () {
      final params = XPathMap({
        const XPathString('method'): const XPathSequence.single(
          XPathString('json'),
        ),
      });
      expect(
        fnSerialize(context, [
          XPathSequence.empty,
          XPathSequence.single(params),
        ]).first.stringValue,
        'null',
      );

      final mapItem = XPathMap({
        const XPathString('name'): const XPathSequence.single(
          XPathString('Antigravity'),
        ),
        const XPathString('count'): XPathSequence.single(
          XPathInteger.fromInt(42),
        ),
        const XPathString('active'): const XPathSequence.single(
          XPathBoolean.trueInstance,
        ),
      });
      final jsonRes = fnSerialize(context, [
        XPathSequence.single(mapItem),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(jsonRes, contains('"name":"Antigravity"'));
      expect(jsonRes, contains('"count":42'));
      expect(jsonRes, contains('"active":true'));

      final arrayItem = XPathArray([
        XPathSequence.single(XPathInteger.fromInt(1)),
        const XPathSequence.single(XPathString('two')),
        const XPathSequence.single(XPathBoolean.falseInstance),
      ]);
      expect(
        fnSerialize(context, [
          XPathSequence.single(arrayItem),
          XPathSequence.single(params),
        ]).first.stringValue,
        '[1,"two",false]',
      );

      // Node in JSON method
      final commentItem = XPathNode(XmlComment(' hello '));
      expect(
        fnSerialize(context, [
          XPathSequence.single(commentItem),
          XPathSequence.single(params),
        ]).first.stringValue,
        '"<!-- hello -->"',
      );
    });

    test('serializes adaptive method', () {
      final params = XPathMap({
        const XPathString('method'): const XPathSequence.single(
          XPathString('adaptive'),
        ),
        const XPathString('item-separator'): const XPathSequence.single(
          XPathString(';'),
        ),
      });
      final mapItem = XPathMap({
        const XPathString('a'): XPathSequence.single(XPathInteger.fromInt(1)),
      });
      final res = fnSerialize(context, [
        seq([1, 'foo', mapItem]),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, '1;foo;map{a:1}');
    });

    test('throws on free-standing attribute in XML method', () {
      final attr = XmlAttribute(const XmlName('foo'), 'bar');
      expect(
        () => fnSerialize(context, [seq(attr)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test(
      'ignores disallowed no-namespace QName parameter per option conventions',
      () {
        final params = XPathMap({
          const XPathQName(XmlName('indent')): const XPathSequence.single(
            XPathBoolean.trueInstance,
          ),
        });
        final res = fnSerialize(context, [
          seq('test'),
          XPathSequence.single(params),
        ]).first.stringValue;
        expect(res, 'test');
      },
    );

    test('parses serialization parameters from XML element', () {
      final paramDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:method value="text"/>
          <output:indent value="yes"/>
        </output:serialization-parameters>
      ''');
      final res = fnSerialize(context, [
        seq(document.findAllElements('a').first),
        seq(paramDoc.rootElement),
      ]).first.stringValue;
      expect(res, '1');
    });

    test('throws on duplicate parameter element', () {
      final paramDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:indent value="yes"/>
          <output:indent value="no"/>
        </output:serialization-parameters>
      ''');
      expect(
        () => fnSerialize(context, [seq('test'), seq(paramDoc.rootElement)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
