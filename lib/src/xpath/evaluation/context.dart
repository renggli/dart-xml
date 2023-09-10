import '../../xml/nodes/node.dart';
import 'functions.dart';
import 'values.dart';

class XPathContext {
  XPathContext(
    this.node, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
  });

  XmlNode node;

  int position = 1;

  int last = 1;

  XPathValue get value => XPathNodeSet([node]);

  /// Looks up an XPath variable with the given [name].
  XPathValue? getVariable(String name) => variables[name];

  /// Looks up a XPath function with the given [name].
  XPathFunction? getFunction(String name) =>
      functions[name] ?? standardFunctions[name];

  final Map<String, XPathValue> variables;

  final Map<String, XPathFunction> functions;

  XPathContext copy() => XPathContext(
        node,
        position: position,
        last: last,
        variables: variables,
        functions: functions,
      );
}
