/// Dart XPath adds support of XPath 3.1 expressions to the XML library.
library;

import 'package:meta/meta.dart' show experimental;

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/name.dart';
import 'src/xpath/evaluation/configuration.dart';
import 'src/xpath/values/function.dart';
import 'src/xpath/values/sequence.dart';

export 'src/xpath/evaluation/configuration.dart';
export 'src/xpath/exceptions/evaluation_exception.dart';
export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/generator.dart';
export 'src/xpath/values/function.dart'
    show XPathFunction, XPathWrappedFunctionExtension;
export 'src/xpath/values/sequence.dart' show XPathSequence;

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  ///
  /// An optional [configuration] can be provided to customize the evaluation
  /// context. The returned nodes are a lazy iterable of [XmlNode] instances.
  @experimental
  Iterable<XmlNode> xpath(
    String expression, {
    XPathConfiguration? configuration,
    @Deprecated('Specify variables in the configuration instead')
    Map<String, Object>? variables,
    @Deprecated('Specify functions in the configuration instead')
    Map<XmlName, XPathFunction>? functions,
  }) => xpathEvaluate(
    expression,
    configuration: configuration,
    variables: variables,
    functions: functions,
  ).whereType<XmlNode>();

  /// Returns the value resulting from evaluating the given XPath [expression].
  ///
  /// An optional [configuration] can be provided to customize the evaluation
  /// context. The returned value is of type [XPathSequence], which is a lazy
  /// iterable of [Object]s.
  @experimental
  XPathSequence xpathEvaluate(
    String expression, {
    XPathConfiguration? configuration,
    @Deprecated('Specify variables in the configuration instead')
    Map<String, Object>? variables,
    @Deprecated('Specify functions in the configuration instead')
    Map<XmlName, XPathFunction>? functions,
  }) {
    var config = configuration ?? XPathConfiguration.standard();
    if (variables != null || functions != null) {
      config = config.copy(variables: variables, functions: functions);
    }
    return config.context(this).evaluate(expression);
  }
}
