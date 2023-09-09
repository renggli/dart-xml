import 'package:meta/meta.dart' show experimental;
import 'package:petitparser/core.dart' show Failure;

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/cache.dart';
import 'src/xpath/context.dart';
import 'src/xpath/exceptions/parser_exception.dart';
import 'src/xpath/parser.dart';
import 'src/xpath/resolver.dart';
import 'src/xpath/values.dart';

export 'src/xpath/exceptions/parser_exception.dart';
export 'src/xpath/exceptions/function_exception.dart';
export 'src/xpath/values.dart';

extension XPathExtension on XmlNode {
  /// Returns an iterable over the nodes matching the provided XPath
  /// [expression].
  @experimental
  Iterable<XmlNode> xpath(String expression) => xpathEvaluate(expression).nodes;

  /// Returns the value resulting from evaluating the given XPath [expression].
  ///
  /// The returned value is of type [NodesValue], [StringValue], [NumberValue],
  /// or [BooleanValue]. You can fetch the underlying data by calling
  /// [Value.nodes], [Value.string], [Value.number], or [Value.boolean]
  /// respectively.
  Value xpathEvaluate(String expression) =>
      _cache[expression](Context(), NodesValue([this]));
}

final _parser = const XPathParser().build();
final _cache = XmlCache<String, Resolver>((expression) {
  final result = _parser.parse(expression);
  if (result is Failure) {
    throw XPathParserException(result.message,
        buffer: expression, position: result.position);
  }
  return result.value;
}, 25);
