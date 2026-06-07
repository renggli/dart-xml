import 'package:meta/meta.dart';
import '../exceptions/evaluation_exception.dart';
import '../grammars/parser.dart';
import '../values/sequence.dart';
import 'configuration.dart';

/// Dynamic execution context to evaluate XPath expressions.
class XPathContext {
  /// Creates a dynamic execution context.
  @internal
  XPathContext(
    this.configuration,
    this.item, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.parentContext,
  });

  /// Configuraiton associated with the context.
  final XPathConfiguration configuration;

  /// Mutable context item.
  Object item;

  /// Mutable context position.
  int position;

  /// Mutable context size.
  int last;

  /// Variables defined in this scope.
  final Map<String, Object> variables;

  /// Parent context used for variable lookup.
  final XPathContext? parentContext;

  /// Looks up an XPath variable with the given [name].
  Object getVariable(String name) {
    // Find the variable in the context chain.
    XPathContext? context = this;
    while (context != null) {
      final variable = context.variables[name];
      if (variable != null) return variable;
      context = context.parentContext;
    }
    // If not found, check the static context.
    final variable = configuration.variables[name];
    if (variable != null) return variable;
    // If still not found, throw an exception.
    throw XPathEvaluationException('Unknown variable: $name');
  }

  /// Evaluates the given XPath [expression].
  XPathSequence evaluate(String expression) =>
      parseExpression(expression)(this);

  /// Creates a modified copy of this context.
  XPathContext copy({
    Object? item,
    int? position,
    int? last,
    Map<String, Object>? variables,
  }) => XPathContext(
    configuration,
    item ?? this.item,
    position: position ?? this.position,
    last: last ?? this.last,
    variables: variables ?? this.variables,
    parentContext: this,
  );
}
