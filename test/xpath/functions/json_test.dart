import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/json.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:parse-json', () {
    test('null', () {
      expect(fnParseJson(context, [seq('null')]), isXPathSequence(isEmpty));
    });
    test('boolean', () {
      expect(fnParseJson(context, [seq('true')]), isXPathSequence([true]));
      expect(fnParseJson(context, [seq('false')]), isXPathSequence([false]));
    });
    test('number', () {
      expect(fnParseJson(context, [seq('123')]), isXPathSequence([123.0]));
      expect(fnParseJson(context, [seq('12.34')]), isXPathSequence([12.34]));
    });
    test('string', () {
      expect(fnParseJson(context, [seq('"abc"')]), isXPathSequence(['abc']));
    });
    test('array', () {
      expect(
        fnParseJson(context, [seq('[1, 2]')]),
        isXPathSequence([
          [1.0, 2.0],
        ]),
      );
    });
    test('map', () {
      expect(
        fnParseJson(context, [seq('{"a": 1}')]),
        isXPathSequence([
          {'a': 1.0},
        ]),
      );
    });
    test('invalid', () {
      expect(() => fnParseJson(context, [seq('{')]), throwsA(isA<Exception>()));
    });
    test('empty', () {
      expect(
        fnParseJson(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
    test('options duplicates reject', () {
      expect(
        () => fnParseJson(context, [
          seq('{"a": 1, "a": 2}'),
          seq(XPathMap({const XPathString('duplicates'): seq('reject')})),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('options duplicates use-last', () {
      final result = fnParseJson(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({const XPathString('duplicates'): seq('use-last')})),
      ]);
      expect(
        (result.first as XPathMap).get(const XPathString('a')),
        isXPathSequence([2]),
      );
    });
    test('options liberal', () {
      final result = fnParseJson(context, [
        seq('{"a": 1,}'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      expect(
        (result.first as XPathMap).get(const XPathString('a')),
        isXPathSequence([1]),
      );
    });
    test('options escape and fallback', () {
      final fallbackFn = XPathFunctionItem.fn1(
        const XmlName.qualified('local:fallback'),
        (ctx, arg) => seq('?'),
      );
      final result = fnParseJson(context, [
        seq(r'"\u0000"'),
        seq(
          XPathMap({
            const XPathString('fallback'): XPathSequence.single(fallbackFn),
          }),
        ),
      ]);
      expect(result, isXPathSequence(['?']));
    });
    test('options duplicates retain throws in parse-json', () {
      expect(
        () => fnParseJson(context, [
          seq('{"a": 1}'),
          seq(XPathMap({const XPathString('duplicates'): seq('retain')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
    });
    test('options duplicates invalid value', () {
      expect(
        () => fnParseJson(context, [
          seq('{"a": 1}'),
          seq(XPathMap({const XPathString('duplicates'): seq('unknown')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
    });
    test('options escape and fallback conflict', () {
      final fallbackFn = XPathFunctionItem.fn1(
        const XmlName.qualified('local:fallback'),
        (ctx, arg) => seq('?'),
      );
      expect(
        () => fnParseJson(context, [
          seq(r'"\u0000"'),
          seq(
            XPathMap({
              const XPathString('escape'): seq(true),
              const XPathString('fallback'): XPathSequence.single(fallbackFn),
            }),
          ),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
    });
    test('options unknown key', () {
      expect(
        () => fnParseJson(context, [
          seq('123'),
          seq(XPathMap({const XPathString('foo'): seq('bar')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
    });
    test('options liberal comments and trailing commas', () {
      final result = fnParseJson(context, [
        seq('{"a": 10, "b": [1, 2,],}'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      expect(result.first, isA<XPathMap>());
    });
    test('options liberal trailing commas in array', () {
      final result = fnParseJson(context, [
        seq('[1, 2, 3,]'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      expect(
        result,
        isXPathSequence([
          [1.0, 2.0, 3.0],
        ]),
      );
    });
    test('multi-item argument throws XPTY0004', () {
      expect(
        () => fnParseJson(context, [
          seq(['1', '2']),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
    test('type errors for options types', () {
      expect(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('liberal'): seq('not-a-bool')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('duplicates'): seq(123)})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('fallback'): seq('not-a-func')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
    test('BOM prefix in parse-json', () {
      final res = fnParseJson(context, [seq('\uFEFF{"a": 1}')]);
      expect(
        (res.first as XPathMap).get(const XPathString('a')),
        isXPathSequence([1.0]),
      );
    });

    test('empty JSON input throws FOJS0001', () {
      expect(
        () => fnParseJson(context, [seq('')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001)),
      );
      expect(
        () => fnParseJson(context, [seq('   ')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001)),
      );
      expect(
        () => fnJsonToXml(context, [seq('')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001)),
      );
    });

    test('trailing junk after JSON value throws FOJS0001', () {
      expect(
        () => fnParseJson(context, [seq('123 trailing')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001)),
      );
      expect(
        () => fnJsonToXml(context, [seq('123 trailing')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001)),
      );
    });
  });
  group('fn:json-doc', () {
    final jsonDocContext = XPathConfiguration.raw(
      baseUri: 'http://example.com/json/',
      unparsedTextLoader: (uri, encoding) {
        if (uri == 'http://example.com/json/map.json') {
          return '{"a": 1, "b": true}';
        }
        if (uri == 'http://example.com/json/array.json') {
          return '[1, 2, 3]';
        }
        if (uri == 'http://example.com/json/invalid.json') {
          return '{invalid}';
        }
        return null;
      },
    ).context(XPathSequence.empty);

    test('2-argument fn:json-doc with options', () {
      final options = XPathMap({const XPathString('liberal'): seq(true)});
      final res = fnJsonDoc(jsonDocContext, [
        seq('http://example.com/json/map.json'),
        seq(options),
      ]);
      expect(
        res,
        isXPathSequence([
          {'a': 1.0, 'b': true},
        ]),
      );
    });

    test('returns empty sequence for empty href', () {
      expect(
        fnJsonDoc(jsonDocContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('loads and decodes map from absolute URI', () {
      expect(
        fnJsonDoc(jsonDocContext, [seq('http://example.com/json/map.json')]),
        isXPathSequence([
          {'a': 1.0, 'b': true},
        ]),
      );
    });

    test('resolves relative URI against baseUri', () {
      expect(
        fnJsonDoc(jsonDocContext, [seq('array.json')]),
        isXPathSequence([
          [1.0, 2.0, 3.0],
        ]),
      );
    });

    test('throws when static base URI is undefined for relative URI', () {
      expect(
        () => fnJsonDoc(context, [seq('map.json')]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('throws when URI contains fragment identifier', () {
      expect(
        () => fnJsonDoc(jsonDocContext, [seq('map.json#frag')]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('throws when resource is not found', () {
      expect(
        () => fnJsonDoc(jsonDocContext, [seq('missing.json')]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('throws when resource is invalid JSON', () {
      expect(
        () => fnJsonDoc(jsonDocContext, [seq('invalid.json')]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });
  group('fn:json-to-xml', () {
    test('basic', () {
      const input = '{"a": 1, "b": [null, true, 2, "c"]}';
      final result = fnJsonToXml(context, [seq(input)]);
      expect(
        ((result.single as XPathNode).node as XmlDocument).toXmlString(),
        '<map xmlns="http://www.w3.org/2005/xpath-functions">'
        '<number key="a">1</number>'
        '<array key="b">'
        '<null/>'
        '<boolean>true</boolean>'
        '<number>2</number>'
        '<string>c</string>'
        '</array>'
        '</map>',
      );
    });
    test('empty', () {
      expect(
        fnJsonToXml(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
    test('invalid', () {
      expect(
        () => fnJsonToXml(context, [seq('{')]),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('options duplicates use-first skips nested structures', () {
      const input = '''
      {
        "a": [1, [2, 3], {"sub": true}],
        "a": {"key": [1, 2], "nested": {}},
        "b": {}
      }
      ''';
      final result = fnJsonToXml(context, [
        seq(input),
        seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      expect(doc.findAllElements('array').length, equals(2));
    });

    test('options duplicates use-first and reject', () {
      final result = fnJsonToXml(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      expect(doc.findAllElements('number').length, 1);

      expect(
        () => fnJsonToXml(context, [
          seq('{"a": 1, "a": 2}'),
          seq(XPathMap({const XPathString('duplicates'): seq('reject')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003)),
      );
    });
    test('options duplicates retain with validate throws FOJS0005', () {
      expect(
        () => fnJsonToXml(context, [
          seq('{"a": 1}'),
          seq(
            XPathMap({
              const XPathString('duplicates'): seq('retain'),
              const XPathString('validate'): seq(true),
            }),
          ),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
    });
    test('options escape true escapes controls', () {
      final result = fnJsonToXml(context, [
        seq(r'{"ctrl": "\u0007"}'),
        seq(XPathMap({const XPathString('escape'): seq(true)})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      final strEl = doc.findAllElements('string').first;
      expect(strEl.getAttribute('escaped'), equals('true'));
      expect(strEl.innerText, equals(r'\u0007'));
    });
    test('options fallback function on characters', () {
      final fallbackFn = XPathFunctionItem.fn1(
        const XmlName.qualified('local:fallback'),
        (ctx, arg) => seq('[char]'),
      );
      final result = fnJsonToXml(context, [
        seq(r'{"ctrl": "\u0007"}'),
        seq(
          XPathMap({
            const XPathString('fallback'): XPathSequence.single(fallbackFn),
          }),
        ),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      expect(doc.findAllElements('string').first.innerText, equals('[char]'));
    });
  });
  group('fn:xml-to-json', () {
    test('basic', () {
      const input =
          '<?xml version="1.0"?>'
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<number key="a">1</number>'
          '<array key="b">'
          '<null/>'
          '<boolean>true</boolean>'
          '<number>2</number>'
          '<string>c</string>'
          '</array>'
          '</map>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      expect(result, isXPathSequence(['{"a":1,"b":[null,true,2,"c"]}']));
    });
    test('empty', () {
      expect(
        fnXmlToJson(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
    test('options indent', () {
      const input =
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<number key="a">1</number>'
          '</map>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [
        seq(document),
        seq(XPathMap({const XPathString('indent'): seq(true)})),
      ]);
      expect(result, isXPathSequence(['{\n  "a" : 1\n}']));
    });
    test('options invalid options', () {
      final doc = XmlDocument.parse(
        '<null xmlns="http://www.w3.org/2005/xpath-functions"/>',
      );
      expect(
        () => fnXmlToJson(context, [
          seq(doc),
          seq(XPathMap({const XPathString('unknown'): seq(true)})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005)),
      );
      expect(
        () => fnXmlToJson(context, [
          seq(doc),
          seq(XPathMap({const XPathString('indent'): seq('yes')})),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
    test('escaped text and surrogate pairs', () {
      const input =
          '<string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\\u0041\\uD83D\\uDE00\\n\\t\\r\\\\\\/\\"\\b\\f</string>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      expect(result.first.stringValue, contains(r'\u0041\uD83D\uDE00'));
    });
    test('escaped-key unescaping and surrogate pairs', () {
      const input =
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<null key="\\uD83D\\uDE00" escaped-key="true"/>'
          '</map>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      expect(result.first.stringValue, contains(r'\uD83D\uDE00'));
    });
    test('unescapeJsonString errors FOJS0007', () {
      void expectEscapeError(String keyContent) {
        final doc = XmlDocument.parse(
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<null key="$keyContent" escaped-key="true"/>'
          '</map>',
        );
        expect(
          () => fnXmlToJson(context, [seq(doc)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );
      }

      expectEscapeError(r'\');
      expectEscapeError(r'\u00');
      expectEscapeError(r'\u00ZZ');
      expectEscapeError(r'\uD800'); // unpaired high surrogate
      expectEscapeError(r'\uDC00'); // unpaired low surrogate
      expectEscapeError(r'\x'); // invalid escape
    });
    test('validation errors FOJS0006', () {
      void expectValidationError(String xml) {
        final doc = XmlDocument.parse(xml);
        expect(
          () => fnXmlToJson(context, [seq(doc)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );
      }

      // Wrong namespace
      expectValidationError('<map xmlns="http://example.com"/>');
      // Invalid element name
      expectValidationError(
        '<invalid xmlns="http://www.w3.org/2005/xpath-functions"/>',
      );
      // Disallowed attribute
      expectValidationError(
        '<null xmlns="http://www.w3.org/2005/xpath-functions" foo="bar"/>',
      );
      // Map child missing key
      expectValidationError(
        '<map xmlns="http://www.w3.org/2005/xpath-functions"><null/></map>',
      );
      // Map duplicate key
      expectValidationError(
        '<map xmlns="http://www.w3.org/2005/xpath-functions">'
        '<null key="k"/><null key="k"/>'
        '</map>',
      );
      // Non-whitespace text in map
      expectValidationError(
        '<map xmlns="http://www.w3.org/2005/xpath-functions">text</map>',
      );
      // Non-whitespace text in array
      expectValidationError(
        '<array xmlns="http://www.w3.org/2005/xpath-functions">text</array>',
      );
      // Invalid number formats: NaN, INF, non-numeric
      expectValidationError(
        '<number xmlns="http://www.w3.org/2005/xpath-functions">NaN</number>',
      );
      expectValidationError(
        '<number xmlns="http://www.w3.org/2005/xpath-functions">INF</number>',
      );
      expectValidationError(
        '<number xmlns="http://www.w3.org/2005/xpath-functions">abc</number>',
      );
    });
    test('formatting numbers in xml-to-json', () {
      final doc = XmlDocument.parse('''
        <array xmlns="http://www.w3.org/2005/xpath-functions">
          <number>0</number>
          <number>-0</number>
          <number>42</number>
          <number>-17</number>
          <number>12.34</number>
          <number>0.0000001</number>
          <number>10000000</number>
        </array>
      ''');
      final result = fnXmlToJson(context, [seq(doc)]);
      final str = result.first.stringValue;
      expect(str, contains('0'));
      expect(str, contains('-0'));
      expect(str, contains('42'));
      expect(str, contains('-17'));
      expect(str, contains('12.34'));
      expect(str, contains('E'));
    });

    group('edge cases and coverage completion', () {
      test('argument type checking', () {
        // _expectOptionalString
        expect(
          () => fnParseJson(context, [
            seq(['a', 'b']),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
        expect(
          () => fnParseJson(context, [seq(123)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
        // Untyped atomic string argument
        expect(
          fnParseJson(context, [seq(const XPathUntypedAtomic('123'))]),
          isXPathSequence([123.0]),
        );

        // _expectOptionalMap
        expect(
          () => fnParseJson(context, [
            seq('null'),
            seq([const XPathMap({}), const XPathMap({})]),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
        expect(
          () => fnParseJson(context, [seq('null'), seq('not-a-map')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );

        // _expectOptionalNode in fnXmlToJson
        expect(
          () => fnXmlToJson(context, [
            seq([XmlDocument(), XmlDocument()]),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
        expect(
          () => fnXmlToJson(context, [seq(123)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
      });

      test('options validation', () {
        // duplicates in json-to-xml invalid value
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-last')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
          ),
        );

        // escape not boolean
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('escape'): seq('yes')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );

        // validate not boolean
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('validate'): seq('yes')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );

        // fallback arity != 1
        final fallbackFn2 = XPathFunctionItem.fn2(
          const XmlName.qualified('local:fallback2'),
          (ctx, a, b) => seq('?'),
        );
        expect(
          () => fnParseJson(context, [
            seq(r'"\u0000"'),
            seq(
              XPathMap({
                const XPathString('fallback'): XPathSequence.single(
                  fallbackFn2,
                ),
              }),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          ),
        );
      });

      test('JSON parser syntax errors and edge cases in parse-json', () {
        // Unexpected end of JSON
        expect(
          () => fnParseJson(context, [seq('{"a": ')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Unexpected character
        expect(
          () => fnParseJson(context, [seq('@')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Empty object and array
        expect(
          fnParseJson(context, [seq('{}')]),
          isXPathSequence([isA<XPathMap>()]),
        );
        expect(
          fnParseJson(context, [seq('[]')]),
          isXPathSequence([isA<XPathArray>()]),
        );

        // Object missing colon
        expect(
          () => fnParseJson(context, [seq('{"a" 1}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Object trailing comma without liberal
        expect(
          () => fnParseJson(context, [seq('{"a": 1,}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Object missing comma or brace
        expect(
          () => fnParseJson(context, [seq('{"a": 1 "b": 2}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Array trailing comma without liberal
        expect(
          () => fnParseJson(context, [seq('[1,]')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Array missing comma or bracket
        expect(
          () => fnParseJson(context, [seq('[1 2]')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
      });

      test('JSON parser syntax errors and edge cases in json-to-xml', () {
        // BOM handling
        final resBom = fnJsonToXml(context, [seq('\uFEFF{"a": 1}')]);
        expect(resBom, isNotEmpty);

        // Unexpected end of JSON
        expect(
          () => fnJsonToXml(context, [seq('{"a": ')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Unexpected character
        expect(
          () => fnJsonToXml(context, [seq('@')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Boolean false
        expect(fnJsonToXml(context, [seq('false')]).first.stringValue, 'false');
        // Empty string
        expect(fnJsonToXml(context, [seq('""')]).first.stringValue, '');

        // Empty array in XML
        final resArr = fnJsonToXml(context, [seq('[]')]);
        expect(resArr.first, isA<XPathNode>());

        // Trailing comma with liberal: true in array
        final resLibArr = fnJsonToXml(context, [
          seq('[1,]'),
          seq(XPathMap({const XPathString('liberal'): seq(true)})),
        ]);
        expect(resLibArr.first, isA<XPathNode>());

        // Trailing comma without liberal in array
        expect(
          () => fnJsonToXml(context, [seq('[1,]')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Array missing comma or bracket in XML
        expect(
          () => fnJsonToXml(context, [seq('[1 2]')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Object missing colon
        expect(
          () => fnJsonToXml(context, [seq('{"a" 1}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Object trailing comma without liberal
        expect(
          () => fnJsonToXml(context, [seq('{"a": 1,}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Object missing comma or brace
        expect(
          () => fnJsonToXml(context, [seq('{"a": 1 "b": 2}')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Duplicate key with validate=true
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": 2}'),
            seq(XPathMap({const XPathString('validate'): seq(true)})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
          ),
        );

        // Escaped key attribute
        final resEsc = fnJsonToXml(context, [
          seq(r'{"\u0061": 1}'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        final escXml = (resEsc.first as XPathNode).node.toXmlString();
        expect(escXml, contains('key="a"'));

        // Skip json value when duplicate with use-first
        final resSkip = fnJsonToXml(context, [
          seq('{"a": 1, "a": [true, false, null, "str", {"k": 2}, []]}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        expect(resSkip.first, isA<XPathNode>());
      });

      test('escape and unicode handling', () {
        // Unterminated escape
        expect(
          () => fnParseJson(context, [seq('"abc\\')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Escapes: \", \\, \/
        expect(fnParseJson(context, [seq(r'"\""')]), isXPathSequence(['"']));
        expect(fnParseJson(context, [seq(r'"\/"')]), isXPathSequence(['/']));
        expect(
          fnParseJson(context, [
            seq(r'"\\"'),
            seq(XPathMap({const XPathString('escape'): seq(true)})),
          ]),
          isXPathSequence([r'\\']),
        );

        // Control escapes with escape: true
        final resEscControls = fnJsonToXml(context, [
          seq(r'"\b\f\n\r\t"'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        final xmlEsc = (resEscControls.first as XPathNode).node.toXmlString();
        expect(xmlEsc, contains('escaped="true"'));

        // Invalid escape char
        expect(
          () => fnParseJson(context, [seq(r'"\x"')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Raw unescaped control char
        expect(
          () => fnParseJson(context, [seq('"\x01"')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Unterminated string
        expect(
          () => fnParseJson(context, [seq('"unterminated')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Hex digits insufficient or invalid
        expect(
          () => fnParseJson(context, [seq(r'"\u12"')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        expect(
          () => fnParseJson(context, [seq(r'"\u12G4"')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Surrogate pairs & unpaired surrogates
        expect(
          fnParseJson(context, [seq(r'"\uD83D\uDE00"')]),
          isXPathSequence(['\u{1F600}']),
        );
        expect(
          fnParseJson(context, [seq(r'"\uD800"')]),
          isXPathSequence(['\uFFFD']),
        );
        expect(
          fnParseJson(context, [seq(r'"\uDC00"')]),
          isXPathSequence(['\uFFFD']),
        );
        expect(
          fnParseJson(context, [seq(r'"\uFFFE"')]),
          isXPathSequence(['\uFFFD']),
        );
        expect(
          fnParseJson(context, [seq(r'"\uFFFF"')]),
          isXPathSequence(['\uFFFD']),
        );

        // Fallback returning non-string or throwing error
        final badFallback = XPathFunctionItem.fn1(
          const XmlName.qualified('local:badFallback'),
          (ctx, arg) => seq(123),
        );
        expect(
          () => fnParseJson(context, [
            seq(r'"\u0000"'),
            seq(
              XPathMap({
                const XPathString('fallback'): XPathSequence.single(
                  badFallback,
                ),
              }),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
          ),
        );

        final throwingFallback = XPathFunctionItem.fn1(
          const XmlName.qualified('local:throwingFallback'),
          (ctx, arg) => throw StateError('boom'),
        );
        expect(
          () => fnParseJson(context, [
            seq(r'"\u0000"'),
            seq(
              XPathMap({
                const XPathString('fallback'): XPathSequence.single(
                  throwingFallback,
                ),
              }),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
          ),
        );
      });

      test('number and literal parser branches', () {
        // Minus without digits
        expect(
          () => fnParseJson(context, [seq('-')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        expect(
          () => fnParseJson(context, [seq('-a')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Leading zero
        expect(
          () => fnParseJson(context, [seq('01')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Decimal without digits
        expect(
          () => fnParseJson(context, [seq('1.')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        // Exponents
        expect(fnParseJson(context, [seq('1e+2')]), isXPathSequence([100.0]));
        expect(fnParseJson(context, [seq('1e-2')]), isXPathSequence([0.01]));
        expect(
          () => fnParseJson(context, [seq('1e')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
        expect(
          () => fnParseJson(context, [seq('1e+')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Literal mismatch
        expect(
          () => fnParseJson(context, [seq('trux')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );
      });

      test('xml-to-json edge cases and serialization validation', () {
        // Input node is neither document nor element
        final comment = XmlComment('comment');
        expect(
          () => fnXmlToJson(context, [seq(comment)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // Empty XML document
        final emptyDoc = XmlDocument();
        expect(
          () => fnXmlToJson(context, [seq(emptyDoc)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // xml:space="preserve" allowed
        final docSpace = XmlDocument.parse('''
          <string xmlns="http://www.w3.org/2005/xpath-functions"
                  xml:space="preserve">  hello  </string>
        ''');
        expect(
          fnXmlToJson(context, [seq(docSpace)]).first.stringValue,
          '"  hello  "',
        );

        // Array with indent
        final docArrIndent = XmlDocument.parse('''
          <array xmlns="http://www.w3.org/2005/xpath-functions">
            <number>1</number>
            <number>2</number>
          </array>
        ''');
        final resArrIndent = fnXmlToJson(context, [
          seq(docArrIndent),
          seq(XPathMap({const XPathString('indent'): seq(true)})),
        ]);
        expect(resArrIndent.first.stringValue, contains('\n'));

        // String, number, boolean, null with child elements throw FOJS0006
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <string xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <number xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </number>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </boolean>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <null xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </null>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // Null element with text throws FOJS0006
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <null xmlns="http://www.w3.org/2005/xpath-functions">not-null</null>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // Boolean values '1' and '0'
        expect(
          fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">1</boolean>
            '''),
            ),
          ]).first.stringValue,
          'true',
        );
        expect(
          fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">0</boolean>
            '''),
            ),
          ]).first.stringValue,
          'false',
        );

        // Invalid boolean content
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">yes</boolean>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // Escaped attribute validation on string
        final docEscapes = XmlDocument.parse(r'''
          <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\"\\\/\b\f\n\r\t\u0020"</string>
        ''');
        final resEscContent = fnXmlToJson(context, [
          seq(docEscapes),
        ]).first.stringValue;
        expect(resEscContent, contains(r'\"'));

        // Unterminated escape in escaped string
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">abc\</string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        // Incomplete \u in escaped string
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\u12</string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        // Invalid hex in \u in escaped string
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\u12G4</string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        // Invalid escape sequence \x in escaped string
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\x</string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        // Escaped-key unescaping in map
        final docEscKey = XmlDocument.parse(r'''
          <map xmlns="http://www.w3.org/2005/xpath-functions">
            <number key='\"\\\/\b\f\n\r\t\u0020' escaped-key="true">1</number>
          </map>
        ''');
        final resEscKey = fnXmlToJson(context, [
          seq(docEscKey),
        ]).first.stringValue;
        expect(resEscKey, contains('1'));

        // Unpaired surrogates in escaped-key
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <map xmlns="http://www.w3.org/2005/xpath-functions">
                <number key="\uD800" escaped-key="true">1</number>
              </map>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <map xmlns="http://www.w3.org/2005/xpath-functions">
                <number key="\uDC00" escaped-key="true">1</number>
              </map>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
          ),
        );

        // Invalid boolean attribute value
        expect(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="maybe">text</string>
            '''),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
          ),
        );

        // Unescaped string characters in xml-to-json: ", \, /, \b, \f, \n, \r, \t, control < 0x20
        final docRawChars = XmlDocument.parse('''
          <string xmlns="http://www.w3.org/2005/xpath-functions">"quote" /slash/ \\backslash\\ \b \f \n \r \t \x01 \x85</string>
        ''');
        final resRaw = fnXmlToJson(context, [
          seq(docRawChars),
        ]).first.stringValue;
        expect(resRaw, contains(r'\"quote\"'));
        expect(resRaw, contains(r'\/slash\/'));
        expect(resRaw, contains(r'\\backslash\\'));
        expect(resRaw, contains(r'\b'));
        expect(resRaw, contains(r'\f'));
        expect(resRaw, contains(r'\n'));
        expect(resRaw, contains(r'\r'));
        expect(resRaw, contains(r'\t'));
        expect(resRaw, contains(r'\u0001'));
        expect(resRaw, contains(r'\u0085'));
      });

      test('additional json-to-xml and xml-to-json edge cases', () {
        // validate: true with duplicates: 'use-first'
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": 2}'),
            seq(
              XPathMap({
                const XPathString('validate'): seq(true),
                const XPathString('duplicates'): seq('use-first'),
              }),
            ),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
          ),
        );

        // escaped-key attribute on XML element
        final resEscBackslash = fnJsonToXml(context, [
          seq(r'{"\\": 1}'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        expect(
          (resEscBackslash.first as XPathNode).node.toXmlString(),
          contains('escaped-key="true"'),
        );

        // Trailing comma in object with liberal: true in json-to-xml
        final resObjLib = fnJsonToXml(context, [
          seq('{"a": 1,}'),
          seq(XPathMap({const XPathString('liberal'): seq(true)})),
        ]);
        expect(resObjLib.first, isA<XPathNode>());

        // _skipJsonValue syntax errors
        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": '),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": {"k" 2}}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        final resSkipObjComma = fnJsonToXml(context, [
          seq('{"a": 1, "a": {"k": 2,}}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        expect(resSkipObjComma.first, isA<XPathNode>());

        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": {"k": 2 "j": 3}}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        final resSkipArrComma = fnJsonToXml(context, [
          seq('{"a": 1, "a": [1,]}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        expect(resSkipArrComma.first, isA<XPathNode>());

        expect(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": [1 2]}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          ),
        );

        // Control escape handling with escape: false in json-to-xml
        // xml10Valid == true (\n, \r, \t)
        final resXmlValidControls = fnJsonToXml(context, [
          seq(r'"\n\r\t"'),
          seq(XPathMap({const XPathString('escape'): seq(false)})),
        ]);
        expect(resXmlValidControls.first.stringValue, '\n\r\t');

        // xml10Valid == false (\b, \f) without fallback produces \uFFFD
        final resXmlInvalidControls = fnJsonToXml(context, [
          seq(r'"\b\f"'),
          seq(XPathMap({const XPathString('escape'): seq(false)})),
        ]);
        expect(resXmlInvalidControls.first.stringValue, '\uFFFD\uFFFD');

        // xml10Valid == false (\b, \f) with fallback
        final fallbackFn = XPathFunctionItem.fn1(
          const XmlName.qualified('local:fallback'),
          (ctx, arg) => seq('[FB]'),
        );
        final resXmlInvalidFallback = fnJsonToXml(context, [
          seq(r'"\b\f"'),
          seq(
            XPathMap({
              const XPathString('escape'): seq(false),
              const XPathString('fallback'): XPathSequence.single(fallbackFn),
            }),
          ),
        ]);
        expect(resXmlInvalidFallback.first.stringValue, '[FB][FB]');

        // options.escape == true and \u0009\u000A\u000D
        final resEscapedTabs = fnJsonToXml(context, [
          seq(r'"\u0009\u000A\u000D"'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        expect(
          (resEscapedTabs.first as XPathNode).node.toXmlString(),
          contains('escaped="true"'),
        );

        // escaped: true element with raw control characters
        final rawControlElem = XmlElement(
          const XmlName.qualified(
            'string',
            namespaceUri: 'http://www.w3.org/2005/xpath-functions',
          ),
          [XmlAttribute(const XmlName.qualified('escaped'), 'true')],
          [XmlText('\b\f\n\r\t\x01\x85')],
        );
        final resEscRawControls = fnXmlToJson(context, [
          seq(rawControlElem),
        ]).first.stringValue;
        expect(resEscRawControls, contains(r'\b'));
        expect(resEscRawControls, contains(r'\f'));
        expect(resEscRawControls, contains(r'\n'));
        expect(resEscRawControls, contains(r'\r'));
        expect(resEscRawControls, contains(r'\t'));
        expect(resEscRawControls, contains(r'\u0001'));
        expect(resEscRawControls, contains(r'\u0085'));

        // _unescapeJsonString regular character before escape
        final docUnescapeChar = XmlDocument.parse(r'''
          <map xmlns="http://www.w3.org/2005/xpath-functions">
            <number key='prefix\"' escaped-key="true">42</number>
          </map>
        ''');
        final resUnescapeChar = fnXmlToJson(context, [
          seq(docUnescapeChar),
        ]).first.stringValue;
        expect(resUnescapeChar, contains('prefix'));
      });
    });
  });
}
