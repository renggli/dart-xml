import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import 'context.dart';
import 'functions.dart';
import 'namespaces.dart';

/// Function type for tracing evaluation.
typedef XPathTraceCallback = void Function(XPathSequence value, String? label);

/// Function type for loading unparsed text.
typedef XPathUnparsedTextLoader = String? Function(
  String uri,
  String? encoding,
);

/// Static configuration for XPath evaluation.
class XPathConfiguration {
  /// Creates a static context extending the standard configuration.
  factory({
    Map<String, Object?>? variables,
    Map<XmlName, XPathFunctionItem>? functions,
    String? namespaceUri,
    Map<String, String>? namespaceUris,
    Map<String, XmlNode>? documents,
    Map<String, List<XmlNode>>? collections,
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
    collections: collections,
    environment: environment,
    baseUri: baseUri,
    unparsedTextLoader: unparsedTextLoader,
    onTraceCallback: onTraceCallback,
  );

  /// Creates a standard static configuration.
  factory standard() => _standard;

  /// Creates a static configuration from scratch not including any of the
  /// standard functions or namespaces.
  const new raw({
    this.variables = const {},
    this.functions = const {},
    this.namespaceUri,
    this.namespaceUris = const {},
    this.documents = const {},
    this.collections = const {},
    this.environment = const {},
    this.baseUri,
    this.unparsedTextLoader,
    this.onTraceCallback,
  });

  /// Variable definitions.
  final Map<String, XPathSequence> variables;

  /// Function definitions.
  final Map<XmlName, XPathFunctionItem> functions;

  /// Default namespace URI for function lookups.
  final String? namespaceUri;

  /// Namespace mapping from prefix to URIs.
  final Map<String, String> namespaceUris;

  /// Document definitions
  final Map<String, XmlNode> documents;

  /// Collection definitions.
  final Map<String, List<XmlNode>> collections;

  /// Environment variable definitions.
  final Map<String, String> environment;

  /// Static base URI.
  final String? baseUri;

  /// Unparsed text loader.
  final XPathUnparsedTextLoader? unparsedTextLoader;

  /// Callback to trace evaluation.
  final XPathTraceCallback? onTraceCallback;

  /// Looks up a XPath function with the given [name] and optional [arity].
  XPathFunctionItem getFunction(XmlName name, [int? arity]) {
    final function = functions[name];
    if (function != null) {
      if (arity != null && function is XPathOverloadedFunction) {
        final specific = function.getForArity(arity);
        if (specific != null) return specific;
        throw XPathEvaluationException(
          'Function "$name" does not support arity $arity',
        );
      }
      if (arity != null && !function.isVariadic && function.arity != arity) {
        throw XPathEvaluationException(
          'Function "$name" does not support arity $arity',
        );
      }
      if (arity != null && function.isVariadic && arity < function.arity) {
        throw XPathEvaluationException(
          'Function "$name" expects at least ${function.arity} arguments, but got $arity',
        );
      }
      return function;
    }
    throw XPathEvaluationException('Unknown function: $name');
  }

  /// Looks up a XPath function with the given [name] (string) and optional [arity].
  XPathFunctionItem getFunctionByString(String name, [int? arity]) =>
      getFunction(
        XmlName.parse(
          name,
          namespaceUri: namespaceUri,
          namespaceUris: namespaceUris,
        ),
        arity,
      );

  /// Creates an evaluation context from this configuration, optionally
  /// with a provided context [item].
  XPathContext context([Object item = XPathSequence.empty]) => XPathContext(
    this,
    item is XPathSequence ? item : XPathSequence.toItem(item),
  );

  /// Creates a modified copy of the static context.
  XPathConfiguration copy({
    Map<String, Object?>? variables,
    Map<XmlName, XPathFunctionItem>? functions,
    String? namespaceUri,
    Map<String, String>? namespaceUris,
    Map<String, XmlNode>? documents,
    Map<String, List<XmlNode>>? collections,
    Map<String, String>? environment,
    String? baseUri,
    XPathUnparsedTextLoader? unparsedTextLoader,
    XPathTraceCallback? onTraceCallback,
  }) {
    final convertedVariables = variables == null
        ? null
        : {
            for (final entry in variables.entries)
              entry.key: XPathSequence.fromObject(entry.value),
          };
    return XPathConfiguration.raw(
      variables: this.variables.extend(convertedVariables),
      functions: this.functions.extend(functions),
      namespaceUri: namespaceUri ?? this.namespaceUri,
      namespaceUris: this.namespaceUris.extend(namespaceUris),
      documents: this.documents.extend(documents),
      collections: this.collections.extend(collections),
      environment: this.environment.extend(environment),
      baseUri: baseUri ?? this.baseUri,
      unparsedTextLoader: unparsedTextLoader ?? this.unparsedTextLoader,
      onTraceCallback: onTraceCallback ?? this.onTraceCallback,
    );
  }
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
