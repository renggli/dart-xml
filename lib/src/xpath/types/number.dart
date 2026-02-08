import '../../xml/nodes/node.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';
import 'string.dart';

/// The XPath numeric type.
const xsNumeric = _XPathNumericType();

class _XPathNumericType extends XPathType<num> {
  const _XPathNumericType();

  @override
  String get name => 'xs:numeric';

  @override
  bool matches(Object value) => value is num;

  @override
  num cast(Object value) {
    if (value is num) {
      return value;
    } else if (value is Duration) {
      return value.inMicroseconds;
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      if (value == 'INF') return double.infinity;
      if (value == '-INF') return double.negativeInfinity;
      final result = num.tryParse(value);
      if (result == null) return double.nan;
      return result;
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath integer type.
const xsInteger = _XPathIntegerType();

class _XPathIntegerType extends XPathType<int> {
  const _XPathIntegerType();

  @override
  String get name => 'xs:integer';

  @override
  Iterable<String> get aliases => const [
    'xs:byte',
    'xs:decimal',
    'xs:int',
    'xs:long',
    'xs:negativeInteger',
    'xs:nonNegativeInteger',
    'xs:nonPositiveInteger',
    'xs:short',
    'xs:unsignedByte',
    'xs:unsignedInt',
    'xs:unsignedLong',
    'xs:unsignedShort',
  ];

  @override
  bool matches(Object value) => value is int;

  @override
  int cast(Object value) {
    if (value is int) {
      return value;
    } else if (value is num) {
      if (value.isInfinite || value.isNaN) {
        throw XPathEvaluationException('Invalid value: $value');
      }
      return value.toInt();
    } else if (value is Duration) {
      return value.inMicroseconds;
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      final result = int.tryParse(value);
      if (result != null) return result;
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath double type.
const xsDouble = _XPathDoubleType();

class _XPathDoubleType extends XPathType<double> {
  const _XPathDoubleType();

  @override
  String get name => 'xs:double';

  @override
  Iterable<String> get aliases => const ['xs:float'];

  @override
  bool matches(Object value) => value is double;

  @override
  double cast(Object value) {
    if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    } else if (value is Duration) {
      return value.inMicroseconds.toDouble();
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      if (value == 'INF') return double.infinity;
      if (value == '-INF') return double.negativeInfinity;
      final result = double.tryParse(value);
      if (result == null) return double.nan;
      return result;
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
