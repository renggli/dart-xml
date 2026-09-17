import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/functions/function.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/xml.dart';

import '../../../utils/matchers.dart';

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
      expect(f.name, const XmlName.qualified('my:fn'));
      expect(f.arity, equals(2));
      expect(
        f(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ]),
        isXPathSequence([2]),
      );
    });

    test('toXPathFunction extension on Function', () {
      XPathSequence custom(XPathContext ctx, List<XPathSequence> args) =>
          const XPathSequence.single(XPathString('success'));

      final f = custom.toXPathFunction(
        name: const XmlName.qualified('test:custom'),
        arity: 0,
      );
      expect(f.name, const XmlName.qualified('test:custom'));
      expect(f.arity, equals(0));
      expect(f(context, []), isXPathSequence(['success']));
    });
  });
}
