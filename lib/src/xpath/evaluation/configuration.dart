import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import 'context.dart';
import 'functions.dart';
import 'namespaces.dart';

/// Function type for tracing evaluation.
typedef XPathTraceCallback = void Function(XPathSequence value, String? label);

/// Function type for loading unparsed text.
typedef XPathUnparsedTextLoader =
    String? Function(String uri, String? encoding);

/// Static configuration for XPath evaluation.
class XPathConfiguration {
  /// Creates a static context extending the standard configuration.
  factory XPathConfiguration({
    Map<String, Object>? variables,
    Map<XmlName, XPathFunction>? functions,
    String? namespaceUri,
    Map<String, String>? namespaceUris,
    Map<String, XmlNode>? documents,
    Map<String, String>? environment,
    String? baseUri,
    XPathUnparsedTextLoader? unparsedTextLoader,
    XPathTraceCallback? onTraceCallback,
  }) => _standard.copy(
    variables: variables,
    functions: functions,
    namespaceUri: namespaceUri,
    namespaceUris: namespaceUris,
    documents: documents,
    environment: environment,
    baseUri: baseUri,
    unparsedTextLoader: unparsedTextLoader,
    onTraceCallback: onTraceCallback,
  );

  /// Creates a standard static configuration.
  factory XPathConfiguration.standard() => _standard;

  /// Creates a static configuration from scratch not including any of the
  /// standard functions or namespaces.
  const XPathConfiguration.raw({
    this.variables = const {},
    this.functions = const {},
    this.namespaceUri,
    this.namespaceUris = const {},
    this.documents = const {},
    this.environment = const {},
    this.baseUri,
    this.unparsedTextLoader,
    this.onTraceCallback,
  });

  /// Variable definitions.
  final Map<String, Object> variables;

  /// Function definitions.
  final Map<XmlName, XPathFunction> functions;

  /// Default namespace URI for function lookups.
  final String? namespaceUri;

  /// Namespace mapping from prefix to URIs.
  final Map<String, String> namespaceUris;

  /// Document definitions
  final Map<String, XmlNode> documents;

  /// Environment variable definitions.
  final Map<String, String> environment;

  /// Static base URI.
  final String? baseUri;

  /// Unparsed text loader.
  final XPathUnparsedTextLoader? unparsedTextLoader;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Looks up a XPath function with the given [name].
  XPathFunction getFunction(XmlName name) {
    final function = functions[name];
    if (function != null) return function;
    throw XPathEvaluationException('Unknown function: $name');
  }

  /// Looks up a XPath function with the given [name] (string).
  XPathFunction getFunctionByString(String name) => getFunction(
    XmlName.parse(
      name,
      namespaceUri: namespaceUri,
      namespaceUris: namespaceUris,
    ),
  );

  /// Creates an evaluation context from this configuration, optionally
  /// with a provided context [item].
  XPathContext context([Object item = XPathSequence.empty]) =>
      XPathContext(this, item);

  /// Creates a modified copy of the static context.
  XPathConfiguration copy({
    Map<String, Object>? variables,
    Map<XmlName, XPathFunction>? functions,
    String? namespaceUri,
    Map<String, String>? namespaceUris,
    Map<String, XmlNode>? documents,
    Map<String, String>? environment,
    String? baseUri,
    XPathUnparsedTextLoader? unparsedTextLoader,
    XPathTraceCallback? onTraceCallback,
  }) => XPathConfiguration.raw(
    variables: this.variables.extend(variables),
    functions: this.functions.extend(functions),
    namespaceUri: namespaceUri ?? this.namespaceUri,
    namespaceUris: this.namespaceUris.extend(namespaceUris),
    documents: this.documents.extend(documents),
    environment: this.environment.extend(environment),
    baseUri: baseUri ?? this.baseUri,
    unparsedTextLoader: unparsedTextLoader ?? this.unparsedTextLoader,
    onTraceCallback: onTraceCallback ?? this.onTraceCallback,
  );
}

extension _MapExtension<K, V> on Map<K, V> {
  /// Returns a new map by extending this map with another map.
  Map<K, V> extend(Map<K, V>? other) {
    if (other == null || other.isEmpty) return this;
    if (isEmpty) return other;
    return {...this, ...other};
  }
}

final XPathConfiguration _standard = XPathConfiguration.raw(
  functions: standardFunctions,
  namespaceUri: xpathFnNamespace,
  namespaceUris: xpathNamespaceUris,
);
