import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
Never fnError(
  XPathContext context, [
  XPathSequence? code,
  XPathSequence? description,
  XPathSequence? errorObject,
]) {
  final buffer = StringBuffer();
  final codeOpt = code != null
      ? XPathEvaluationException.checkZeroOrOne(code)?.toXPathString()
      : null;
  if (codeOpt != null) buffer.write(codeOpt);
  final descriptionOpt = description != null
      ? XPathEvaluationException.checkZeroOrOne(description)?.toXPathString()
      : null;
  if (descriptionOpt != null) {
    if (buffer.isNotEmpty) {
      buffer.write(': ');
    }
    buffer.write(descriptionOpt);
  }
  final errorObjectOpt = errorObject != null
      ? XPathEvaluationException.checkZeroOrOne(errorObject)?.toXPathString()
      : null;
  if (errorObjectOpt != null) {
    if (buffer.isEmpty) {
      buffer.write(errorObjectOpt);
    } else {
      buffer.write(' ($errorObjectOpt)');
    }
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
XPathSequence fnTrace(
  XPathContext context,
  XPathSequence value, [
  XPathSequence? label,
]) {
  final labelOpt = label != null
      ? XPathEvaluationException.checkZeroOrOne(label)?.toXPathString()
      : null;
  context.onTraceCallback?.call(value, labelOpt);
  return value;
}
