import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/notation.dart';
import 'package:xml/xpath.dart';

void main() {
  test('op:NOTATION-equal', () {
    expect(
      opNotationEqual(
        const XPathSequence.single('foo:bar'),
        const XPathSequence.single('foo:bar'),
      ),
      [true],
    );
  });
}
