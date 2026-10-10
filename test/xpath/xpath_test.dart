import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/checks.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b><c>3</c></r>');
void main() {
  group('xpath', () {
    test('returns matching nodes', () {
      final results = document.xpath('/r/a');
      check(results).deepEquals([document.findAllElements('a').first]);
    });
    test('returns empty iterable when nothing matches', () {
      final results = document.xpath('/r/d');
      check(results).isEmpty();
    });
    test('supports custom configuration', () {
      final config = XPathConfiguration(variables: {'target': 'b'});
      final results = document.xpath(
        r'/r/*[local-name() = $target]',
        configuration: config,
      );
      check(results).deepEquals([document.findAllElements('b').first]);
    });
    test('supports deprecated variables argument', () {
      // ignore: deprecated_member_use_from_same_package
      final results = document.xpath(
        r'/r/*[local-name() = $target]',
        variables: {'target': 'c'},
      );
      check(results).deepEquals([document.findAllElements('c').first]);
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
            final node = (args[0].first as XPathNode).node;
            return XPathSequence.single(
              XPathBoolean(node is XmlElement && node.name.local == 'c'),
            );
          }).toXPathFunction(arity: 1),
        },
        configuration: XPathConfiguration(namespaceUris: {'custom': 'custom'}),
      );
      check(results).deepEquals([document.findAllElements('c').first]);
    });
  });
  group('xpathEvaluate', () {
    test('returns XPathSequence of nodes', () {
      final results = document.xpathEvaluate('/r/a');
      check(results).isXPathSequence([document.findAllElements('a').first]);
    });
    test('returns empty sequence when nothing matches', () {
      final results = document.xpathEvaluate('/r/d');
      check(results).isXPathSequence(isEmpty);
    });
    test('returns primitive values', () {
      check(document.xpathEvaluate('1 + 2')).isXPathSequence([3]);
      check(document.xpathEvaluate('count(/r/*)')).isXPathSequence([3]);
      check(document.xpathEvaluate('local-name(/r/a)')).isXPathSequence(['a']);
      check(document.xpathEvaluate('boolean(/r/a)')).isXPathSequence([true]);
    });
    test('supports custom configuration', () {
      final config = XPathConfiguration(variables: {'val': 10});
      check(document.xpathEvaluate(r'$val * 2', configuration: config))
          .isXPathSequence([20]);
    });
    test('supports deprecated variables argument', () {
      // ignore: deprecated_member_use_from_same_package
      check(document.xpathEvaluate(r'$val * 2', variables: {'val': 15}))
          .isXPathSequence([30]);
    });
    test('supports deprecated functions argument', () {
      // ignore: deprecated_member_use_from_same_package
      check(
        document.xpathEvaluate(
          'custom:double(5)',
          functions: {
            const XmlName.parts(
              'double',
              namespaceUri: 'custom',
            ): ((XPathContext context, List<XPathSequence> args) {
              final val = (args[0].first as XPathNumeric).toDouble();
              return XPathSequence.from([val * 2]);
            }).toXPathFunction(arity: 1),
          },
          configuration: XPathConfiguration(
            namespaceUris: {'custom': 'custom'},
          ),
        ),
      ).isXPathSequence([10]);
    });
  });
}
