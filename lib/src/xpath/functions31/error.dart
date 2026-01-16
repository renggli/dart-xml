import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
XPathSequence fnError(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:error', arguments, 0, 3);
  final buffer = StringBuffer();
  if (arguments.isNotEmpty) {
    final code = XPathEvaluationException.extractZeroOrOne(
      'fn:error',
      'code',
      arguments[0],
    );
    if (code != null) buffer.write(code.toXPathString());
  }
  if (arguments.length > 1) {
    final description = XPathEvaluationException.extractExactlyOne(
      'fn:error',
      'description',
      arguments[1],
    );
    if (buffer.isNotEmpty) buffer.write(': ');
    buffer.write(description.toXPathString());
  }
  if (arguments.length > 2) {
    final errorObject = arguments[2].toXPathSequence();
    if (errorObject.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(errorObject);
    }
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
XPathSequence fnTrace(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:trace', arguments, 1, 2);
  final value = arguments[0];
  final label = arguments.length > 1
      ? XPathEvaluationException.extractExactlyOne(
          'fn:trace',
          'label',
          arguments[1],
        ).toXPathString()
      : null;
  context.onTraceCallback?.call(value, label);
  return value;
}
