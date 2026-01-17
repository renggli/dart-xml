import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('concat', () {
    test('strings', () {
      expectEvaluate(xml, '"a" || "b"', ['ab']);
    });
    test('numbers', () {
      expectEvaluate(xml, '1 || 2', ['12']);
    });
    test('mixed', () {
      expectEvaluate(xml, '"a" || 1 || "b"', ['a1b']);
    });
    test('empty', () {
      expectEvaluate(xml, '"a" || () || "b"', ['ab']);
    });
  });
}
