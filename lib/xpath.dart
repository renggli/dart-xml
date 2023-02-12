import 'package:meta/meta.dart';

import 'src/xml/nodes/node.dart';
import 'src/xml/utils/cache.dart';
import 'src/xpath/exceptions/parser_exception.dart';
import 'src/xpath/parser.dart';
import 'src/xpath/resolver.dart';

export 'src/xpath/exceptions/parser_exception.dart';

extension XPathExtension on XmlNode {
  /// Returns a lazy iterable over the provided simplified XPath [expression].
  @experimental
  Iterable<XmlNode> xpath(String expression) => _cache[expression]([this]);
}

final _parser = const XPathParser().build();
final _cache = XmlCache<String, Resolver>((expression) {
  final result = _parser.parse(expression);
  if (result.isFailure) {
    throw XPathParserException(result.message,
        buffer: expression, position: result.position);
  }
  return result.value;
}, 25);
