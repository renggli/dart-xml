/// Dart XPath adds support of XPath 3.1 expressions to the XML library.
library;

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/name.dart';
import 'src/xpath/evaluation/configuration.dart';
import 'src/xpath/xdm/functions/function.dart';
import 'src/xpath/xdm/item.dart';
import 'src/xpath/xdm/sequence.dart';

export 'src/xpath/evaluation/configuration.dart';
export 'src/xpath/exceptions/evaluation_exception.dart';
export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/generator.dart';
export 'src/xpath/xdm/atomic.dart';
export 'src/xpath/xdm/function_item.dart' show XPathFunctionItem;
export 'src/xpath/xdm/functions/array.dart' show XPathArray;
export 'src/xpath/xdm/functions/function.dart'
    show XPathFunction, XPathWrappedFunctionExtension;
export 'src/xpath/xdm/functions/map.dart' show XPathMap;
export 'src/xpath/xdm/item.dart' show XPathItem, XPathNode;
export 'src/xpath/xdm/sequence.dart' show XPathSequence;
export 'src/xpath/xdm/types.dart';

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  ///
  /// An optional [configuration] can be provided to customize the evaluation
  /// context. The returned nodes are a lazy iterable of [XmlNode] instances.
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
  ).whereType<XPathNode>().map((item) => item.node);

  /// Returns the value resulting from evaluating the given XPath [expression].
  ///
  /// An optional [configuration] can be provided to customize the evaluation
  /// context. The returned value is of type [XPathSequence].
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
