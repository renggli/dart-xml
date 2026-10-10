import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/notation.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opNotationEqual', () {
    test('equal', () {
      check(
        opNotationEqual(
          const XPathSequence.single(XPathString('foo:bar')),
          const XPathSequence.single(XPathString('foo:bar')),
        ),
      ).equals(XPathSequence.trueSequence);
    });
  });
}
