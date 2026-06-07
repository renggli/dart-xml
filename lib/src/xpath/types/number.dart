import '../../xml/nodes/node.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/duration.dart';
import '../values/sequence.dart';
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
  num cast(Object value) => switch (value) {
    num() => value,
    Duration() => value.inMicroseconds,
    XPathDayTimeDuration() => value.inMicroseconds,
    XPathYearMonthDuration() => value.totalMonths,
    bool() => value ? 1 : 0,
    String() => _parseNumeric(value.trim()),
    XmlNode() => cast(xsString.cast(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  num _parseNumeric(String trimmed) {
    if (trimmed == 'INF') return double.infinity;
    if (trimmed == '-INF') return double.negativeInfinity;
    if (trimmed == 'NaN') return double.nan;
    if (_doublePattern.hasMatch(trimmed)) {
      return num.parse(trimmed);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(num value) => _castNumberToString(value);
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
  num cast(Object value) => switch (value) {
    num() when value.isFinite => value,
    Duration() => value.inMicroseconds,
    XPathDayTimeDuration() => value.inMicroseconds,
    XPathYearMonthDuration() => value.totalMonths,
    bool() => value ? 1 : 0,
    String() => _parseDecimal(value.trim()),
    XmlNode() => cast(xsString.cast(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  num _parseDecimal(String trimmed) {
    if (_decimalPattern.hasMatch(trimmed)) {
      return num.parse(trimmed);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(num value) => _castNumberToString(value);
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
  int cast(Object value) => switch (value) {
    int() => value,
    num() when value.isFinite => value.toInt(),
    Duration() => value.inMicroseconds,
    XPathDayTimeDuration() => value.inMicroseconds,
    XPathYearMonthDuration() => value.totalMonths,
    bool() => value ? 1 : 0,
    String() => _parseInteger(value.trim()),
    XmlNode() => cast(xsString.cast(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  int _parseInteger(String trimmed) {
    if (_integerPattern.hasMatch(trimmed)) {
      return int.parse(trimmed);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(int value) => _castNumberToString(value);
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

  @override
  String castToString(int value) => _castNumberToString(value);
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
  double cast(Object value) => switch (value) {
    double() => value,
    num() => value.toDouble(),
    Duration() => value.inMicroseconds.toDouble(),
    XPathDayTimeDuration() => value.inMicroseconds.toDouble(),
    XPathYearMonthDuration() => value.totalMonths.toDouble(),
    bool() => value ? 1 : 0,
    String() => _parseDouble(value.trim()),
    XmlNode() => cast(xsString.cast(value)),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  double _parseDouble(String trimmed) {
    if (trimmed == 'INF') return double.infinity;
    if (trimmed == '-INF') return double.negativeInfinity;
    if (trimmed == 'NaN') return double.nan;
    if (_doublePattern.hasMatch(trimmed)) {
      return double.parse(trimmed);
    }
    throw XPathEvaluationException.unsupportedCast(this, trimmed);
  }

  @override
  String castToString(double value) => _castNumberToString(value);
}

final _doublePattern = RegExp(r'^(\+|-)?\d+(\.\d*)?(\.\d+)?([eE][+-]?\d+)?$');
final _decimalPattern = RegExp(r'^(\+|-)?(\d+(\.\d*)?|\.\d+)$');
final _integerPattern = RegExp(r'^(\+|-)?\d+$');

String _castNumberToString(num value) {
  if (value.isNaN) return 'NaN';
  if (value == double.infinity) return 'INF';
  if (value == double.negativeInfinity) return '-INF';
  if (value == 0.0 || value == -0.0) return '0';
  final string = value.toString();
  return string.endsWith('.0')
      ? string.substring(0, string.length - 2)
      : string;
}
