import 'package:test/test.dart';
import 'package:xml/src/xpath/expressions/axis.dart';
import 'package:xml/src/xpath/expressions/name.dart';
import 'package:xml/src/xpath/expressions/step.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  group('reverse axis predicate evaluation order', () {
    const input = '<root><a id="1"/><b id="2"/><c id="3"/><d id="4"/></root>';
    final doc = XmlDocument.parse(input);
    final d = doc.findAllElements('d').single;

    test('preceding-sibling with single positional predicate', () {
      expectXPath(d, 'preceding-sibling::*[1]', ['<c id="3"/>']);
      expectXPath(d, 'preceding-sibling::*[2]', ['<b id="2"/>']);
      expectXPath(d, 'preceding-sibling::*[3]', ['<a id="1"/>']);
    });

    test('preceding-sibling with multiple predicates', () {
      expectXPath(d, 'preceding-sibling::*[position() < 3][1]', [
        '<c id="3"/>',
      ]);
      expectXPath(d, 'preceding-sibling::*[position() < 3][2]', [
        '<b id="2"/>',
      ]);
      expectXPath(d, 'preceding-sibling::*[1][1]', ['<c id="3"/>']);
    });

    test('ancestor with multiple predicates', () {
      const nested = '<top><mid><leaf/></mid></top>';
      final docNested = XmlDocument.parse(nested);
      final leaf = docNested.findAllElements('leaf').single;
      expectXPath(leaf, 'ancestor::*[1]', ['<mid><leaf/></mid>']);
      expectXPath(leaf, 'ancestor::*[2]', ['<top><mid><leaf/></mid></top>']);
      expectXPath(leaf, 'ancestor::*[1][1]', ['<mid><leaf/></mid>']);
      expectXPath(leaf, 'ancestor::*[position() <= 2][2]', [
        '<top><mid><leaf/></mid></top>',
      ]);
    });
  });

  group('missing context item error (XPDY0002)', () {
    final emptyContext = const XPathConfiguration.raw().context();

    test('StepExpression throws XPDY0002 when context item is absent', () {
      const step = StepExpression(ChildAxis(), nodeTest: NodeNameTest());
      expect(
        () => step(emptyContext),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPDY0002)),
      );
    });

    test('RootNodeExpression throws XPDY0002 when context item is absent', () {
      const rootStep = RootNodeExpression();
      expect(
        () => rootStep(emptyContext),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPDY0002)),
      );
    });
  });

  group('non-node context item error (XPTY0019)', () {
    test('step throws XPTY0019 when context item is not a node', () {
      final intContext = const XPathConfiguration.raw().context(42);
      const step = StepExpression(ChildAxis(), nodeTest: NodeNameTest());
      expect(
        () => step(intContext),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0019)),
      );
    });

    test('root throws XPTY0019 when context item is not a node', () {
      final intContext = const XPathConfiguration.raw().context(42);
      const rootStep = RootNodeExpression();
      expect(
        () => rootStep(intContext),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0019)),
      );
    });
  });
}
