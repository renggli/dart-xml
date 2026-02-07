import '../definitions/type.dart';

/// The XPath any value type.
const xsAny = _XPathAnyType();

class _XPathAnyType extends XPathType<Object> {
  const _XPathAnyType();

  @override
  String get name => 'item()';

  @override
  bool matches(Object value) => true;

  @override
  Object cast(Object value) => value;
}
