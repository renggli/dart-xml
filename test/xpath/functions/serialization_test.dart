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

    test(
      'parses use-character-maps and suppress-indentation from XML element',
      () {
        final paramDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
             xmlns:ext="http://example.com/extension">
          <output:method value="xml"/>
          <output:indent value="yes"/>
          <output:omit-xml-declaration value="yes"/>
          <output:standalone value="no"/>
          <output:undeclare-prefixes value="no"/>
          <output:suppress-indentation value="a b"/>
          <output:use-character-maps>
            <output:character-map character="&amp;" map-string="[AND]"/>
          </output:use-character-maps>
          <ext:custom-option value="ignored"/>
        </output:serialization-parameters>
      ''');
        final xmlDoc = XmlDocument.parse('<r><a>Tom &amp; Jerry</a></r>');
        final res = fnSerialize(context, [
          seq(xmlDoc),
          seq(paramDoc.rootElement),
        ]).first.stringValue;
        expect(res, contains('[AND]'));
      },
    );

    test(
      'XML element serialization parameter errors SEPM0017 and SEPM0018',
      () {
        void expectParamError(String xml, XPathErrorCode code) {
          final doc = XmlDocument.parse(xml);
          expect(
            () => fnSerialize(context, [seq('test'), seq(doc.rootElement)]),
            throwsA(isXPathEvaluationException(errorCode: code)),
          );
        }

        // Disallowed element outside output namespace with no prefix
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<invalid-elem value="1"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Missing value attribute
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:method/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Invalid boolean value for indent
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:indent value="maybe"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Invalid boolean value for omit-xml-declaration
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:omit-xml-declaration value="true"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Invalid standalone value
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:standalone value="always"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Invalid undeclare-prefixes value
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:undeclare-prefixes value="invalid"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Unrecognized output parameter
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:unknown-param value="xyz"/>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Invalid attribute on character-map
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:use-character-maps>'
          '  <output:character-map character="a" map-string="b" invalid="bad"/>'
          '</output:use-character-maps>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Multi-character rune on character-map
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:use-character-maps>'
          '  <output:character-map character="abc" map-string="def"/>'
          '</output:use-character-maps>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0017,
        );

        // Duplicate character in character-map throws SEPM0018
        expectParamError(
          '<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">'
          '<output:use-character-maps>'
          '  <output:character-map character="a" map-string="1"/>'
          '  <output:character-map character="a" map-string="2"/>'
          '</output:use-character-maps>'
          '</output:serialization-parameters>',
          XPathErrorCode.SEPM0018,
        );
      },
    );

    test('options parsing from sequence with type checking', () {
      // Untyped atomic boolean coercion
      final mapWithUntyped = XPathMap({
        const XPathString('indent'): seq(const XPathUntypedAtomic('yes')),
        const XPathString('omit-xml-declaration'): seq(
          const XPathUntypedAtomic('0'),
        ),
      });
      final res = fnSerialize(context, [
        seq(XmlDocument.parse('<r><a/></r>')),
        XPathSequence.single(mapWithUntyped),
      ]).first.stringValue;
      expect(res, contains('<?xml'));

      // Invalid boolean type throws XPTY0004
      expect(
        () => fnSerialize(context, [
          seq('test'),
          XPathSequence.single(
            XPathMap({const XPathString('indent'): seq(123)}),
          ),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // Invalid string type throws XPTY0004
      expect(
        () => fnSerialize(context, [
          seq('test'),
          XPathSequence.single(
            XPathMap({const XPathString('method'): seq(false)}),
          ),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('HTML serialization void tags and head handling', () {
      final htmlDoc = XmlDocument.parse('''
        <html>
          <head></head>
          <body>
            <br/>
            <hr/>
            <img src="pic.jpg"/>
          </body>
        </html>
      ''');
      final params = XPathMap({
        const XPathString('method'): const XPathSequence.single(
          XPathString('html'),
        ),
      });
      final res = fnSerialize(context, [
        seq(htmlDoc),
        XPathSequence.single(params),
      ]).first.stringValue;
      expect(res, contains('<br/>'));
      expect(res, contains('<hr/>'));
      expect(res, contains('<meta http-equiv="Content-Type"'));
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
