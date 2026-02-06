import 'package:petitparser/core.dart' show Failure;

import '../../xml/nodes/node.dart';
import '../../xml/utils/cache.dart';
import '../exceptions/parser_exception.dart';
import '../parser.dart';
import 'expression.dart';
import 'types.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  XPathContext(
    this.item, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
    this.documents = const {},
    this.namespaces = const {
      'xml': 'http://www.w3.org/XML/1998/namespace',
      'fn': 'http://www.w3.org/2005/xpath-functions',
      'math': 'http://www.w3.org/2005/xpath-functions/math',
      'map': 'http://www.w3.org/2005/xpath-functions/map',
      'array': 'http://www.w3.org/2005/xpath-functions/array',
      'xs': 'http://www.w3.org/2001/XMLSchema',
    },
    this.onTraceCallback,
  });

  /// Mutable context node.
  XPathItem item;

  /// Mutable context position.
  int position;

  /// Mutable context size.
  int last;

  /// Looks up an XPath variable with the given [name].
  XPathSequence? getVariable(String name) => variables[name];

  /// Looks up a XPath function with the given [name].
  Object? getFunction(String name) {
    if (name.startsWith('Q{')) {
      final end = name.indexOf('}');
      if (end != -1) return functions[name];
    }
    final index = name.indexOf(':');
    if (index != -1) {
      final prefix = name.substring(0, index);
      final local = name.substring(index + 1);
      final uri = namespaces[prefix];
      if (uri != null) {
        final key = 'Q{$uri}$local';
        if (functions.containsKey(key)) return functions[key];
      }
      if (functions.containsKey(name)) return functions[name];
    } else {
      // Default function namespace logic could go here, for now assuming fn:
      const defaultUri = 'http://www.w3.org/2005/xpath-functions';
      final key = 'Q{$defaultUri}$name';
      if (functions.containsKey(key)) return functions[key];
      // Fallback for unprefixed legacy keys (if any)
      if (functions.containsKey(name)) return functions[name];
    }
    return null;
  }

  /// User-defined variables.
  final Map<String, XPathSequence> variables;

  /// User-defined functions.
  final Map<String, Object> functions;

  /// Available documents.
  final Map<String, XmlNode> documents;

  /// Available namespaces.
  final Map<String, String> namespaces;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Creates a copy of the current context.
  XPathContext copy({
    Map<String, XPathSequence>? variables,
    Map<String, Object>? functions,
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
typedef XPathTraceCallback =
    void Function(XPathSequence value, XPathString? label);

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
