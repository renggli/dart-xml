import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathFunction', () {
    test('construction and invocation', () {
      final f = XPathFunction(
        name: const XmlName.qualified('my:fn'),
        arity: 2,
        function: (ctx, args) =>
            XPathSequence.single(XPathInteger.fromInt(args.length)),
      );
      check(f.name).equals(const XmlName.qualified('my:fn'));
      check(f.arity).equals(2);
      check(
        f(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ]),
      ).isXPathSequence([2]);
    });

    test('toXPathFunction extension on Function', () {
      XPathSequence custom(XPathContext ctx, List<XPathSequence> args) =>
          const XPathSequence.single(XPathString('success'));

      final f = custom.toXPathFunction(
        name: const XmlName.qualified('test:custom'),
        arity: 0,
      );
      check(f.name).equals(const XmlName.qualified('test:custom'));
      check(f.arity).equals(0);
      check(f(context, [])).isXPathSequence(['success']);
    });
  });
}
