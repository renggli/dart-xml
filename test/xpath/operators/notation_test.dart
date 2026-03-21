import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/notation.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opNotationEqual', () {
    test('equal', () {
      expect(
        opNotationEqual(
          const XPathSequence.single('foo:bar'),
          const XPathSequence.single('foo:bar'),
        ),
        [true],
      );
    });
  });
}
