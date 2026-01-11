import 'package:petitparser/petitparser.dart' show unbounded;

import '../../xml/exceptions/exception.dart';
import '../evaluation/functions.dart';
import '../evaluation/values.dart';
import '../types31/sequence.dart';

/// Exception thrown when calling an XPath functions fails.
class XPathEvaluationException extends XmlException {
  XPathEvaluationException(super.message);

  /// Checks the number of arguments passed to a XPath function.
  static void checkArgumentCount(
    String name,
    List<dynamic> arguments,
    int min, [
    int? max,
  ]) {
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

  /// Checks the presence of a variable.
  static XPathValue checkVariable(String name, XPathValue? value) {
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

  /// Checks that a sequence has at most one item.
  static Object? checkZeroOrOne(XPathSequence value) {
    final iterator = value.iterator;
    if (!iterator.moveNext()) return null;
    final item = iterator.current;
    if (!iterator.moveNext()) return item;
    throw XPathEvaluationException(
      'Expected sequence with zero-or-one items, but got $value',
    );
  }

  /// Checks that a sequence has exactly one item.
  static Object checkExactlyOne(XPathSequence value) {
    final iterator = value.iterator;
    if (iterator.moveNext()) {
      final item = iterator.current;
      if (!iterator.moveNext()) return item;
    }
    throw XPathEvaluationException(
      'Expected sequence with exactly one item, but got $value',
    );
  }

  /// Checks that a sequence has at least one item.
  static Iterable<Object> checkOneOrMore(XPathSequence value) {
    if (value.isNotEmpty) return value;
    throw XPathEvaluationException(
      'Expected sequence with one-or-more items, but got $value',
    );
  }

  @override
  String toString() => 'XPathEvaluationException: $message';
}
