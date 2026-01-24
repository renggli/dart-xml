import '../../xml/nodes/node.dart';
import '../types/item.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// Runtime execution context to evaluate XPath expressions.
class XPathContext {
  XPathContext(
    this.item, {
    this.position = 1,
    this.last = 1,
    this.variables = const {},
    this.functions = const {},
    this.documents = const {},
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
  Object? getFunction(String name) => functions[name];

  /// User-defined variables.
  final Map<String, XPathSequence> variables;

  /// User-defined functions.
  final Map<String, Object> functions;

  /// Available documents.
  final Map<String, XmlNode> documents;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Creates a copy of the current context.
  XPathContext copy({
    Map<String, XPathSequence>? variables,
    Map<String, Object>? functions,
    Map<String, XmlNode>? documents,
    XPathTraceCallback? onTraceCallback,
  }) => XPathContext(
    item,
    position: position,
    last: last,
    variables: variables ?? this.variables,
    functions: functions ?? this.functions,
    documents: documents ?? this.documents,
    onTraceCallback: onTraceCallback ?? this.onTraceCallback,
  );
}

/// Function type for tracing evaluation.
typedef XPathTraceCallback =
    void Function(XPathSequence value, XPathString? label);
