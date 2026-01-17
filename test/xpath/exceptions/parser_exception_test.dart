import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/parser_exception.dart';

void main() {
  group('XPathParserException', () {
    test('message only', () {
      final exception = XPathParserException('message');
      expect(exception.message, 'message');
      expect(exception.buffer, isNull);
      expect(exception.position, isNull);
      expect(exception.toString(), 'XPathParserException: message');
    });
    test('with buffer and position', () {
      final exception = XPathParserException(
        'message',
        buffer: 'buffer',
        position: 0,
      );
      expect(exception.message, 'message');
      expect(exception.buffer, 'buffer');
      expect(exception.position, 0);
      expect(exception.toString(), startsWith('XPathParserException: message'));
    });
  });
}
