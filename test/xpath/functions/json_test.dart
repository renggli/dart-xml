import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/json.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:parse-json', () {
    test('null', () {
      expect(
        fnParseJson(context, [const XPathSequence.single('null')]),
        isXPathSequence(isEmpty),
      );
    });
    test('boolean', () {
      expect(
        fnParseJson(context, [const XPathSequence.single('true')]),
        isXPathSequence([true]),
      );
      expect(
        fnParseJson(context, [const XPathSequence.single('false')]),
        isXPathSequence([false]),
      );
    });
    test('number', () {
      expect(
        fnParseJson(context, [const XPathSequence.single('123')]),
        isXPathSequence([123.0]),
      );
      expect(
        fnParseJson(context, [const XPathSequence.single('12.34')]),
        isXPathSequence([12.34]),
      );
    });
    test('string', () {
      expect(
        fnParseJson(context, [const XPathSequence.single('"abc"')]),
        isXPathSequence(['abc']),
      );
    });
    test('array', () {
      final result = fnParseJson(context, [
        const XPathSequence.single('[1, 2]'),
      ]);
      expect(result.length, 1);
      final array = result.first as List;
      expect(array, [1.0, 2.0]);
    });
    test('map', () {
      final result = fnParseJson(context, [
        const XPathSequence.single('{"a": 1}'),
      ]);
      expect(result.length, 1);
      final map = result.first as Map;
      expect(map, {'a': 1.0});
    });
    test('invalid', () {
      expect(
        () => fnParseJson(context, [const XPathSequence.single('{')]),
        throwsA(isA<Exception>()),
      );
    });
    test('empty', () {
      expect(
        fnParseJson(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
  group('fn:json-doc', () {
    test('unimplemented', () {
      expect(
        () => fnJsonDoc(context, [const XPathSequence.single('url')]),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnJsonDoc(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
  group('fn:json-to-xml', () {
    test('basic', () {
      const input = '{"a": 1, "b": [null, true, 2, "c"]}';
      final result = fnJsonToXml(context, [const XPathSequence.single(input)]);
      expect(
        (result.single as XmlDocument).toXmlString(),
        '<?xml version="1.0"?>'
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
        () => fnJsonToXml(context, [const XPathSequence.single('{')]),
        throwsA(isXPathEvaluationException()),
      );
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
      final result = fnXmlToJson(context, [XPathSequence.single(document)]);
      expect(result.single, '{"a":1,"b":[null,true,2,"c"]}');
    });
    test('empty', () {
      expect(
        fnXmlToJson(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
}
