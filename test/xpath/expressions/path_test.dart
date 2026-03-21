import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/expressions/axis.dart';
import 'package:xml/src/xpath/expressions/name.dart';
import 'package:xml/src/xpath/expressions/node.dart';
import 'package:xml/src/xpath/expressions/path.dart';
import 'package:xml/src/xpath/expressions/predicate.dart';
import 'package:xml/src/xpath/expressions/step.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  group('step optimization', () {
    void expectOptimized(Axis stepAxis, Axis newAxis) {
      {
        // Applies optimization.
        final path = PathExpression([
          const StepExpression(DescendantOrSelfAxis()),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(1));
        final actualStep = path.steps.single as StepExpression;
        expect(actualStep.axis.runtimeType, newAxis.runtimeType);
        expect(actualStep.nodeTest, const QualifiedNameTest('x'));
        expect(actualStep.predicates, isEmpty);
      }
      {
        // Incompatible initial step.
        final path = PathExpression([
          const StepExpression(SelfAxis()),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible node test.
        final path = PathExpression([
          const StepExpression(
            DescendantOrSelfAxis(),
            nodeTest: CommentTypeTest(),
          ),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible predicate.
        final path = PathExpression([
          const StepExpression(DescendantOrSelfAxis()),
          StepExpression(
            stepAxis,
            nodeTest: const QualifiedNameTest('x'),
            predicates: const [
              Predicate(LiteralExpression(XPathSequence.single(1))),
            ],
          ),
        ]);
        expect(path.steps, hasLength(2));
      }
    }

    test(
      '//child::x => descendant::x',
      () => expectOptimized(const ChildAxis(), const DescendantAxis()),
    );
    test(
      '//self::x => descendant-or-self::x',
      () => expectOptimized(const SelfAxis(), const DescendantOrSelfAxis()),
    );
    test(
      '//descendant::x => descendant::x',
      () => expectOptimized(const DescendantAxis(), const DescendantAxis()),
    );
    test(
      '//descendant-or-self::x => descendant-or-self::x',
      () => expectOptimized(
        const DescendantOrSelfAxis(),
        const DescendantOrSelfAxis(),
      ),
    );
  });
  group('order preservation', () {
    test('anyStep (selfStep | attributeStep)*', () {
      expect(
        PathExpression(const [
          StepExpression(AncestorOrSelfAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(AncestorOrSelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(AncestorOrSelfAxis()),
          StepExpression(DescendantAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
    });
    test(
      '(selfStep | childStep)+ (descendantStep | descendantOrSelfStep)? (selfStep | attributeStep)*',
      () {
        expect(
          PathExpression(const [
            StepExpression(ChildAxis()),
            StepExpression(ChildAxis()),
            StepExpression(SelfAxis()),
            StepExpression(DescendantAxis()),
            StepExpression(SelfAxis()),
            StepExpression(SelfAxis()),
            StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ]).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            StepExpression(ChildAxis()),
            StepExpression(ChildAxis()),
            StepExpression(SelfAxis()),
            StepExpression(SelfAxis()),
            StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ]).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            StepExpression(ChildAxis()),
            StepExpression(ChildAxis()),
            StepExpression(SelfAxis()),
            StepExpression(DescendantOrSelfAxis()),
            StepExpression(SelfAxis()),
            StepExpression(SelfAxis()),
            StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ]).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            StepExpression(ChildAxis()),
            StepExpression(ChildAxis()),
            StepExpression(SelfAxis()),
            StepExpression(ParentAxis()),
            StepExpression(SelfAxis()),
            StepExpression(SelfAxis()),
            StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ]).isOrderPreserved,
          isFalse,
        );
      },
    );
  });

  group('evaluation edge cases', () {
    final context = XPathContext.canonical(XmlDocument.parse('<root/>'));
    test('empty steps throw ArgumentError', () {
      expect(() => PathExpression([]), throwsArgumentError);
    });
    test(
      'non-node items on path step without order preserved throws Exception',
      () {
        final path = PathExpression([
          const LiteralExpression(XPathSequence.single('text')),
          const StepExpression(ChildAxis()),
        ]);
        expect(path.isOrderPreserved, isFalse);
        expect(
          () => path(context),
          throwsA(
            isXPathEvaluationException(
              message:
                  'Path operator / requires sequence of nodes, but got text',
            ),
          ),
        );
      },
    );
    test('sort and deduplicate with non-nodes', () {
      final xml = XmlDocument.parse('<root><a><b/></a></root>');
      final path = PathExpression([
        const StepExpression(AncestorAxis()),
        const LiteralExpression(XPathSequence.single(1)),
      ]);
      expect(path.isOrderPreserved, isFalse);
      final evalContext = XPathContext.canonical(
        xml.rootElement.children.first,
      );
      expect(path(evalContext), equals([1]));
    });
    test('sort and deduplicate with large node sets', () {
      final xml = XmlDocument.parse(
        '<root>${List.generate(60, (i) => '<a><b/></a>').join('')}</root>',
      );
      final path = PathExpression([
        const StepExpression(AncestorAxis()),
        const StepExpression(ChildAxis()),
      ]);
      expect(path.isOrderPreserved, isFalse);
      // Evaluate starting at a 'b' node
      final evalContext = XPathContext.canonical(
        xml.findAllElements('b').first,
      );
      final result = path(evalContext);
      expect(result, hasLength(62));
    });
    test('sort and deduplicate with nodes from multiple documents', () {
      final xml1 = XmlDocument.parse(
        '<root>${List.generate(55, (i) => '<a><b/></a>').join('')}</root>',
      );
      final xml2 = XmlDocument.parse('<root2><a/><b/></root2>');
      final path = PathExpression([
        LiteralExpression(
          XPathSequence([
            ...xml1.findAllElements('b'),
            ...xml2.rootElement.children,
          ]),
        ),
        const StepExpression(SelfAxis()),
      ]);
      expect(path.isOrderPreserved, isFalse);
      final result = path(context);
      // Expected to find 55 elements from xml1 + 2 elements from xml2 = 57
      expect(result, hasLength(57));
    });
  });
}
