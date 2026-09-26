import 'package:test/test.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathErrorCode', () {
    test('properties', () {
      const code = XPathErrorCode.XPTY0004;
      expect(code.code, 'XPTY0004');
      expect(code.message, 'Type error');
      expect(code.qname.value.local, 'XPTY0004');
      expect(code.qname.value.prefix, 'err');
      expect(
        code.qname.value.namespaceUri,
        'http://www.w3.org/2005/xqt-errors',
      );
      expect(code.qname.stringValue, 'err:XPTY0004');
    });

    test('format without details', () {
      expect(
        XPathErrorCode.FOAR0001.format(),
        'Division by zero [err:FOAR0001]',
      );
    });

    test('format with details', () {
      expect(
        XPathErrorCode.XPTY0004.format('Custom detail message'),
        'Custom detail message [err:XPTY0004]',
      );
    });

    test('custom namespace qname', () {
      const custom = XPathErrorCode(
        'CUSTOM',
        'Custom message',
        'http://custom',
      );
      expect(custom.qname.value.local, 'CUSTOM');
      expect(custom.qname.value.prefix, isNull);
      expect(custom.qname.value.namespaceUri, 'http://custom');
    });

    test('equality, hashCode and toString', () {
      const c1 = XPathErrorCode('TEST', 'Msg 1', 'http://uri');
      const c2 = XPathErrorCode('TEST', 'Msg 2', 'http://uri');
      const c3 = XPathErrorCode('OTHER', 'Msg 1', 'http://uri');
      expect(c1, equals(c2));
      expect(c1.hashCode, equals(c2.hashCode));
      expect(c1 == c3, isFalse);
      expect(c1 == Object(), isFalse);
      expect(c1.toString(), contains('XPathErrorCode(TEST: Msg 1)'));
    });
  });
}
