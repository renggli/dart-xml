import 'package:test/test.dart';
import 'package:xml/src/xpath/expressions/axis.dart';
import 'package:xml/src/xpath/expressions/name.dart';
import 'package:xml/src/xpath/expressions/node.dart';
import 'package:xml/src/xpath/expressions/path.dart';
import 'package:xml/src/xpath/expressions/predicate.dart';
import 'package:xml/src/xpath/expressions/step.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/types/sequence.dart';

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
}
