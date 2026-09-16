import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';

import '../../utils/matchers.dart';

void main() {
  group('Simple Map Operator (!)', () {
    test('1 ! 2', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('1 ! 2'), isXPathSequence([2]));
    });
    test('1 ! .', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(context.evaluate('1 ! .'), isXPathSequence([1]));
    });
    test('(1, 2, 3) ! (. + 1)', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(
        context.evaluate('(1, 2, 3) ! (. + 1)'),
        isXPathSequence([2, 3, 4]),
      );
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
      expect(
        context.evaluate('(1, 2) ! (., .)'),
        isXPathSequence([1, 1, 2, 2]),
      );
    });
    test('position() and last()', () {
      final context = XPathConfiguration().context(XPathSequence.empty);
      expect(
        context.evaluate('(10, 20, 30) ! position()'),
        isXPathSequence([1, 2, 3]),
      );
      expect(
        context.evaluate('(10, 20, 30) ! last()'),
        isXPathSequence([3, 3, 3]),
      );
    });
  });
}
