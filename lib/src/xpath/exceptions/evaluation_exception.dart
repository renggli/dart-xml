import '../../xml/exceptions/exception.dart';
import 'error_code.dart';

/// Exception thrown when calling an XPath function or evaluating an expression fails.
class XPathEvaluationException extends XmlException {
  new(this.errorCode, [this.details]) : super(errorCode.format(details));

  /// The XPath error code.
  final XPathErrorCode errorCode;

  /// Optional specific details of the error.
  final String? details;

  @override
  String toString() => 'XPathEvaluationException: $message';
}
