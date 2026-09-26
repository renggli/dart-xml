import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
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
      expect(
        () => xml.xpathEvaluate('1.0 to 3.0'),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('multi-item operand throws XPTY0004', () {
      expect(
        () => xml.xpathEvaluate('(1, 2) to 3'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains(
              'Range expression operands must be single integer items',
            ),
          ),
        ),
      );
    });
    test('untypedAtomic operands', () {
      expectEvaluate(xml, 'xs:untypedAtomic("1") to 3', [1, 2, 3]);
      expect(
        () => xml.xpathEvaluate('xs:untypedAtomic("abc") to 3'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.FORG0001,
            message: contains(
              'Cannot convert untypedAtomic "abc" to xs:integer',
            ),
          ),
        ),
      );
    });
    test('exceeds size limit', () {
      expect(
        () => xml.xpathEvaluate('1 to 10000002'),
        throwsA(
          isXPathEvaluationException(
            message: contains('Sequence size limit exceeded'),
          ),
        ),
      );
    });
  });
}
