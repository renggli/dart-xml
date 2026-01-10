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
  final codeValue = code?.firstOrNull?.toXPathString();
  if (codeValue != null) buffer.write(codeValue);
  final descriptionValue = description?.firstOrNull?.toXPathString();
  if (descriptionValue != null) {
    if (buffer.isNotEmpty) {
      buffer.write(': ');
    }
    buffer.write(descriptionValue);
  }
  final errorObjectValue = errorObject?.firstOrNull?.toXPathString();
  if (errorObjectValue != null) {
    if (buffer.isEmpty) {
      buffer.write(errorObjectValue);
    } else {
      buffer.write(' ($errorObjectValue)');
    }
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
XPathSequence fnTrace(
  XPathContext context,
  XPathSequence value, [
  XPathSequence? label,
]) => value;
