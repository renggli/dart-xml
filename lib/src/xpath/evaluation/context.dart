import 'package:petitparser/core.dart' show Failure;

import '../../xml/nodes/node.dart';
import '../../xml/utils/cache.dart';
import '../exceptions/evaluation_exception.dart';
import '../exceptions/parser_exception.dart';
import '../parser.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import 'expression.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  XPathContext(
    this.item, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
    this.documents = const {},
    this.namespaces = const {},
    this.onTraceCallback,
  });

  /// Mutable context node.
  Object item;

  /// Mutable context position.
  int position;

  /// Mutable context size.
  int last;

  /// User-defined variables.
  final Map<String, Object> variables;

  /// User-defined functions.
  final Map<String, XPathFunction> functions;

  /// Available documents.
  final Map<String, XmlNode> documents;

  /// Available namespaces.
  final Map<String, String> namespaces;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Looks up an XPath variable with the given [name].
  Object getVariable(String name) {
    final variable = variables[name];
    if (variable != null) return variable;
    throw XPathEvaluationException('Unknown variable: $name');
  }

  /// Looks up a XPath function with the given [name].
  XPathFunction getFunction(String name) {
    final function = functions[name];
    if (function != null) return function;
    throw XPathEvaluationException('Unknown function: $name');
  }

  /// Creates a copy of the current context.
  XPathContext copy({
    Map<String, Object>? variables,
    Map<String, XPathFunction>? functions,
    Map<String, XmlNode>? documents,
    Map<String, String>? namespaces,
    XPathTraceCallback? onTraceCallback,
  }) => XPathContext(
    item,
    position: position,
    last: last,
    variables: variables ?? this.variables,
    functions: functions ?? this.functions,
    documents: documents ?? this.documents,
    namespaces: namespaces ?? this.namespaces,
    onTraceCallback: onTraceCallback ?? this.onTraceCallback,
  );

  /// Evaluates the given XPath [expression].
  XPathSequence evaluate(String expression) => _cache[expression](this);
}

/// Function type for tracing evaluation.
typedef XPathTraceCallback = void Function(XPathSequence value, String? label);

final _parser = const XPathParser().build();
final _cache = XmlCache<String, XPathExpression>((expression) {
  final result = _parser.parse(expression);
  if (result is Failure) {
    throw XPathParserException(
      result.message,
      buffer: expression,
      position: result.position,
    );
  }
  return result.value;
}, 25);
