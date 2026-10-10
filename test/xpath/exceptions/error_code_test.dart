import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathErrorCode', () {
    test('properties', () {
      const code = XPathErrorCode.XPTY0004;
      check(code.code).equals('XPTY0004');
      check(code.message).equals('Type error');
      check(code.qname.value.local).equals('XPTY0004');
      check(code.qname.value.prefix).equals('err');
      check(code.qname.value.namespaceUri)
          .equals('http://www.w3.org/2005/xqt-errors');
      check(code.qname.stringValue).equals('err:XPTY0004');
    });

    test('format without details', () {
      check(XPathErrorCode.FOAR0001.format())
          .equals('Division by zero [err:FOAR0001]');
    });

    test('format with details', () {
      check(XPathErrorCode.XPTY0004.format('Custom detail message'))
          .equals('Custom detail message [err:XPTY0004]');
    });

    test('custom namespace qname', () {
      const custom = XPathErrorCode(
        'CUSTOM',
        'Custom message',
        'http://custom',
      );
      check(custom.qname.value.local).equals('CUSTOM');
      check(custom.qname.value.prefix).isNull();
      check(custom.qname.value.namespaceUri).equals('http://custom');
    });

    test('equality, hashCode and toString', () {
      const c1 = XPathErrorCode('TEST', 'Msg 1', 'http://uri');
      const c2 = XPathErrorCode('TEST', 'Msg 2', 'http://uri');
      const c3 = XPathErrorCode('OTHER', 'Msg 1', 'http://uri');
      check(c1).equals(c2);
      check(c1.hashCode).equals(c2.hashCode);
      check(c1 == c3).isFalse();
      check(c1 == Object()).isFalse();
      check(c1.toString()).contains('XPathErrorCode(TEST: Msg 1)');
    });
  });
}
