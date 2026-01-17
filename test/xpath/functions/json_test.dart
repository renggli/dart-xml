import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/json.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('json', () {
    test('fn:parse-json', () {
      expect(
        () => fnParseJson(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:json-doc', () {
      expect(
        () => fnJsonDoc(context, [const XPathSequence.single('url')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:json-to-xml', () {
      expect(
        () => fnJsonToXml(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:xml-to-json', () {
      expect(
        () => fnXmlToJson(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
