import 'package:test/test.dart';
import 'package:xml/xpath.dart';

void main() {
  group('XPathEvaluationException', () {
    test('without details', () {
      final exception = XPathEvaluationException(XPathErrorCode.FOAR0001);
      expect(exception.errorCode, XPathErrorCode.FOAR0001);
      expect(exception.details, isNull);
      expect(exception.message, 'Division by zero [err:FOAR0001]');
      expect(
        exception.toString(),
        'XPathEvaluationException: Division by zero [err:FOAR0001]',
      );
    });

    test('with details', () {
      final exception = XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot compare a and b',
      );
      expect(exception.errorCode, XPathErrorCode.XPTY0004);
      expect(exception.details, 'Cannot compare a and b');
      expect(exception.message, 'Cannot compare a and b [err:XPTY0004]');
      expect(
        exception.toString(),
        'XPathEvaluationException: Cannot compare a and b [err:XPTY0004]',
      );
    });
  });
}
