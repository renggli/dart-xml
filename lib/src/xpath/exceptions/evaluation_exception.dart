import '../../xml/exceptions/exception.dart';
import '../definitions/type.dart';
import '../types/sequence.dart';

/// Exception thrown when calling an XPath functions fails.
class XPathEvaluationException extends XmlException {
  XPathEvaluationException(super.message);

  /// Unsupported cast from [value] to [type].
  static Never unsupportedCast(XPathType type, Object value) =>
      throw XPathEvaluationException('Unsupported cast from $value to $type');

  /// Thrown when a map key is invalid.
  static Never invalidMapKey(XPathSequence key) =>
      throw XPathEvaluationException('Invalid map key: $key');

  @override
  String toString() => 'XPathEvaluationException: $message';
}
