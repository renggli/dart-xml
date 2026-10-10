import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/exceptions/parser_exception.dart';

void main() {
  group('XPathParserException', () {
    test('message only', () {
      final exception = XPathParserException('message');
      check(exception.message).equals('message');
      check(exception.buffer).isNull();
      check(exception.position).isNull();
      check(exception.toString()).equals('XPathParserException: message');
    });
    test('with buffer and position', () {
      final exception = XPathParserException(
        'message',
        buffer: 'buffer',
        position: 0,
      );
      check(exception.message).equals('message');
      check(exception.buffer).equals('buffer');
      check(exception.position).equals(0);
      check(exception.toString()).startsWith('XPathParserException: message');
    });
  });
}
