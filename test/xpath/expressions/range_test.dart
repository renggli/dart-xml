import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('range', () {
    test('1 to 3', () {
      expectEvaluate(xml, '1 to 3', [1, 2, 3]);
    });
    test('1 to 1', () {
      expectEvaluate(xml, '1 to 1', [1]);
    });
    test('3 to 1', () {
      expectEvaluate(xml, '3 to 1', isEmpty);
    });
    test('empty operand', () {
      expectEvaluate(xml, '() to 1', isEmpty);
      expectEvaluate(xml, '1 to ()', isEmpty);
    });
    test('double operand', () {
      expectEvaluate(xml, '1.0 to 3.0', [1, 2, 3]);
    });
  });
}
