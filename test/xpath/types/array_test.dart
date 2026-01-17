import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/array.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  test('cast from array', () {
    final array = [1, 2, 3];
    expect(array.toXPathArray(), array);
  });
  test('cast from sequence', () {
    expect(const XPathSequence.single([1, 2]).toXPathArray(), [1, 2]);
    expect(
      () => XPathSequence.empty.toXPathArray(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('cast from other', () {
    expect(() => 123.toXPathArray(), throwsA(isA<XPathEvaluationException>()));
  });
}
