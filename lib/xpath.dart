/// Dart XPath adds support of XPath 1.0 expressions to the XML library.
library;

import 'package:meta/meta.dart' show experimental;

import 'src/xml/nodes/node.dart';
import 'src/xpath/evaluation/context.dart';
import 'src/xpath/evaluation/functions.dart';
import 'src/xpath/types/sequence.dart';

export 'src/xpath/evaluation/functions.dart' show XPathFunction;
export 'src/xpath/exceptions/evaluation_exception.dart';
export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/generator.dart' show XPathGenerator;
export 'src/xpath/types/sequence.dart';

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  @experimental
  Iterable<XmlNode> xpath(
    String expression, {
    Map<String, XPathSequence> variables = const {},
    Map<String, Object> functions = const {},
  }) => xpathEvaluate(
    expression,
    variables: variables,
    functions: functions,
  ).whereType<XmlNode>();

  /// Returns the value resulting from evaluating the given XPath [expression].
  ///
  /// The returned value is of type [XPathSequence], which is an iterable of
  /// [Object]s.
  @experimental
  XPathSequence xpathEvaluate(
    String expression, {
    Map<String, XPathSequence> variables = const {},
    Map<String, Object> functions = const {},
  }) => XPathContext(
    this,
    variables: variables,
    functions: {...standardFunctions, ...functions},
  ).evaluate(expression);
}
