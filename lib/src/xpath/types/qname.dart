import '../../xml/utils/name.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath QName type.
const xsQName = _XPathQNameType();

class _XPathQNameType extends XPathType<XmlName> {
  const _XPathQNameType();

  @override
  String get name => 'xs:QName';

  @override
  bool matches(Object value) => value is XmlName;

  @override
  XmlName cast(Object value) => switch (value) {
    XmlName() => value,
    String() => XmlName.qualified(value),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  @override
  String castToString(XmlName value) => value.qualified;
}
