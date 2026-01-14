import 'package:petitparser/petitparser.dart' show unbounded;

import '../../xml/exceptions/exception.dart';
import '../evaluation/functions.dart';
import '../types31/sequence.dart';

/// Exception thrown when calling an XPath functions fails.
class XPathEvaluationException extends XmlException {
  XPathEvaluationException(super.message);

  /// Checks the number of arguments passed to a XPath function.
  static void checkArgumentCount(
    String functionName,
    List<dynamic> arguments,
    int min, [
    int? max,
  ]) {
    final count = arguments.length;
    if (min <= count && count <= (max ?? min)) return;
    final buffer = StringBuffer('Function "$functionName" expects ');
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

  /// Extracts the value of a sequence that has at most one item.
  static Object? extractZeroOrOne(
    String functionName,
    String argumentName,
    XPathSequence value,
  ) {
    final iterator = value.iterator;
    if (!iterator.moveNext()) return null;
    final item = iterator.current;
    if (!iterator.moveNext()) return item;
    throw XPathEvaluationException(
      'Function "$functionName" argument "$argumentName" expects a sequence '
      'with zero-or-one items, but got $value',
    );
  }

  /// Extracts the value of a sequence that has exactly one item.
  static Object extractExactlyOne(
    String functionName,
    String argumentName,
    XPathSequence value,
  ) {
    final iterator = value.iterator;
    if (iterator.moveNext()) {
      final item = iterator.current;
      if (!iterator.moveNext()) return item;
    }
    throw XPathEvaluationException(
      'Function "$functionName" argument "$argumentName" expects a sequence '
      'with exactly-one item, but got $value',
    );
  }

  /// Extracts the values of a sequence that has at least one item.
  static XPathSequence extractOneOrMore(
    String functionName,
    String argumentName,
    XPathSequence value,
  ) {
    if (value.isNotEmpty) return value;
    throw XPathEvaluationException(
      'Function "$functionName" argument "$argumentName" expects a sequence '
      'with one-or-more items, but got $value',
    );
  }

  /// Checks the presence of a variable.
  static XPathSequence checkVariable(String name, XPathSequence? value) {
    if (value != null) return value;
    throw XPathEvaluationException('Undeclared variable "$name"');
  }

  /// Checks the presence of a function.
  static XPathFunction checkFunction(String name, XPathFunction? value) {
    if (value != null) return value;
    throw XPathEvaluationException('Undeclared function "$name"');
  }

  /// Unsupported cast from [value] to [type].
  static Never unsupportedCast(Object value, String type) =>
      throw XPathEvaluationException('Unsupported cast from $value to $type');

  /// Thrown when a map key is invalid.
  static Never invalidMapKey(XPathSequence key) =>
      throw XPathEvaluationException('Invalid map key: $key');

  @override
  String toString() => 'XPathEvaluationException: $message';
}
