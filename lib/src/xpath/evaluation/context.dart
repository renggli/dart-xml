import '../../xml/nodes/node.dart';
import 'functions.dart';
import 'values.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  XPathContext(
    this.node, {
    XPathNodeSet? nodeSet,
    this.variables = const {},
    this.functions = const {},
  }) : nodeSet = nodeSet ?? XPathNodeSet.fromSortedUniqueNodes([node]);

  /// Mutable context node.
  XmlNode node;

  /// Mutable context node set.
  XPathNodeSet nodeSet;

  /// The visiting position.
  int? visitingPosition;

  /// The position in document order.
  int get position => nodeSet.getPosition(node, visitingPosition);

  /// The size of the context node set.
  int get last => nodeSet.value.length;

  /// The current node as an [XPathNodeSet].
  XPathNodeSet get value => XPathNodeSet.fromSortedUniqueNodes([node]);

  /// Looks up an XPath variable with the given [name].
  XPathValue? getVariable(String name) => variables[name];

  /// Looks up a XPath function with the given [name].
  XPathFunction? getFunction(String name) =>
      functions[name] ?? standardFunctions[name];

  /// User-defined variables.
  final Map<String, XPathValue> variables;

  /// User-defined functions.
  final Map<String, XPathFunction> functions;

  /// Creates a copy of the current context.
  XPathContext copy() => XPathContext(
    node,
    nodeSet: nodeSet,
    variables: variables,
    functions: functions,
  );
}
