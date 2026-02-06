import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  test('cast from date time', () {
    final dateTime = DateTime.now();
    expect(dateTime.toXPathDateTime(), dateTime);
  });
  test('cast from string', () {
    final dateTime = DateTime.parse('2021-01-01T00:00:00.000');
    expect('2021-01-01T00:00:00.000'.toXPathDateTime(), dateTime);
    expect(
      () => 'invalid'.toXPathDateTime(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('cast from sequence', () {
    final dateTime = DateTime.now();
    expect(XPathSequence.single(dateTime).toXPathDateTime(), dateTime);
    expect(
      () => XPathSequence.empty.toXPathDateTime(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('cast from other', () {
    expect(
      () => 123.toXPathDateTime(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
}
