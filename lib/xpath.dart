/// Dart XPath adds support of XPath 1.0 expressions to the XML library.
library xpath;

import 'package:meta/meta.dart' show experimental;
import 'package:petitparser/core.dart' show Failure;

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/cache.dart';
import 'src/xpath/evaluation/context.dart';
import 'src/xpath/evaluation/expression.dart';
import 'src/xpath/evaluation/functions.dart';
import 'src/xpath/evaluation/values.dart';
import 'src/xpath/exceptions/parser_exception.dart';
import 'src/xpath/parser.dart';

export 'src/xpath/evaluation/functions.dart' show XPathFunction;
export 'src/xpath/evaluation/values.dart';
export 'src/xpath/exceptions/evaluation_exception.dart';
export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/generator.dart' show XPathGenerator;

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  @experimental
  Iterable<XmlNode> xpath(String expression,
          {Map<String, XPathValue> variables = const {},
          Map<String, XPathFunction> functions = const {}}) =>
      xpathEvaluate(expression, variables: variables, functions: functions)
          .nodes;

  /// Returns the value resulting from evaluating the given XPath [expression].
  ///
  /// The returned value is of type [XPathNodeSet], [XPathString], [XPathNumber],
  /// or [XPathBoolean]. You can fetch the underlying data by calling
  /// [XPathValue.nodes], [XPathValue.string], [XPathValue.number], or
  /// [XPathValue.boolean] respectively.
  @experimental
  XPathValue xpathEvaluate(String expression,
          {Map<String, XPathValue> variables = const {},
          Map<String, XPathFunction> functions = const {}}) =>
      _cache[expression](
          XPathContext(this, variables: variables, functions: functions));
}

final _parser = const XPathParser().build();
final _cache = XmlCache<String, XPathExpression>((expression) {
  final result = _parser.parse(expression);
  if (result is Failure) {
    throw XPathParserException(result.message,
        buffer: expression, position: result.position);
  }
  return result.value;
}, 25);
