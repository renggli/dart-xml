import '../../xml/nodes/node.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/function.dart';
import '../values/sequence.dart';

/// The XPath any value type.
const xsAny = _XPathAnyType();

class _XPathAnyType extends XPathType<Object> {
  const _XPathAnyType();

  @override
  String get name => 'item()';

  @override
  bool get isAtomic => false;

  @override
  Iterable<String> get aliases => ['xs:untyped', 'xs:untypedAtomic'];

  @override
  bool matches(Object value) => true;

  @override
  Object cast(Object value) => value;
}

/// The XPath anyAtomicType type.
const xsAnyAtomicType = _XPathAnyAtomicType();

class _XPathAnyAtomicType extends XPathType<Object> {
  const _XPathAnyAtomicType();

  @override
  String get name => 'xs:anyAtomicType';

  @override
  bool get isAtomic => true;

  @override
  bool matches(Object value) =>
      value is! XmlNode &&
      value is! XPathSequence &&
      value is! XPathFunction &&
      value is! Function &&
      value is! Map &&
      value is! List;

  @override
  Object cast(Object value) {
    if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) {
        return cast(item);
      }
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    if (matches(value)) {
      return value;
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath error type.
const xsError = _XPathErrorType();

class _XPathErrorType extends XPathType<Object> {
  const _XPathErrorType();

  @override
  String get name => 'xs:error';

  @override
  bool get isAtomic => true;

  @override
  bool matches(Object value) => false;

  @override
  Object cast(Object value) =>
      throw XPathEvaluationException.unsupportedCast(this, value);
}
