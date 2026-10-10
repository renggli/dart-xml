import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathEvaluationException', () {
    test('without details', () {
      final exception = XPathEvaluationException(XPathErrorCode.FOAR0001);
      check(exception.errorCode).equals(XPathErrorCode.FOAR0001);
      check(exception.details).isNull();
      check(exception.message).equals('Division by zero [err:FOAR0001]');
      check(exception.toString())
          .equals('XPathEvaluationException: Division by zero [err:FOAR0001]');
    });

    test('with details', () {
      final exception = XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot compare a and b',
      );
      check(exception.errorCode).equals(XPathErrorCode.XPTY0004);
      check(exception.details).equals('Cannot compare a and b');
      check(exception.message).equals('Cannot compare a and b [err:XPTY0004]');
      check(exception.toString()).equals(
        'XPathEvaluationException: Cannot compare a and b [err:XPTY0004]',
      );
    });
  });
}
