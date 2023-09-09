import 'package:petitparser/petitparser.dart' show unbounded;

import '../../xml/exceptions/exception.dart';

/// Exception thrown when calling XPath functions fails.
class XPathFunctionException extends XmlException {
  XPathFunctionException(this.name, this.args, super.message);

  /// Checks the number of arguments passed to a XPath function.
  static void checkArgumentCount(String name, List<Object?> args, int min,
      [int? max]) {
    final count = args.length;
    if (min <= count && count <= (max ?? min)) return;
    final buffer = StringBuffer('$name expected ');
    if (min == max || max == null) {
      buffer.write('$min arguments');
    } else if (max == unbounded) {
      buffer.write('at least $min arguments');
    } else {
      buffer.write('between $min and $max arguments');
    }
    buffer.write(', but got $count: ${args.join(', ')}');
    throw XPathFunctionException(name, args, buffer.toString());
  }

  /// The name of the function.
  final String name;

  /// The arguments passed to the function.
  final List<Object?> args;
}
