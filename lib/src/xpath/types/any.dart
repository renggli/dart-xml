import '../definitions/types.dart';

/// The XPath any value type.
const xsAny = _XPathAnyvalueType();

class _XPathAnyvalueType extends XPathType<Object> {
  const _XPathAnyvalueType();

  @override
  String get name => 'value()';

  @override
  bool matches(Object value) => true;

  @override
  Object cast(Object value) => value;
}
