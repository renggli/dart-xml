import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/json.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:parse-json', () {
    test('null', () {
      check(fnParseJson(context, [seq('null')])).isXPathSequence(isEmpty);
    });
    test('boolean', () {
      check(fnParseJson(context, [seq('true')])).isXPathSequence([true]);
      check(fnParseJson(context, [seq('false')])).isXPathSequence([false]);
    });
    test('number', () {
      check(fnParseJson(context, [seq('123')])).isXPathSequence([123.0]);
      check(fnParseJson(context, [seq('12.34')])).isXPathSequence([12.34]);
    });
    test('string', () {
      check(fnParseJson(context, [seq('"abc"')])).isXPathSequence(['abc']);
    });
    test('array', () {
      check(fnParseJson(context, [seq('[1, 2]')])).isXPathSequence([
        [1.0, 2.0],
      ]);
    });
    test('map', () {
      check(fnParseJson(context, [seq('{"a": 1}')])).isXPathSequence([
        {'a': 1.0},
      ]);
    });
    test('invalid', () {
      check(() => fnParseJson(context, [seq('{')])).throws<Exception>();
    });
    test('empty', () {
      check(fnParseJson(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
    test('options duplicates reject', () {
      check(
        () => fnParseJson(context, [
          seq('{"a": 1, "a": 2}'),
          seq(XPathMap({const XPathString('duplicates'): seq('reject')})),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });
    test('options duplicates use-last', () {
      final result = fnParseJson(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({const XPathString('duplicates'): seq('use-last')})),
      ]);
      check((result.first as XPathMap).get(const XPathString('a')))
          .isNotNull()
          .isXPathSequence([2]);
    });
    test('options liberal', () {
      final result = fnParseJson(context, [
        seq('{"a": 1,}'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      check((result.first as XPathMap).get(const XPathString('a')))
          .isNotNull()
          .isXPathSequence([1]);
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
      check(result).isXPathSequence(['?']);
    });
    test('options duplicates retain throws in parse-json', () {
      check(
        () => fnParseJson(context, [
          seq('{"a": 1}'),
          seq(XPathMap({const XPathString('duplicates'): seq('retain')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });
    test('options duplicates invalid value', () {
      check(
        () => fnParseJson(context, [
          seq('{"a": 1}'),
          seq(XPathMap({const XPathString('duplicates'): seq('unknown')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });
    test('options escape and fallback conflict', () {
      final fallbackFn = XPathFunctionItem.fn1(
        const XmlName.qualified('local:fallback'),
        (ctx, arg) => seq('?'),
      );
      check(
        () => fnParseJson(context, [
          seq(r'"\u0000"'),
          seq(
            XPathMap({
              const XPathString('escape'): seq(true),
              const XPathString('fallback'): XPathSequence.single(fallbackFn),
            }),
          ),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });
    test('options unknown key', () {
      check(
        () => fnParseJson(context, [
          seq('123'),
          seq(XPathMap({const XPathString('foo'): seq('bar')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });
    test('options liberal comments and trailing commas', () {
      final result = fnParseJson(context, [
        seq('{"a": 10, "b": [1, 2,],}'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      check(result.first).isA<XPathMap>();
    });
    test('options liberal trailing commas in array', () {
      final result = fnParseJson(context, [
        seq('[1, 2, 3,]'),
        seq(XPathMap({const XPathString('liberal'): seq(true)})),
      ]);
      check(result).isXPathSequence([
        [1.0, 2.0, 3.0],
      ]);
    });
    test('multi-item argument throws XPTY0004', () {
      check(
        () => fnParseJson(context, [
          seq(['1', '2']),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });
    test('type errors for options types', () {
      check(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('liberal'): seq('not-a-bool')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('duplicates'): seq(123)})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnParseJson(context, [
          seq('1'),
          seq(XPathMap({const XPathString('fallback'): seq('not-a-func')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });
    test('BOM prefix in parse-json', () {
      final res = fnParseJson(context, [seq('\uFEFF{"a": 1}')]);
      check((res.first as XPathMap).get(const XPathString('a')))
          .isNotNull()
          .isXPathSequence([1.0]);
    });

    test('empty JSON input throws FOJS0001', () {
      check(() => fnParseJson(context, [seq('')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          );
      check(() => fnParseJson(context, [seq('   ')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          );
      check(() => fnJsonToXml(context, [seq('')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          );
    });

    test('trailing junk after JSON value throws FOJS0001', () {
      check(() => fnParseJson(context, [seq('123 trailing')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
          );
      check(() => fnJsonToXml(context, [seq('123 trailing')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
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
      check(res).isXPathSequence([
        {'a': 1.0, 'b': true},
      ]);
    });

    test('returns empty sequence for empty href', () {
      check(fnJsonDoc(jsonDocContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });

    test('loads and decodes map from absolute URI', () {
      check(
        fnJsonDoc(jsonDocContext, [seq('http://example.com/json/map.json')]),
      ).isXPathSequence([
        {'a': 1.0, 'b': true},
      ]);
    });

    test('resolves relative URI against baseUri', () {
      check(fnJsonDoc(jsonDocContext, [seq('array.json')])).isXPathSequence([
        [1.0, 2.0, 3.0],
      ]);
    });

    test('throws when static base URI is undefined for relative URI', () {
      check(() => fnJsonDoc(context, [seq('map.json')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('throws when URI contains fragment identifier', () {
      check(() => fnJsonDoc(jsonDocContext, [seq('map.json#frag')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('throws when resource is not found', () {
      check(() => fnJsonDoc(jsonDocContext, [seq('missing.json')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('throws when resource is invalid JSON', () {
      check(() => fnJsonDoc(jsonDocContext, [seq('invalid.json')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });
  group('fn:json-to-xml', () {
    test('basic', () {
      const input = '{"a": 1, "b": [null, true, 2, "c"]}';
      final result = fnJsonToXml(context, [seq(input)]);
      check(((result.single as XPathNode).node as XmlDocument).toXmlString())
          .equals(
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
      check(fnJsonToXml(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
    test('invalid', () {
      check(() => fnJsonToXml(context, [seq('{')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
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
      check(doc.findAllElements('array').length).equals(2);
    });

    test('options duplicates use-first and reject', () {
      final result = fnJsonToXml(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      check(doc.findAllElements('number').length).equals(1);

      check(
        () => fnJsonToXml(context, [
          seq('{"a": 1, "a": 2}'),
          seq(XPathMap({const XPathString('duplicates'): seq('reject')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
      );
    });
    test('options duplicates retain with validate throws FOJS0005', () {
      check(
        () => fnJsonToXml(context, [
          seq('{"a": 1}'),
          seq(
            XPathMap({
              const XPathString('duplicates'): seq('retain'),
              const XPathString('validate'): seq(true),
            }),
          ),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });
    test('options escape true escapes controls', () {
      final result = fnJsonToXml(context, [
        seq(r'{"ctrl": "\u0007"}'),
        seq(XPathMap({const XPathString('escape'): seq(true)})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      final strEl = doc.findAllElements('string').first;
      check(strEl.getAttribute('escaped')).equals('true');
      check(strEl.innerText).equals(r'\u0007');
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
      check(doc.findAllElements('string').first.innerText).equals('[char]');
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
      check(result).isXPathSequence(['{"a":1,"b":[null,true,2,"c"]}']);
    });
    test('empty', () {
      check(fnXmlToJson(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
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
      check(result).isXPathSequence(['{\n  "a" : 1\n}']);
    });
    test('options invalid options', () {
      final doc = XmlDocument.parse(
        '<null xmlns="http://www.w3.org/2005/xpath-functions"/>',
      );
      check(
        () => fnXmlToJson(context, [
          seq(doc),
          seq(XPathMap({const XPathString('unknown'): seq(true)})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
      check(
        () => fnXmlToJson(context, [
          seq(doc),
          seq(XPathMap({const XPathString('indent'): seq('yes')})),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });
    test('escaped text and surrogate pairs', () {
      const input =
          '<string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\\u0041\\uD83D\\uDE00\\n\\t\\r\\\\\\/\\"\\b\\f</string>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      check(result.first.stringValue).contains(r'\u0041\uD83D\uDE00');
    });
    test('escaped-key unescaping and surrogate pairs', () {
      const input =
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<null key="\\uD83D\\uDE00" escaped-key="true"/>'
          '</map>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      check(result.first.stringValue).contains(r'\uD83D\uDE00');
    });
    test('unescapeJsonString errors FOJS0007', () {
      void expectEscapeError(String keyContent) {
        final doc = XmlDocument.parse(
          '<map xmlns="http://www.w3.org/2005/xpath-functions">'
          '<null key="$keyContent" escaped-key="true"/>'
          '</map>',
        );
        check(() => fnXmlToJson(context, [seq(doc)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
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
        check(() => fnXmlToJson(context, [seq(doc)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
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
      check(str).contains('0');
      check(str).contains('-0');
      check(str).contains('42');
      check(str).contains('-17');
      check(str).contains('12.34');
      check(str).contains('E');
    });

    group('edge cases and coverage completion', () {
      test('argument type checking', () {
        // _expectOptionalString
        check(
          () => fnParseJson(context, [
            seq(['a', 'b']),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );
        check(() => fnParseJson(context, [seq(123)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
            );
        // Untyped atomic string argument
        check(fnParseJson(context, [seq(const XPathUntypedAtomic('123'))]))
            .isXPathSequence([123.0]);

        // _expectOptionalMap
        check(
          () => fnParseJson(context, [
            seq('null'),
            seq([const XPathMap({}), const XPathMap({})]),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );
        check(() => fnParseJson(context, [seq('null'), seq('not-a-map')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
            );

        // _expectOptionalNode in fnXmlToJson
        check(
          () => fnXmlToJson(context, [
            seq([XmlDocument(), XmlDocument()]),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );
        check(() => fnXmlToJson(context, [seq(123)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
            );
      });

      test('options validation', () {
        // duplicates in json-to-xml invalid value
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-last')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
        );

        // escape not boolean
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('escape'): seq('yes')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );

        // validate not boolean
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1}'),
            seq(XPathMap({const XPathString('validate'): seq('yes')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );

        // fallback arity != 1
        final fallbackFn2 = XPathFunctionItem.fn2(
          const XmlName.qualified('local:fallback2'),
          (ctx, a, b) => seq('?'),
        );
        check(
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
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
        );
      });

      test('JSON parser syntax errors and edge cases in parse-json', () {
        // Unexpected end of JSON
        check(() => fnParseJson(context, [seq('{"a": ')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Unexpected character
        check(() => fnParseJson(context, [seq('@')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Empty object and array
        check(fnParseJson(context, [seq('{}')]))
            .isXPathSequence([isA<XPathMap>()]);
        check(fnParseJson(context, [seq('[]')]))
            .isXPathSequence([isA<XPathArray>()]);

        // Object missing colon
        check(() => fnParseJson(context, [seq('{"a" 1}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Object trailing comma without liberal
        check(() => fnParseJson(context, [seq('{"a": 1,}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Object missing comma or brace
        check(() => fnParseJson(context, [seq('{"a": 1 "b": 2}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Array trailing comma without liberal
        check(() => fnParseJson(context, [seq('[1,]')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Array missing comma or bracket
        check(() => fnParseJson(context, [seq('[1 2]')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
      });

      test('JSON parser syntax errors and edge cases in json-to-xml', () {
        // BOM handling
        final resBom = fnJsonToXml(context, [seq('\uFEFF{"a": 1}')]);
        check(resBom).isNotEmpty();

        // Unexpected end of JSON
        check(() => fnJsonToXml(context, [seq('{"a": ')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Unexpected character
        check(() => fnJsonToXml(context, [seq('@')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Boolean false
        check(fnJsonToXml(context, [seq('false')]).first.stringValue)
            .equals('false');
        // Empty string
        check(fnJsonToXml(context, [seq('""')]).first.stringValue).equals('');

        // Empty array in XML
        final resArr = fnJsonToXml(context, [seq('[]')]);
        check(resArr.first).isA<XPathNode>();

        // Trailing comma with liberal: true in array
        final resLibArr = fnJsonToXml(context, [
          seq('[1,]'),
          seq(XPathMap({const XPathString('liberal'): seq(true)})),
        ]);
        check(resLibArr.first).isA<XPathNode>();

        // Trailing comma without liberal in array
        check(() => fnJsonToXml(context, [seq('[1,]')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Array missing comma or bracket in XML
        check(() => fnJsonToXml(context, [seq('[1 2]')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Object missing colon
        check(() => fnJsonToXml(context, [seq('{"a" 1}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Object trailing comma without liberal
        check(() => fnJsonToXml(context, [seq('{"a": 1,}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Object missing comma or brace
        check(() => fnJsonToXml(context, [seq('{"a": 1 "b": 2}')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Duplicate key with validate=true
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": 2}'),
            seq(XPathMap({const XPathString('validate'): seq(true)})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
        );

        // Escaped key attribute
        final resEsc = fnJsonToXml(context, [
          seq(r'{"\u0061": 1}'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        final escXml = (resEsc.first as XPathNode).node.toXmlString();
        check(escXml).contains('key="a"');

        // Skip json value when duplicate with use-first
        final resSkip = fnJsonToXml(context, [
          seq('{"a": 1, "a": [true, false, null, "str", {"k": 2}, []]}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        check(resSkip.first).isA<XPathNode>();
      });

      test('escape and unicode handling', () {
        // Unterminated escape
        check(() => fnParseJson(context, [seq('"abc\\')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Escapes: \", \\, \/
        check(fnParseJson(context, [seq(r'"\""')])).isXPathSequence(['"']);
        check(fnParseJson(context, [seq(r'"\/"')])).isXPathSequence(['/']);
        check(
          fnParseJson(context, [
            seq(r'"\\"'),
            seq(XPathMap({const XPathString('escape'): seq(true)})),
          ]),
        ).isXPathSequence([r'\\']);

        // Control escapes with escape: true
        final resEscControls = fnJsonToXml(context, [
          seq(r'"\b\f\n\r\t"'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        final xmlEsc = (resEscControls.first as XPathNode).node.toXmlString();
        check(xmlEsc).contains('escaped="true"');

        // Invalid escape char
        check(() => fnParseJson(context, [seq(r'"\x"')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Raw unescaped control char
        check(() => fnParseJson(context, [seq('"\x01"')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Unterminated string
        check(() => fnParseJson(context, [seq('"unterminated')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Hex digits insufficient or invalid
        check(() => fnParseJson(context, [seq(r'"\u12"')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        check(() => fnParseJson(context, [seq(r'"\u12G4"')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Surrogate pairs & unpaired surrogates
        check(fnParseJson(context, [seq(r'"\uD83D\uDE00"')]))
            .isXPathSequence(['\u{1F600}']);
        check(fnParseJson(context, [seq(r'"\uD800"')]))
            .isXPathSequence(['\uFFFD']);
        check(fnParseJson(context, [seq(r'"\uDC00"')]))
            .isXPathSequence(['\uFFFD']);
        check(fnParseJson(context, [seq(r'"\uFFFE"')]))
            .isXPathSequence(['\uFFFD']);
        check(fnParseJson(context, [seq(r'"\uFFFF"')]))
            .isXPathSequence(['\uFFFD']);

        // Fallback returning non-string or throwing error
        final badFallback = XPathFunctionItem.fn1(
          const XmlName.qualified('local:badFallback'),
          (ctx, arg) => seq(123),
        );
        check(
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
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
        );

        final throwingFallback = XPathFunctionItem.fn1(
          const XmlName.qualified('local:throwingFallback'),
          (ctx, arg) => throw StateError('boom'),
        );
        check(
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
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
        );
      });

      test('number and literal parser branches', () {
        // Minus without digits
        check(() => fnParseJson(context, [seq('-')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        check(() => fnParseJson(context, [seq('-a')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Leading zero
        check(() => fnParseJson(context, [seq('01')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Decimal without digits
        check(() => fnParseJson(context, [seq('1.')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        // Exponents
        check(fnParseJson(context, [seq('1e+2')])).isXPathSequence([100.0]);
        check(fnParseJson(context, [seq('1e-2')])).isXPathSequence([0.01]);
        check(() => fnParseJson(context, [seq('1e')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
        check(() => fnParseJson(context, [seq('1e+')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );

        // Literal mismatch
        check(() => fnParseJson(context, [seq('trux')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
            );
      });

      test('xml-to-json edge cases and serialization validation', () {
        // Input node is neither document nor element
        final comment = XmlComment('comment');
        check(() => fnXmlToJson(context, [seq(comment)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
            );

        // Empty XML document
        final emptyDoc = XmlDocument();
        check(() => fnXmlToJson(context, [seq(emptyDoc)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
            );

        // xml:space="preserve" allowed
        final docSpace = XmlDocument.parse('''
          <string xmlns="http://www.w3.org/2005/xpath-functions"
                  xml:space="preserve">  hello  </string>
        ''');
        check(fnXmlToJson(context, [seq(docSpace)]).first.stringValue)
            .equals('"  hello  "');

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
        check(resArrIndent.first.stringValue).contains('\n');

        // String, number, boolean, null with child elements throw FOJS0006
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <string xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <number xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </number>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </boolean>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <null xmlns="http://www.w3.org/2005/xpath-functions">
                <bad/>
              </null>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        // Null element with text throws FOJS0006
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <null xmlns="http://www.w3.org/2005/xpath-functions">not-null</null>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        // Boolean values '1' and '0'
        check(
          fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">1</boolean>
            '''),
            ),
          ]).first.stringValue,
        ).equals('true');
        check(
          fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">0</boolean>
            '''),
            ),
          ]).first.stringValue,
        ).equals('false');

        // Invalid boolean content
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse('''
              <boolean xmlns="http://www.w3.org/2005/xpath-functions">yes</boolean>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        // Escaped attribute validation on string
        final docEscapes = XmlDocument.parse(r'''
          <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\"\\\/\b\f\n\r\t\u0020"</string>
        ''');
        final resEscContent = fnXmlToJson(context, [
          seq(docEscapes),
        ]).first.stringValue;
        check(resEscContent).contains(r'\"');

        // Unterminated escape in escaped string
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">abc\</string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
        );

        // Incomplete \u in escaped string
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\u12</string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
        );

        // Invalid hex in \u in escaped string
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\u12G4</string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
        );

        // Invalid escape sequence \x in escaped string
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\x</string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
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
        check(resEscKey).contains('1');

        // Unpaired surrogates in escaped-key
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <map xmlns="http://www.w3.org/2005/xpath-functions">
                <number key="\uD800" escaped-key="true">1</number>
              </map>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
        );

        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <map xmlns="http://www.w3.org/2005/xpath-functions">
                <number key="\uDC00" escaped-key="true">1</number>
              </map>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0007),
        );

        // Invalid boolean attribute value
        check(
          () => fnXmlToJson(context, [
            seq(
              XmlDocument.parse(r'''
              <string xmlns="http://www.w3.org/2005/xpath-functions" escaped="maybe">text</string>
            '''),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0006),
        );

        // Unescaped string characters in xml-to-json: ", \, /, \b, \f, \n, \r, \t, control < 0x20
        final docRawChars = XmlDocument.parse('''
          <string xmlns="http://www.w3.org/2005/xpath-functions">"quote" /slash/ \\backslash\\ \b \f \n \r \t \x01 \x85</string>
        ''');
        final resRaw = fnXmlToJson(context, [
          seq(docRawChars),
        ]).first.stringValue;
        check(resRaw).contains(r'\"quote\"');
        check(resRaw).contains(r'\/slash\/');
        check(resRaw).contains(r'\\backslash\\');
        check(resRaw).contains(r'\b');
        check(resRaw).contains(r'\f');
        check(resRaw).contains(r'\n');
        check(resRaw).contains(r'\r');
        check(resRaw).contains(r'\t');
        check(resRaw).contains(r'\u0001');
        check(resRaw).contains(r'\u0085');
      });

      test('additional json-to-xml and xml-to-json edge cases', () {
        // validate: true with duplicates: 'use-first'
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": 2}'),
            seq(
              XPathMap({
                const XPathString('validate'): seq(true),
                const XPathString('duplicates'): seq('use-first'),
              }),
            ),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
        );

        // escaped-key attribute on XML element
        final resEscBackslash = fnJsonToXml(context, [
          seq(r'{"\\": 1}'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        check((resEscBackslash.first as XPathNode).node.toXmlString())
            .contains('escaped-key="true"');

        // Trailing comma in object with liberal: true in json-to-xml
        final resObjLib = fnJsonToXml(context, [
          seq('{"a": 1,}'),
          seq(XPathMap({const XPathString('liberal'): seq(true)})),
        ]);
        check(resObjLib.first).isA<XPathNode>();

        // _skipJsonValue syntax errors
        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": '),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
        );

        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": {"k" 2}}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
        );

        final resSkipObjComma = fnJsonToXml(context, [
          seq('{"a": 1, "a": {"k": 2,}}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        check(resSkipObjComma.first).isA<XPathNode>();

        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": {"k": 2 "j": 3}}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
        );

        final resSkipArrComma = fnJsonToXml(context, [
          seq('{"a": 1, "a": [1,]}'),
          seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
        ]);
        check(resSkipArrComma.first).isA<XPathNode>();

        check(
          () => fnJsonToXml(context, [
            seq('{"a": 1, "a": [1 2]}'),
            seq(XPathMap({const XPathString('duplicates'): seq('use-first')})),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0001),
        );

        // Control escape handling with escape: false in json-to-xml
        // xml10Valid == true (\n, \r, \t)
        final resXmlValidControls = fnJsonToXml(context, [
          seq(r'"\n\r\t"'),
          seq(XPathMap({const XPathString('escape'): seq(false)})),
        ]);
        check(resXmlValidControls.first.stringValue).equals('\n\r\t');

        // xml10Valid == false (\b, \f) without fallback produces \uFFFD
        final resXmlInvalidControls = fnJsonToXml(context, [
          seq(r'"\b\f"'),
          seq(XPathMap({const XPathString('escape'): seq(false)})),
        ]);
        check(resXmlInvalidControls.first.stringValue).equals('\uFFFD\uFFFD');

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
        check(resXmlInvalidFallback.first.stringValue).equals('[FB][FB]');

        // options.escape == true and \u0009\u000A\u000D
        final resEscapedTabs = fnJsonToXml(context, [
          seq(r'"\u0009\u000A\u000D"'),
          seq(XPathMap({const XPathString('escape'): seq(true)})),
        ]);
        check((resEscapedTabs.first as XPathNode).node.toXmlString())
            .contains('escaped="true"');

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
        check(resEscRawControls).contains(r'\b');
        check(resEscRawControls).contains(r'\f');
        check(resEscRawControls).contains(r'\n');
        check(resEscRawControls).contains(r'\r');
        check(resEscRawControls).contains(r'\t');
        check(resEscRawControls).contains(r'\u0001');
        check(resEscRawControls).contains(r'\u0085');

        // _unescapeJsonString regular character before escape
        final docUnescapeChar = XmlDocument.parse(r'''
          <map xmlns="http://www.w3.org/2005/xpath-functions">
            <number key='prefix\"' escaped-key="true">42</number>
          </map>
        ''');
        final resUnescapeChar = fnXmlToJson(context, [
          seq(docUnescapeChar),
        ]).first.stringValue;
        check(resUnescapeChar).contains('prefix');
      });
    });
  });
}
