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
          const Step(DescendantOrSelfAxis()),
          Step(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ], isAbsolute: true);
        expect(path.steps, hasLength(1));
        final actualStep = path.steps.single;
        expect(actualStep.axis.runtimeType, newAxis.runtimeType);
        expect(actualStep.nodeTest, const QualifiedNameTest('x'));
        expect(actualStep.predicates, isEmpty);
      }
      {
        // Incompatible initial step.
        final path = PathExpression([
          const Step(SelfAxis()),
          Step(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ], isAbsolute: true);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible node test.
        final path = PathExpression([
          const Step(DescendantOrSelfAxis(), nodeTest: CommentTypeTest()),
          Step(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ], isAbsolute: true);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible predicate.
        final path = PathExpression([
          const Step(DescendantOrSelfAxis()),
          Step(
            stepAxis,
            nodeTest: const QualifiedNameTest('x'),
            predicates: const [
              Predicate(LiteralExpression(XPathSequence.single(1))),
            ],
          ),
        ], isAbsolute: true);
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
          Step(AncestorOrSelfAxis()),
        ], isAbsolute: true).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          Step(AncestorOrSelfAxis()),
          Step(SelfAxis()),
          Step(SelfAxis()),
          Step(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ], isAbsolute: true).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          Step(AncestorOrSelfAxis()),
          Step(DescendantAxis()),
        ], isAbsolute: true).isOrderPreserved,
        isFalse,
      );
    });
    test(
      '(selfStep | childStep)+ (descendantStep | descendantOrSelfStep)? (selfStep | attributeStep)*',
      () {
        expect(
          PathExpression(const [
            Step(ChildAxis()),
            Step(ChildAxis()),
            Step(SelfAxis()),
            Step(DescendantAxis()),
            Step(SelfAxis()),
            Step(SelfAxis()),
            Step(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ], isAbsolute: false).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            Step(ChildAxis()),
            Step(ChildAxis()),
            Step(SelfAxis()),
            Step(SelfAxis()),
            Step(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ], isAbsolute: false).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            Step(ChildAxis()),
            Step(ChildAxis()),
            Step(SelfAxis()),
            Step(DescendantOrSelfAxis()),
            Step(SelfAxis()),
            Step(SelfAxis()),
            Step(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ], isAbsolute: false).isOrderPreserved,
          isTrue,
        );
        expect(
          PathExpression(const [
            Step(ChildAxis()),
            Step(ChildAxis()),
            Step(SelfAxis()),
            Step(ParentAxis()),
            Step(SelfAxis()),
            Step(SelfAxis()),
            Step(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
          ], isAbsolute: false).isOrderPreserved,
          isFalse,
        );
      },
    );
  });
}
