import '../../xml/utils/name.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath QName type.
const xsQName = _XPathQNameType();

class _XPathQNameType extends XPathType<Object> {
  const _XPathQNameType();

  @override
  String get name => 'xs:QName';

  @override
  bool matches(Object value) => value is XmlName;

  @override
  XmlName cast(Object value) {
    if (value is XmlName) {
      return value;
    } else if (value is String) {
      return XmlName.qualified(value);
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
