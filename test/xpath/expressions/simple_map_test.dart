import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/values/sequence.dart';

void main() {
  group('Simple Map Operator (!)', () {
    test('1 ! 2', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('1 ! 2'), equals([2]));
    });
    test('1 ! .', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('1 ! .'), equals([1]));
    });
    test('(1, 2, 3) ! (. + 1)', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('(1, 2, 3) ! (. + 1)'), equals([2, 3, 4]));
    });
    test('() ! 1', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('() ! 1'), isEmpty);
    });
    test('1 ! ()', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('1 ! ()'), isEmpty);
    });
    test('(1, 2) ! (., .)', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('(1, 2) ! (., .)'), equals([1, 1, 2, 2]));
    });
    test('position() and last()', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('(10, 20, 30) ! position()'), equals([1, 2, 3]));
      expect(context.evaluate('(10, 20, 30) ! last()'), equals([3, 3, 3]));
    });
  });
}
