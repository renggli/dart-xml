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
          seq(XPathMap({XPathString('duplicates'): seq('reject')})),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('options duplicates use-last', () {
      final result = fnParseJson(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({XPathString('duplicates'): seq('use-last')})),
      ]);
      expect(
        (result.first as XPathMap).get(XPathString('a')),
        isXPathSequence([2]),
      );
    });
    test('options liberal', () {
      final result = fnParseJson(context, [
        seq('{"a": 1,}'),
        seq(XPathMap({XPathString('liberal'): seq(true)})),
      ]);
      expect(
        (result.first as XPathMap).get(XPathString('a')),
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
          XPathMap({XPathString('fallback'): XPathSequence.single(fallbackFn)}),
        ),
      ]);
      expect(result, isXPathSequence(['?']));
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
    test('options duplicates', () {
      final result = fnJsonToXml(context, [
        seq('{"a": 1, "a": 2}'),
        seq(XPathMap({XPathString('duplicates'): seq('use-first')})),
      ]);
      final doc = (result.single as XPathNode).node as XmlDocument;
      expect(doc.findAllElements('number').length, 1);
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
        seq(XPathMap({XPathString('indent'): seq(true)})),
      ]);
      expect(result, isXPathSequence(['{\n  "a" : 1\n}']));
    });
    test('escaped text', () {
      const input =
          '<string xmlns="http://www.w3.org/2005/xpath-functions" escaped="true">\\u0041</string>';
      final document = XmlDocument.parse(input);
      final result = fnXmlToJson(context, [seq(document)]);
      expect(result, isXPathSequence([r'"\u0041"']));
    });
  });
}
