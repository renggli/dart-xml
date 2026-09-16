import '../../xml/exceptions/exception.dart';
import '../xdm/types.dart';

/// Exception thrown when calling an XPath functions fails.
class XPathEvaluationException extends XmlException {
  new(super.message);

  /// Unsupported cast from [value] to [type].
  static Never unsupportedCast(XPathType type, Object value) =>
      throw XPathEvaluationException('Unsupported cast from $value to $type');

  @override
  String toString() => 'XPathEvaluationException: $message';
}
