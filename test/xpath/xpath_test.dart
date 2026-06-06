import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
void main() {
  group('xpath', () {
    test('returns matching nodes', () {
      final results = document.xpath('/r/a');
      expect(results, [document.findAllElements('a').first]);
    });
    test('returns empty iterable when nothing matches', () {
      final results = document.xpath('/r/d');
      expect(results, isEmpty);
    });
    test('supports custom configuration', () {
      final config = XPathConfiguration(variables: {'target': 'b'});
      final results = document.xpath(
        r'/r/*[local-name() = $target]',
        configuration: config,
      );
      expect(results, [document.findAllElements('b').first]);
    });
    test('supports deprecated variables argument', () {
      // ignore: deprecated_member_use_from_same_package
      final results = document.xpath(
        r'/r/*[local-name() = $target]',
        variables: {'target': 'c'},
      );
      expect(results, [document.findAllElements('c').first]);
    });
    test('supports deprecated functions argument', () {
      // ignore: deprecated_member_use_from_same_package
      final results = document.xpath(
        r'/r/*[custom:is-c(.)]',
        functions: {
          const XmlName.parts(
            'is-c',
            namespaceUri: 'custom',
          ): ((XPathContext context, List<XPathSequence> args) {
            final node = args[0].first as XmlNode;
            return XPathSequence.single(
              node is XmlElement && node.name.local == 'c',
            );
          }).toXPathFunction(arity: 1),
        },
        configuration: XPathConfiguration(namespaceUris: {'custom': 'custom'}),
      );
      expect(results, [document.findAllElements('c').first]);
    });
  });
  group('xpathEvaluate', () {
    test('returns XPathSequence of nodes', () {
      final results = document.xpathEvaluate('/r/a');
      expect(results, isXPathSequence([document.findAllElements('a').first]));
    });
    test('returns empty sequence when nothing matches', () {
      final results = document.xpathEvaluate('/r/d');
      expect(results, isXPathSequence(isEmpty));
    });
    test('returns primitive values', () {
      expect(document.xpathEvaluate('1 + 2'), isXPathSequence([3]));
      expect(document.xpathEvaluate('count(/r/*)'), isXPathSequence([3]));
      expect(
        document.xpathEvaluate('local-name(/r/a)'),
        isXPathSequence(['a']),
      );
      expect(document.xpathEvaluate('boolean(/r/a)'), isXPathSequence([true]));
    });
    test('supports custom configuration', () {
      final config = XPathConfiguration(variables: {'val': 10});
      expect(
        document.xpathEvaluate(r'$val * 2', configuration: config),
        isXPathSequence([20]),
      );
    });
    test('supports deprecated variables argument', () {
      // ignore: deprecated_member_use_from_same_package
      expect(
        document.xpathEvaluate(r'$val * 2', variables: {'val': 15}),
        isXPathSequence([30]),
      );
    });
    test('supports deprecated functions argument', () {
      // ignore: deprecated_member_use_from_same_package
      expect(
        document.xpathEvaluate(
          'custom:double(5)',
          functions: {
            const XmlName.parts(
              'double',
              namespaceUri: 'custom',
            ): ((XPathContext context, List<XPathSequence> args) {
              final val = args[0].first as num;
              return XPathSequence.single(val * 2);
            }).toXPathFunction(arity: 1),
          },
          configuration: XPathConfiguration(
            namespaceUris: {'custom': 'custom'},
          ),
        ),
        isXPathSequence([10]),
      );
    });
  });
}
