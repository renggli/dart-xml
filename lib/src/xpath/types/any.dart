import '../../xml/nodes/node.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/function.dart';
import '../values/sequence.dart';
import '../values/untyped_atomic.dart';
import 'node.dart';
import 'string.dart';

/// The XPath any value type.
const xsAny = _XPathAnyType();

class _XPathAnyType extends XPathType<Object> {
  const new();

  @override
  String get name => 'item()';

  @override
  bool get isAtomic => false;

  @override
  bool matches(Object value) => true;

  @override
  Object cast(Object value) => value;
}

/// The XPath anyAtomicType type.
const xsAnyAtomicType = _XPathAnyAtomicType();

class _XPathAnyAtomicType extends XPathType<Object> {
  const new();

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
  const new();

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

/// The XPath untypedAtomic type.
const xsUntypedAtomic = _XPathUntypedAtomicType();

class _XPathUntypedAtomicType extends XPathType<XPathUntypedAtomic> {
  const new();

  @override
  String get name => 'xs:untypedAtomic';

  @override
  bool get isAtomic => true;

  @override
  bool matches(Object value) => value is XPathUntypedAtomic;

  @override
  XPathUntypedAtomic cast(Object value) => switch (value) {
    XPathUntypedAtomic() => value,
    XmlNode() => XPathUntypedAtomic(xsNode.castToString(value)),
    XPathSequence() => _castSequence(value),
    _ => XPathUntypedAtomic(xsString.cast(value)),
  };

  XPathUntypedAtomic _castSequence(XPathSequence sequence) {
    final iterator = sequence.iterator;
    if (!iterator.moveNext()) {
      throw XPathEvaluationException.unsupportedCast(this, sequence);
    }
    final item = iterator.current;
    if (!iterator.moveNext()) return cast(item);
    throw XPathEvaluationException.unsupportedCast(this, sequence);
  }
}
