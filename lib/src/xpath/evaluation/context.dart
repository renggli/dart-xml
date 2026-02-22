import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../grammars/parser.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import 'functions.dart';
import 'namespaces.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  /// Creates an empty XPath context.
  XPathContext.empty(
    this.item, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
    this.namespaceUri,
    this.namespaceUris = const {},
    this.documents = const {},
    this.onTraceCallback,
  });

  /// Creates a canonical XPath context on [item].
  XPathContext.canonical(this.item)
    : position = 1,
      last = 1,
      variables = const {},
      functions = standardFunctions,
      namespaceUri = xpathFnNamespace,
      namespaceUris = xpathNamespaceUris,
      documents = const {},
      onTraceCallback = null;

  /// Mutable context node.
  Object item;

  /// Mutable context position.
  int position;

  /// Mutable context size.
  int last;

  /// User-defined variables.
  final Map<String, Object> variables;

  /// Available function definitions.
  final Map<XmlName, XPathFunction> functions;

  /// Default namespace URI for function lookups.
  final String? namespaceUri;

  /// Namespace mapping from prefix to URIs.
  final Map<String, String> namespaceUris;

  /// Available documents.
  final Map<String, XmlNode> documents;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Looks up an XPath variable with the given [name].
  Object getVariable(String name) {
    final variable = variables[name];
    if (variable != null) return variable;
    throw XPathEvaluationException('Unknown variable: $name');
  }

  /// Looks up a XPath function with the given [name].
  XPathFunction getFunction(XmlName name) {
    final function = functions[name];
    if (function != null) return function;
    throw XPathEvaluationException('Unknown function: $name');
  }

  /// Looks up a XPath function with the given [name].
  XPathFunction getFunctionByString(String name) => getFunction(
    XmlName.parse(
      name,
      namespaceUri: namespaceUri,
      namespaceUris: namespaceUris,
    ),
  );

  /// Creates a copy of this context.
  XPathContext copy({
    Map<String, Object>? variables,
    Map<XmlName, XPathFunction>? functions,
    String? namespaceUri,
    Map<String, String>? namespaceUris,
    Map<String, XmlNode>? documents,
    XPathTraceCallback? onTraceCallback,
  }) => XPathContext.empty(
    item,
    position: position,
    last: last,
    variables: _extend(this.variables, variables),
    functions: _extend(this.functions, functions),
    documents: _extend(this.documents, documents),
    namespaceUri: namespaceUri ?? this.namespaceUri,
    namespaceUris: _extend(this.namespaceUris, namespaceUris),
    onTraceCallback: onTraceCallback ?? this.onTraceCallback,
  );

  /// Evaluates the given XPath [expression].
  XPathSequence evaluate(String expression) =>
      parseExpression(expression)(this);
}

/// Function type for tracing evaluation.
typedef XPathTraceCallback = void Function(XPathSequence value, String? label);

Map<K, V> _extend<K, V>(Map<K, V> original, Map<K, V>? other) {
  if (other == null || other.isEmpty) return original;
  if (original.isEmpty) return other;
  return {...original, ...other};
}
