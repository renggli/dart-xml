import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

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
      check(() => xml.xpathEvaluate('1.0 to 3.0'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
    test('multi-item operand throws XPTY0004', () {
      check(() => xml.xpathEvaluate('(1, 2) to 3'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.XPTY0004,
              message: 'Range expression operands must be single integer items',
            ),
          );
    });
    test('untypedAtomic operands', () {
      expectEvaluate(xml, 'xs:untypedAtomic("1") to 3', [1, 2, 3]);
      check(() => xml.xpathEvaluate('xs:untypedAtomic("abc") to 3'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.FORG0001,
              message: 'Cannot convert untypedAtomic "abc" to xs:integer',
            ),
          );
    });
    test('exceeds size limit', () {
      check(() => xml.xpathEvaluate('1 to 10000002'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Sequence size limit exceeded'),
          );
    });
  });
}
