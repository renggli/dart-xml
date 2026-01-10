import '../evaluation/context.dart';
import '../evaluation/values.dart' as evaluation_values;
import '../types31/sequence.dart';

XPathSequence contextNode(XPathContext context) {
  final value = context.value;
  if (value is evaluation_values.XPathNodeSet) {
    return XPathSequence(value.nodes);
  }
  return value.toXPathSequence();
}
