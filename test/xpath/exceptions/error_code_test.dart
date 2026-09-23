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
  });
}
