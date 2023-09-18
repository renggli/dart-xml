import 'package:petitparser/petitparser.dart' show unbounded;

import '../../xml/exceptions/exception.dart';
import '../evaluation/expression.dart';
import '../evaluation/functions.dart';
import '../evaluation/values.dart';

/// Exception thrown when calling an XPath functions fails.
class XPathEvaluationException extends XmlException {
  XPathEvaluationException(super.message);

  /// Checks the number of arguments passed to a XPath function.
  static void checkArgumentCount(
      String name, List<XPathExpression> arguments, int min,
      [int? max]) {
    final count = arguments.length;
    if (min <= count && count <= (max ?? min)) return;
    final buffer = StringBuffer('Function "$name" expects ');
    if (min == max || max == null) {
      buffer.write('$min arguments');
    } else if (max == unbounded) {
      buffer.write('at least $min arguments');
    } else {
      buffer.write('between $min and $max arguments');
    }
    buffer.write(', but got $count');
    throw XPathEvaluationException(buffer.toString());
  }

  // Checks the presence of a variable.
  static XPathValue checkVariable(String name, XPathValue? value) {
    if (value != null) return value;
    throw XPathEvaluationException('Undeclared variable "$name"');
  }

  // Checks the presence of a function.
  static XPathFunction checkFunction(String name, XPathFunction? value) {
    if (value != null) return value;
    throw XPathEvaluationException('Undeclared function "$name"');
  }

  @override
  String toString() => 'XPathEvaluationException: $message';
}
