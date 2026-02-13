import 'package:petitparser/petitparser.dart';

import '../../xml/utils/cache.dart';
import '../evaluation/expression.dart';
import '../exceptions/parser_exception.dart';
import 'xpath.dart';

XPathExpression parseExpression(String expression) => _cache[expression];

final _parser = const XPathGrammar().build();
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
