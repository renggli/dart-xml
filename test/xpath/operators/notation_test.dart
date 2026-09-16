import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/notation.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opNotationEqual', () {
    test('equal', () {
      expect(
        opNotationEqual(
          const XPathSequence.single(XPathString('foo:bar')),
          const XPathSequence.single(XPathString('foo:bar')),
        ),
        XPathSequence.trueSequence,
      );
    });
  });
}
