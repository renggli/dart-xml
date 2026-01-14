/// Dart XPath adds support of XPath 1.0 expressions to the XML library.
library;

import 'package:meta/meta.dart' show experimental;
import 'package:petitparser/core.dart' show Failure;

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/cache.dart';
import 'src/xpath/evaluation/context.dart';
import 'src/xpath/evaluation/expression.dart';
import 'src/xpath/evaluation/functions.dart';
import 'src/xpath/exceptions/parser_exception.dart';
import 'src/xpath/parser.dart';
import 'src/xpath/types31/sequence.dart';

export 'src/xpath/evaluation/functions.dart' show XPathFunction;
export 'src/xpath/exceptions/evaluation_exception.dart';
export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/generator.dart' show XPathGenerator;
export 'src/xpath/types31/sequence.dart';

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  @experimental
  Iterable<XmlNode> xpath(
    String expression, {
    Map<String, XPathSequence> variables = const {},
    Map<String, XPathFunction> functions = const {},
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
    Map<String, XPathFunction> functions = const {},
  }) {
    final allFunctions = {...standardFunctions, ...functions};
    return _cache[expression](
      XPathContext(this, variables: variables, functions: allFunctions),
    );
  }
}

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
