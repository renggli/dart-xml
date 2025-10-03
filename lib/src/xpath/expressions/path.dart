import '../../xml/extensions/parent.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import 'axis.dart';
import 'node_test.dart';
import 'step.dart';

class PathExpression implements XPathExpression {
  factory PathExpression(List<Step> steps, {required bool isAbsolute}) {
    if (steps.isEmpty) {
      assert(isAbsolute);
      return const PathExpression._(
        [],
        isAbsolute: true,
        isOrderPreserved: true,
      );
    }
    final optimizedSteps = <Step>[steps.first];
    for (final step in steps.skip(1)) {
      Step? merged;
      final last = optimizedSteps.last;
      if (last.axis is DescendantOrSelfAxis &&
          last.nodeTest is NodeTypeNodeTest &&
          last.predicates.isEmpty &&
          step.predicates.isEmpty) {
        // Try to merge the '//' step with the next step:
        // The next step must not have any predicates,
        // because the predicates might depend on the `position` of the context node
        // and we cannot guarantee the `position` is still preserved after merging.
        switch (step.axis) {
          // child::x => descendant::x
          case ChildAxis():
            merged = Step(
              const DescendantAxis(),
              step.nodeTest,
              step.predicates,
            );
          // self::x => descendant-or-self::x
          case SelfAxis():
            merged = Step(
              const DescendantOrSelfAxis(),
              step.nodeTest,
              step.predicates,
            );
          // descendant::x => descendant::x
          case DescendantAxis():
          // descendant-or-self::x => descendant-or-self::x
          case DescendantOrSelfAxis():
            merged = step;
          default:
        }
      }
      if (merged != null) {
        optimizedSteps.removeLast();
        optimizedSteps.add(merged);
      } else {
        optimizedSteps.add(step);
      }
    }

    // The resulting nodes' document order and uniqueness is preserved,
    // if the steps match the following patterns:
    //
    // 1. anyStep (selfStep | attributeStep)*
    // 2. (selfStep | childStep)+ (descendantStep | descendantOrSelfStep)? (selfStep | attributeStep)*
    //
    // Proof:
    //
    // Suppose we have node-set S_prev which is the result of the previous step and it's in document order.
    // And we are going to apply step f to it, where f is at least the second step obviously, then we get node-set S_next = f(S_prev).
    //
    // For any node pair i, j in S_next, where i comes before j in S_next, we need to prove that i comes before j in document order (1).
    //
    // Let's denote any nodes in S_prev that generate i and j as i' and j' respectively.
    // If i' = j', then i comes before j in document order because step f is a forward step, so (1) is true.
    // So we only need to discuss the case where **i' != j'**.
    //
    // To prove (1), we need to prove that:
    // - i' comes not after j' in S_prev (2)
    // - all nodes in f(i') come before all nodes in f(j') in document order (3).
    //
    // If i' comes after j' and we still get i before j in S_next, that means both f(i') and f(j') will produce i (4).
    // To prove (2), we just need to prove that (4) is impossible.
    //
    // Let's discuss each pattern:
    //
    // **Pattern 1**
    // Step f can only be selfStep or attributeStep.
    // For such step f, f(i') and f(j') cannot produce the same node i, so (4) is impossible and (2) is true.
    // Now that i' comes before j' in S_prev, we have:
    // - If f is selfStep, then i = i' and j = j', so (3) is true.
    // - If f is attributeStep, then all attributes of i' must come before all attributes of j' in document order, so (3) is true.
    //
    // **Pattern 2**
    // We only need to discuss a simpler form of pattern2:
    // - (selfStep | childStep)+ (descendantStep | descendantOrSelfStep)?
    // Because if this simpler form will produce nodes in document order, then these steps can be viewed as a single complex step.
    // Adding `(selfStep | attributeStep)*` after it is the same as pattern 1, which has been proved.
    // So step f can be selfStep, childStep, descendantStep, or descendantOrSelfStep.
    // For selfStep, the proof is the same as pattern 1.
    // And after all the steps before f, the resulting nodes have the same depth, which means j' cannot be the descendant of i' and vice versa (5).
    // For descendantOrSelfStep:
    // - Because of (5), f(i') and f(j') cannot produce the same node i, so (4) is impossible and (2) is true.
    // - Because of (2) and (5), all nodes in f(i') must come before all nodes in f(j') in document order, so (3) is true.
    // Same proof applies to descendantStep and childStep.
    //
    // So for all the patterns, (2) and (3) are true, so (1) is true.
    // By induction, the document order and uniqueness is preserved after applying all the steps.
    bool isPattern1() {
      for (var i = 1; i < optimizedSteps.length; i++) {
        final step = optimizedSteps[i];
        if (step.axis is! SelfAxis && step.axis is! AttributeAxis) {
          return false;
        }
      }
      return true;
    }

    bool isPattern2() {
      var i = 0;
      for (i = 0; i < optimizedSteps.length; i++) {
        final axis = optimizedSteps[i].axis;
        if (axis is! SelfAxis && axis is! AttributeAxis && axis is! ChildAxis) {
          break;
        }
      }
      if (i < optimizedSteps.length) {
        final axis = optimizedSteps[i].axis;
        if (axis is DescendantAxis || axis is DescendantOrSelfAxis) {
          i++;
        }
      }
      for (; i < optimizedSteps.length; i++) {
        final axis = optimizedSteps[i].axis;
        if (axis is! SelfAxis && axis is! AttributeAxis) {
          return false;
        }
      }
      return true;
    }

    return PathExpression._(
      optimizedSteps,
      isAbsolute: isAbsolute,
      isOrderPreserved: isPattern1() || isPattern2(),
    );
  }

  const PathExpression._(
    this.steps, {
    required this.isAbsolute,
    required this.isOrderPreserved,
  });

  final List<Step> steps;
  final bool isAbsolute;

  /// Whether the document order of the resulting nodes is preserved after applying all the steps.
  final bool isOrderPreserved;

  @override
  XPathValue call(XPathContext context) {
    if (steps.isEmpty) {
      return XPathNodeSet.single(context.node.root);
    }
    final inner = context.copy();
    if (isOrderPreserved) {
      var nodes = [if (isAbsolute) context.node.root else context.node];
      for (final step in steps) {
        final innerNodes = <XmlNode>[];
        for (final node in nodes) {
          inner.node = node;
          innerNodes.addAll(step.find(inner));
        }
        nodes = innerNodes;
      }
      return XPathNodeSet(nodes);
    } else {
      var nodes = {if (isAbsolute) context.node.root else context.node};
      for (final step in steps) {
        final innerNodes = <XmlNode>{};
        for (final node in nodes) {
          inner.node = node;
          innerNodes.addAll(step.find(inner));
        }
        nodes = innerNodes;
      }
      return XPathNodeSet.fromIterable(nodes, isUnique: true);
    }
  }
}
