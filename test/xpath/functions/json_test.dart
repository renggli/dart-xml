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
  });
}
