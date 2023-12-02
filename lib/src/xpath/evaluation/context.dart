import '../../xml/nodes/node.dart';
import 'functions.dart';
import 'values.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  XPathContext(
    this.node, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
  });

  /// Mutable context node.
  XmlNode node;

  /// Mutable context position.
  int position = 1;

  /// Mutable context size.
  int last = 1;

  /// The current node as an [XPathValue].
  XPathValue get value => XPathNodeSet([node]);

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
        position: position,
        last: last,
        variables: variables,
        functions: functions,
      );
}
