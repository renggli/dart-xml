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
      final trimmed = value.trim();
      if (trimmed == 'INF') return double.infinity;
      if (trimmed == '-INF') return double.negativeInfinity;
      if (trimmed == 'NaN') return double.nan;
      if (_doublePattern.hasMatch(trimmed)) {
        return num.parse(trimmed);
      }
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath decimal type.
const xsDecimal = _XPathDecimalType();

class _XPathDecimalType extends XPathType<num> {
  const _XPathDecimalType();

  @override
  String get name => 'xs:decimal';

  @override
  bool matches(Object value) => value is num;

  @override
  num cast(Object value) {
    if (value is num && value.isFinite) {
      return value;
    } else if (value is Duration) {
      return value.inMicroseconds;
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      final trimmed = value.trim();
      if (_decimalPattern.hasMatch(trimmed)) {
        return num.parse(trimmed);
      }
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

/// Range-checked integer subtypes.
const xsByte = _XPathRangeCheckedIntegerType('xs:byte', min: -128, max: 127);
const xsShort = _XPathRangeCheckedIntegerType(
  'xs:short',
  min: -32768,
  max: 32767,
);
const xsInt = _XPathRangeCheckedIntegerType(
  'xs:int',
  min: -2147483648,
  max: 2147483647,
);
const xsLong = _XPathRangeCheckedIntegerType('xs:long');
const xsUnsignedByte = _XPathRangeCheckedIntegerType(
  'xs:unsignedByte',
  min: 0,
  max: 255,
);
const xsUnsignedShort = _XPathRangeCheckedIntegerType(
  'xs:unsignedShort',
  min: 0,
  max: 65535,
);
const xsUnsignedInt = _XPathRangeCheckedIntegerType(
  'xs:unsignedInt',
  min: 0,
  max: 4294967295,
);
const xsUnsignedLong = _XPathRangeCheckedIntegerType('xs:unsignedLong', min: 0);
const xsNonNegativeInteger = _XPathRangeCheckedIntegerType(
  'xs:nonNegativeInteger',
  min: 0,
);
const xsNonPositiveInteger = _XPathRangeCheckedIntegerType(
  'xs:nonPositiveInteger',
  max: 0,
);
const xsPositiveInteger = _XPathRangeCheckedIntegerType(
  'xs:positiveInteger',
  min: 1,
);
const xsNegativeInteger = _XPathRangeCheckedIntegerType(
  'xs:negativeInteger',
  max: -1,
);

class _XPathIntegerType extends XPathType<int> {
  const _XPathIntegerType();

  @override
  String get name => 'xs:integer';

  @override
  bool matches(Object value) => value is int;

  @override
  int cast(Object value) {
    if (value is int) {
      return value;
    } else if (value is num && value.isFinite) {
      return value.toInt();
    } else if (value is Duration) {
      return value.inMicroseconds;
    } else if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      final trimmed = value.trim();
      if (_integerPattern.hasMatch(trimmed)) {
        return int.parse(trimmed);
      }
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// An integer subtype with optional range constraints.
class _XPathRangeCheckedIntegerType extends XPathType<int> {
  const _XPathRangeCheckedIntegerType(this._name, {int? min, int? max})
    : _min = min,
      _max = max;

  final String _name;
  final int? _min;
  final int? _max;

  @override
  String get name => _name;

  @override
  bool matches(Object value) => value is int;

  @override
  int cast(Object value) {
    final result = xsInteger.cast(value);
    if (_min != null && result < _min) {
      throw XPathEvaluationException('Value $result out of range for $name');
    }
    if (_max != null && result > _max) {
      throw XPathEvaluationException('Value $result out of range for $name');
    }
    return result;
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
      final trimmed = value.trim();
      if (trimmed == 'INF') return double.infinity;
      if (trimmed == '-INF') return double.negativeInfinity;
      if (trimmed == 'NaN') return double.nan;
      if (_doublePattern.hasMatch(trimmed)) {
        return double.parse(trimmed);
      }
    } else if (value is XmlNode) {
      return cast(xsString.cast(value));
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

final _doublePattern = RegExp(r'^(\+|-)?\d+(\.\d*)?(\.\d+)?([eE][+-]?\d+)?$');
final _decimalPattern = RegExp(r'^(\+|-)?(\d+(\.\d*)?|\.\d+)$');
final _integerPattern = RegExp(r'^(\+|-)?\d+$');
