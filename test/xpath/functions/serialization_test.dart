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

    test('fromSequence edge cases', () {
      final defaultParams = SerializationParameters.fromSequence(
        XPathSequence.empty,
      );
      expect(defaultParams.method, 'xml');

      expect(
        () => SerializationParameters.fromSequence(seq(123)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('fromMap parameter validation', () {
      // Invalid key type
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathDouble(123): seq('val')}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // Unknown method
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('method'): seq('unknown-method')}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0016)),
      );

      // Standalone variations
      final pEmpty = SerializationParameters.fromMap(
        XPathMap({const XPathString('standalone'): XPathSequence.empty}),
      );
      expect(pEmpty.standalone, isNull);

      final pYes = SerializationParameters.fromMap(
        XPathMap({const XPathString('standalone'): seq('yes')}),
      );
      expect(pYes.standalone, isTrue);

      final pNo = SerializationParameters.fromMap(
        XPathMap({const XPathString('standalone'): seq('no')}),
      );
      expect(pNo.standalone, isFalse);

      final pOmit = SerializationParameters.fromMap(
        XPathMap({const XPathString('standalone'): seq('omit')}),
      );
      expect(pOmit.standalone, isNull);

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('standalone'): seq('maybe')}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('standalone'): seq(['yes', 'no']),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // string and number options
      final pOpts = SerializationParameters.fromMap(
        XPathMap({
          const XPathString('version'): seq('1.1'),
          const XPathString('html-version'): seq(5.0),
          const XPathString('encoding'): seq('iso-8859-1'),
          const XPathString('json-node-output-method'): seq('xml'),
          const XPathString('allow-duplicate-names'): seq(true),
          const XPathString('undeclare-prefixes'): seq(true),
        }),
      );
      expect(pOpts.version, '1.1');
      expect(pOpts.htmlVersion, 5.0);
      expect(pOpts.encoding, 'iso-8859-1');
      expect(pOpts.jsonNodeOutputMethod, 'xml');
      expect(pOpts.allowDuplicateNames, isTrue);
      expect(pOpts.undeclarePrefixes, isTrue);

      // cdata-section-elements with XPathArray, string, and invalid items
      final pCdata = SerializationParameters.fromMap(
        XPathMap({
          const XPathString('cdata-section-elements'): XPathSequence.single(
            XPathArray([seq('elem1'), seq('elem2')]),
          ),
        }),
      );
      expect(pCdata.cdataSectionElements.length, 2);

      final pCdataAtomic = SerializationParameters.fromMap(
        XPathMap({
          const XPathString('cdata-section-elements'): seq([
            const XPathUntypedAtomic('elem1'),
          ]),
        }),
      );
      expect(pCdataAtomic.cdataSectionElements.length, 1);

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('cdata-section-elements'): seq(123)}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // suppress-indentation with XPathArray, QName, string, untyped, and invalid items
      final pSuppress = SerializationParameters.fromMap(
        XPathMap({
          const XPathString('suppress-indentation'): XPathSequence.single(
            XPathArray([
              seq(const XPathQName(XmlName.qualified('q1'))),
              seq('str1'),
              seq(const XPathUntypedAtomic('untyped1')),
            ]),
          ),
        }),
      );
      expect(pSuppress.suppressIndentation.length, 3);

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('suppress-indentation'): seq(123)}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // use-character-maps error handling
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('use-character-maps'): seq('not-a-map')}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('use-character-maps'): XPathSequence.single(
              XPathMap({const XPathDouble(123): seq('val')}),
            ),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('use-character-maps'): XPathSequence.single(
              XPathMap({const XPathString('two-chars'): seq('val')}),
            ),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0016)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('use-character-maps'): XPathSequence.single(
              XPathMap({
                const XPathString('a'): seq(['val1', 'val2']),
              }),
            ),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('use-character-maps'): XPathSequence.single(
              XPathMap({const XPathString('a'): seq(123)}),
            ),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // json method with item-separator throws SERE0023
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('method'): seq('json'),
            const XPathString('item-separator'): seq(','),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0023)),
      );
    });

    test('fromElement error and feature handling', () {
      // Outermost element wrong name or namespace
      final wrongDoc1 = XmlDocument.parse('<wrong-name/>');
      expect(
        () => SerializationParameters.fromElement(wrongDoc1.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // Non-xmlns attribute on serialization-parameters
      final invalidAttrDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
             invalid="true"/>
      ''');
      expect(
        () => SerializationParameters.fromElement(invalidAttrDoc.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0017)),
      );

      // use-character-maps non-xmlns attribute
      final cmAttrDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:use-character-maps foo="bar"/>
        </output:serialization-parameters>
      ''');
      expect(
        () => SerializationParameters.fromElement(cmAttrDoc.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0017)),
      );

      // use-character-maps invalid child
      final cmInvalidChildDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:use-character-maps>
            <output:not-character-map/>
          </output:use-character-maps>
        </output:serialization-parameters>
      ''');
      expect(
        () =>
            SerializationParameters.fromElement(cmInvalidChildDoc.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0017)),
      );

      // character-map missing character or map-string
      final cmMissingAttrDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:use-character-maps>
            <output:character-map character="a"/>
          </output:use-character-maps>
        </output:serialization-parameters>
      ''');
      expect(
        () => SerializationParameters.fromElement(cmMissingAttrDoc.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0017)),
      );

      // Parameter element with invalid attribute (not value)
      final paramBadAttr = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:method value="xml" extra="123"/>
        </output:serialization-parameters>
      ''');
      expect(
        () => SerializationParameters.fromElement(paramBadAttr.rootElement),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SEPM0017)),
      );

      // Various parameter element settings from element
      final allParamsDoc = XmlDocument.parse('''
        <output:serialization-parameters
             xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:item-separator value=","/>
          <output:version value="1.1"/>
          <output:undeclare-prefixes value="yes"/>
          <output:encoding value="iso-8859-1"/>
          <output:cdata-section-elements value="b i"/>
          <output:suppress-indentation value="pre code"/>
        </output:serialization-parameters>
      ''');
      final pElem = SerializationParameters.fromElement(
        allParamsDoc.rootElement,
      );
      expect(pElem.itemSeparator, ',');
      expect(pElem.version, '1.1');
      expect(pElem.undeclarePrefixes, isTrue);
      expect(pElem.encoding, 'iso-8859-1');
      expect(pElem.cdataSectionElements.length, 2);
      expect(pElem.suppressIndentation.length, 2);
    });

    test('option helper functions validation', () {
      // _getStringOption with empty or multiple
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('method'): XPathSequence.empty}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // _getBooleanOption with empty or multiple
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('indent'): XPathSequence.empty}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      // _getNumberOption with empty or multiple, valid number, valid untyped, invalid untyped, invalid type
      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('html-version'): XPathSequence.empty}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      final pNum = SerializationParameters.fromMap(
        XPathMap({
          const XPathString('html-version'): seq(
            const XPathUntypedAtomic('5.0'),
          ),
        }),
      );
      expect(pNum.htmlVersion, 5.0);

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({
            const XPathString('html-version'): seq(
              const XPathUntypedAtomic('not-a-number'),
            ),
          }),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );

      expect(
        () => SerializationParameters.fromMap(
          XPathMap({const XPathString('html-version'): seq(true)}),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('serializeSequence edge cases and serialization methods', () {
      // Unknown method in SerializationParameters instance defaults to XML
      final pUnknown = SerializationParameters(method: 'custom-unknown');
      final sUnknown = serializeSequence(seq('hello'), pUnknown);
      expect(sUnknown, 'hello');

      // XML: consecutive atomics without item separator write space
      final sConsecutive = serializeSequence(
        seq([1, 2, 3]),
        SerializationParameters(method: 'xml'),
      );
      expect(sConsecutive, '1 2 3');

      // XML suppress-indentation with namespace
      final docNs = XmlDocument.parse(
        '<root xmlns:ns="http://example.com"><ns:pre> preserved </ns:pre></root>',
      );
      final pSuppressNs = SerializationParameters(
        method: 'xml',
        indent: true,
        suppressIndentation: [
          const XmlName.qualified('pre', namespaceUri: 'http://example.com'),
        ],
      );
      final sSuppress = serializeSequence(seq(docNs), pSuppressNs);
      expect(sSuppress, contains(' preserved '));

      // CDATA with namespace and self-closing empty element and XmlDeclaration
      final docCdataNs = XmlDocument.parse(
        '<?xml version="1.0"?><doc xmlns:ns="http://example.com"><ns:b attr="val">text</ns:b><br/></doc>',
      );
      final pCdataNs = SerializationParameters(
        method: 'xml',
        cdataSectionElements: [
          const XmlName.qualified('b', namespaceUri: 'http://example.com'),
        ],
      );
      final sCdata = serializeSequence(seq(docCdataNs), pCdataNs);
      expect(sCdata, contains('<![CDATA[text]]>'));
      expect(sCdata, contains('attr="val"'));
      expect(sCdata, contains('<br/>'));

      // HTML with sequence containing html element
      final htmlElem = XmlElement(const XmlName.qualified('html'), [], [
        XmlElement(const XmlName.qualified('body')),
      ]);
      final sHtmlElem = serializeSequence(
        seq(htmlElem),
        SerializationParameters(method: 'html'),
      );
      expect(sHtmlElem, contains('<!DOCTYPE html>'));

      // HTML with sequence containing atomic item
      final sHtmlAtomic = serializeSequence(
        seq('plain text'),
        SerializationParameters(method: 'html'),
      );
      expect(sHtmlAtomic, 'plain text');

      // JSON: sequence length > 1
      expect(
        () => serializeSequence(
          seq([1, 2]),
          SerializationParameters(method: 'json'),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0023)),
      );

      // JSON: duplicate keys without allowDuplicateNames
      final mapDup = XPathMap({
        XPathInteger.fromInt(1): seq('first'),
        const XPathString('1'): seq('second'),
      });
      expect(
        () => serializeSequence(
          XPathSequence.single(mapDup),
          SerializationParameters(method: 'json', allowDuplicateNames: false),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0022)),
      );

      // JSON: empty sequence inside map/array becomes null
      final mapWithEmpty = XPathMap({
        const XPathString('empty'): XPathSequence.empty,
      });
      final sMapEmpty = serializeSequence(
        XPathSequence.single(mapWithEmpty),
        SerializationParameters(method: 'json'),
      );
      expect(sMapEmpty, '{"empty":null}');

      const arrWithEmpty = XPathArray([XPathSequence.empty]);
      final sArrEmpty = serializeSequence(
        const XPathSequence.single(arrWithEmpty),
        SerializationParameters(method: 'json'),
      );
      expect(sArrEmpty, '[null]');

      // JSON: sequence length > 1 inside map/array throws SERE0023
      final mapWithMulti = XPathMap({
        const XPathString('k'): seq([1, 2]),
      });
      expect(
        () => serializeSequence(
          XPathSequence.single(mapWithMulti),
          SerializationParameters(method: 'json'),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0023)),
      );

      final arrWithMulti = XPathArray([
        seq([1, 2]),
      ]);
      expect(
        () => serializeSequence(
          XPathSequence.single(arrWithMulti),
          SerializationParameters(method: 'json'),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0023)),
      );

      // JSON: XmlDocument and XmlText inside JSON
      final docChild = XmlDocument.parse(
        '<?xml version="1.0"?><child>val</child>',
      );
      final sDocJson = serializeSequence(
        seq(docChild),
        SerializationParameters(method: 'json'),
      );
      expect(sDocJson, contains(r'<child>val<\/child>'));

      final textNode = XmlText('simple text');
      final sTextJson = serializeSequence(
        seq(textNode),
        SerializationParameters(method: 'json'),
      );
      expect(sTextJson, '"simple text"');

      // JSON: NaN and Infinity throw SERE0020
      expect(
        () => serializeSequence(
          seq(double.nan),
          SerializationParameters(method: 'json'),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.SERE0020)),
      );

      // Adaptive serialization: array, attribute, boolean
      final arrAdaptive = XPathArray([seq(1), seq(2)]);
      final sArrAdaptive = serializeSequence(
        XPathSequence.single(arrAdaptive),
        SerializationParameters(method: 'adaptive'),
      );
      expect(sArrAdaptive, '[1,2]');

      final elemWithAttr = XmlElement(const XmlName.qualified('el'), [
        XmlAttribute(const XmlName.qualified('id'), 'test'),
      ]);
      final attrNode = elemWithAttr.attributes.first;
      final sAttrAdaptive = serializeSequence(
        seq(attrNode),
        SerializationParameters(method: 'adaptive'),
      );
      expect(sAttrAdaptive, 'id="test"');

      final sElemAdaptiveIndent = serializeSequence(
        seq(elemWithAttr),
        SerializationParameters(method: 'adaptive', indent: true),
      );
      expect(sElemAdaptiveIndent, contains('<el id="test"/>'));

      final sBoolAdaptive = serializeSequence(
        seq(true),
        SerializationParameters(method: 'adaptive'),
      );
      expect(sBoolAdaptive, 'true()');

      // JSON string escaping: ", \, /, \b, \f, \n, \r, \t, control < 0x20, 0x7F-0x9F, iso-8859-1
      const rawStr = '"quote" /slash/ \\backslash\\ \b \f \n \r \t \x01 \x85';
      final sEscaped = serializeSequence(
        seq(rawStr),
        SerializationParameters(method: 'json'),
      );
      expect(sEscaped, contains(r'\"quote\"'));
      expect(sEscaped, contains(r'\/slash\/'));
      expect(sEscaped, contains(r'\\backslash\\'));
      expect(sEscaped, contains(r'\b'));
      expect(sEscaped, contains(r'\f'));
      expect(sEscaped, contains(r'\n'));
      expect(sEscaped, contains(r'\r'));
      expect(sEscaped, contains(r'\t'));
      expect(sEscaped, contains(r'\u0001'));
      expect(sEscaped, contains(r'\u0085'));

      final sIso = serializeSequence(
        seq('euro: \u20ac'),
        SerializationParameters(method: 'json', encoding: 'iso-8859-1'),
      );
      expect(sIso, contains(r'\u20AC'));
    });
  });
}
