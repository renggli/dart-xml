import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/duration.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('duration', () {
    test('cast from duration', () {
      const duration = Duration(seconds: 1);
      expect(duration.toXPathDuration(), duration);
    });
    test('cast from string', () {
      expect(() => 'P1Y'.toXPathDuration(), throwsA(isA<UnimplementedError>()));
    });
    test('cast from sequence', () {
      const duration = Duration(seconds: 1);
      expect(const XPathSequence.single(duration).toXPathDuration(), duration);
      expect(
        () => XPathSequence.empty.toXPathDuration(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(
        () => 123.toXPathDuration(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
