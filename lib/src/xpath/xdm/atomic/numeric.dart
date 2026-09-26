import 'dart:math' as math;
import 'dart:typed_data';

import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

final _float32Holder = Float32List(1);

/// Converts a 64-bit Dart [double] to a 32-bit single-precision IEEE 754 float.
double roundToFloat(double value) {
  _float32Holder[0] = value;
  return _float32Holder[0];
}

/// Sealed base class for all XDM numeric atomic values.
sealed class XPathNumeric extends XPathAtomic {
  const new();

  @override
  bool get isNumeric => true;

  double toDouble();
  BigInt toBigInt();
  XPathDecimal toDecimal();

  XPathNumeric operator +(XPathNumeric other);
  XPathNumeric operator -(XPathNumeric other);
  XPathNumeric operator *(XPathNumeric other);
  XPathNumeric operator /(XPathNumeric other);
  XPathInteger idiv(XPathNumeric other);
  XPathNumeric operator %(XPathNumeric other);
  XPathNumeric operator -();
}

/// Arbitrary-precision integer (xs:integer and subtypes).
final class XPathInteger extends XPathNumeric {
  new(this.value, [this.type = xsInteger]);

  factory fromInt(int val, [XPathType type = xsInteger]) =>
      XPathInteger(BigInt.from(val), type);

  factory parse(String text, [XPathType type = xsInteger]) =>
      XPathInteger(BigInt.parse(text.trim()), type);

  static final zero = XPathInteger(BigInt.zero);

  @override
  final BigInt value;

  @override
  final XPathType type;

  @override
  String get stringValue => value.toString();

  @override
  bool get effectiveBooleanValue => value != BigInt.zero;

  @override
  double toDouble() => value.toDouble();

  @override
  BigInt toBigInt() => value;

  /// Returns the value as a Dart [int].
  int get asInt => value.toInt();

  @override
  Object toValue() => value.isValidInt ? value.toInt() : value;

  @override
  XPathDecimal toDecimal() => XPathDecimal(value, 0);

  @override
  XPathNumeric operator +(XPathNumeric other) => switch (other) {
    final XPathInteger i => XPathInteger(value + i.value),
    final XPathDecimal d => toDecimal() + d,
    final XPathDouble d => XPathDouble(toDouble() + d.value),
  };

  @override
  XPathNumeric operator -(XPathNumeric other) => switch (other) {
    final XPathInteger i => XPathInteger(value - i.value),
    final XPathDecimal d => toDecimal() - d,
    final XPathDouble d => XPathDouble(toDouble() - d.value),
  };

  @override
  XPathNumeric operator *(XPathNumeric other) => switch (other) {
    final XPathInteger i => XPathInteger(value * i.value),
    final XPathDecimal d => toDecimal() * d,
    final XPathDouble d => XPathDouble(toDouble() * d.value),
  };

  @override
  XPathNumeric operator /(XPathNumeric other) => switch (other) {
    final XPathInteger i => toDecimal() / i.toDecimal(),
    final XPathDecimal d => toDecimal() / d,
    final XPathDouble d => XPathDouble(toDouble() / d.value),
  };

  @override
  XPathInteger idiv(XPathNumeric other) => switch (other) {
    final XPathInteger i =>
      i.value == BigInt.zero
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0001,
              'Division by zero',
            )
          : XPathInteger(value ~/ i.value),
    final XPathDecimal d => toDecimal().idiv(d),
    final XPathDouble d =>
      d.value == 0
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0001,
              'Division by zero in idiv',
            )
          : d.value.isNaN
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0002,
              'NaN in idiv',
            )
          : d.value.isInfinite
          ? XPathInteger(BigInt.zero)
          : XPathDouble(toDouble()).idiv(d),
  };

  @override
  XPathNumeric operator %(XPathNumeric other) => switch (other) {
    final XPathInteger i =>
      i.value == BigInt.zero
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0001,
              'Division by zero in mod',
            )
          : XPathInteger(value.remainder(i.value)),
    final XPathDecimal d => toDecimal() % d,
    final XPathDouble d => XPathDouble(toDouble().remainder(d.value)),
  };

  @override
  XPathInteger operator -() => XPathInteger(-value, type);

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathInteger) return value.compareTo(other.value);
    if (other is XPathDecimal) return toDecimal().compareTo(other);
    if (other is XPathDouble) {
      if (other.value.isNaN) return -1;
      final d = toDouble();
      if (d == other.value) return 0;
      return d.compareTo(other.value);
    }
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathInteger) return value == other.value;
    if (other is XPathDecimal) return toDecimal() == other;
    if (other is XPathDouble) {
      return !other.value.isNaN && toDouble() == other.value;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Arbitrary-precision decimal (xs:decimal).
final class XPathDecimal extends XPathNumeric {
  factory(BigInt unscaled, int scale) {
    final (u, s) = _normalize(unscaled, scale);
    return XPathDecimal._raw(u, s);
  }

  const new _raw(this.unscaledValue, this.scale);

  factory fromInt(int val) => XPathDecimal._raw(BigInt.from(val), 0);

  factory fromBigInt(BigInt val) => XPathDecimal._raw(val, 0);

  factory fromNum(num val) {
    if (val is int) return XPathDecimal.fromInt(val);
    final text = val.toString();
    return XPathDecimal.parse(text);
  }

  factory parse(String text) {
    final trimmed = text.trim();
    if (trimmed.contains('e') || trimmed.contains('E')) {
      final parts = trimmed.split(RegExp(r'[eE]'));
      final mantissa = XPathDecimal.parse(parts[0]);
      final exp = int.parse(parts[1]);
      final newScale = mantissa.scale - exp;
      if (newScale >= 0) {
        return XPathDecimal(mantissa.unscaledValue, newScale);
      } else {
        return XPathDecimal(mantissa.unscaledValue * _ten.pow(-newScale), 0);
      }
    }
    final dot = trimmed.indexOf('.');
    if (dot == -1) {
      return XPathDecimal(BigInt.parse(trimmed), 0);
    }
    final scale = trimmed.length - dot - 1;
    final digits = trimmed.replaceFirst('.', '');
    return XPathDecimal(BigInt.parse(digits), scale);
  }

  static (BigInt, int) _normalize(BigInt unscaled, int scale) {
    if (unscaled == BigInt.zero) return (BigInt.zero, 0);
    var u = unscaled;
    var s = scale;
    while (s > 0 && u % _ten == BigInt.zero) {
      u ~/= _ten;
      s--;
    }
    return (u, s);
  }

  static final BigInt _ten = BigInt.from(10);
  static final zero = XPathDecimal(BigInt.zero, 0);

  final BigInt unscaledValue;
  final int scale;

  @override
  Object get value => this;

  @override
  XPathType get type => xsDecimal;

  @override
  String get stringValue {
    if (scale == 0) return unscaledValue.toString();
    final isNegative = unscaledValue < BigInt.zero;
    final absDigits = (isNegative ? -unscaledValue : unscaledValue).toString();
    final String full;
    if (absDigits.length <= scale) {
      final zeros = '0' * (scale - absDigits.length);
      full = '0.$zeros$absDigits';
    } else {
      final dotIndex = absDigits.length - scale;
      full =
          '${absDigits.substring(0, dotIndex)}.${absDigits.substring(dotIndex)}';
    }
    return isNegative ? '-$full' : full;
  }

  @override
  bool get effectiveBooleanValue => unscaledValue != BigInt.zero;

  @override
  double toDouble() {
    if (scale == 0) return unscaledValue.toDouble();
    return unscaledValue.toDouble() / math.pow(10, scale);
  }

  @override
  BigInt toBigInt() {
    if (scale == 0) return unscaledValue;
    return unscaledValue ~/ _ten.pow(scale);
  }

  @override
  Object toValue() => scale == 0 && unscaledValue.isValidInt
      ? unscaledValue.toInt()
      : toDouble();

  @override
  XPathDecimal toDecimal() => this;

  @override
  XPathNumeric operator +(XPathNumeric other) => switch (other) {
    final XPathInteger i => this + i.toDecimal(),
    final XPathDecimal d => _addDecimal(d),
    final XPathDouble d => XPathDouble(toDouble() + d.value),
  };

  XPathDecimal _addDecimal(XPathDecimal other) {
    if (scale == other.scale) {
      return XPathDecimal(unscaledValue + other.unscaledValue, scale);
    }
    final maxScale = math.max(scale, other.scale);
    final u1 = unscaledValue * _ten.pow(maxScale - scale);
    final u2 = other.unscaledValue * _ten.pow(maxScale - other.scale);
    return XPathDecimal(u1 + u2, maxScale);
  }

  @override
  XPathNumeric operator -(XPathNumeric other) => switch (other) {
    final XPathInteger i => this - i.toDecimal(),
    final XPathDecimal d => _subDecimal(d),
    final XPathDouble d => XPathDouble(toDouble() - d.value),
  };

  XPathDecimal _subDecimal(XPathDecimal other) {
    if (scale == other.scale) {
      return XPathDecimal(unscaledValue - other.unscaledValue, scale);
    }
    final maxScale = math.max(scale, other.scale);
    final u1 = unscaledValue * _ten.pow(maxScale - scale);
    final u2 = other.unscaledValue * _ten.pow(maxScale - other.scale);
    return XPathDecimal(u1 - u2, maxScale);
  }

  @override
  XPathNumeric operator *(XPathNumeric other) => switch (other) {
    final XPathInteger i => this * i.toDecimal(),
    final XPathDecimal d => XPathDecimal(
      unscaledValue * d.unscaledValue,
      scale + d.scale,
    ),
    final XPathDouble d => XPathDouble(toDouble() * d.value),
  };

  @override
  XPathNumeric operator /(XPathNumeric other) => switch (other) {
    final XPathInteger i => this / i.toDecimal(),
    final XPathDecimal d => _divDecimal(d),
    final XPathDouble d => XPathDouble(toDouble() / d.value),
  };

  XPathDecimal _divDecimal(XPathDecimal other) {
    if (other.unscaledValue == BigInt.zero) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero',
      );
    }
    const precision = 20;
    final shift = precision + other.scale - scale;
    final BigInt scaledDividend;
    final int resultScale;
    if (shift >= 0) {
      scaledDividend = unscaledValue * _ten.pow(shift);
      resultScale = precision;
    } else {
      scaledDividend = unscaledValue ~/ _ten.pow(-shift);
      resultScale = 0;
    }
    final quotient = scaledDividend ~/ other.unscaledValue;
    return XPathDecimal(quotient, resultScale);
  }

  @override
  XPathInteger idiv(XPathNumeric other) => switch (other) {
    final XPathInteger i => idiv(i.toDecimal()),
    final XPathDecimal d =>
      d.unscaledValue == BigInt.zero
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0001,
              'Division by zero in idiv',
            )
          : () {
              final maxScale = math.max(scale, d.scale);
              final u1 = unscaledValue * _ten.pow(maxScale - scale);
              final u2 = d.unscaledValue * _ten.pow(maxScale - d.scale);
              return XPathInteger(u1 ~/ u2);
            }(),
    final XPathDouble d =>
      d.value == 0
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0001,
              'Division by zero in idiv',
            )
          : d.value.isNaN
          ? throw XPathEvaluationException(
              XPathErrorCode.FOAR0002,
              'NaN in idiv',
            )
          : d.value.isInfinite
          ? XPathInteger(BigInt.zero)
          : XPathDouble(toDouble()).idiv(d),
  };

  @override
  XPathNumeric operator %(XPathNumeric other) => switch (other) {
    final XPathInteger i => this % i.toDecimal(),
    final XPathDecimal d => _modDecimal(d),
    final XPathDouble d => XPathDouble(toDouble() % d.value),
  };

  XPathDecimal _modDecimal(XPathDecimal other) {
    if (other.unscaledValue == BigInt.zero) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero in mod',
      );
    }
    final maxScale = math.max(scale, other.scale);
    final u1 = unscaledValue * _ten.pow(maxScale - scale);
    final u2 = other.unscaledValue * _ten.pow(maxScale - other.scale);
    return XPathDecimal(u1.remainder(u2), maxScale);
  }

  @override
  XPathDecimal operator -() => XPathDecimal(-unscaledValue, scale);

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathInteger) return compareTo(other.toDecimal());
    if (other is XPathDecimal) {
      final maxScale = math.max(scale, other.scale);
      final u1 = unscaledValue * _ten.pow(maxScale - scale);
      final u2 = other.unscaledValue * _ten.pow(maxScale - other.scale);
      return u1.compareTo(u2);
    }
    if (other is XPathDouble) {
      if (other.value.isNaN) return -1;
      final d = toDouble();
      if (d == other.value) return 0;
      return d.compareTo(other.value);
    }
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathInteger) return this == other.toDecimal();
    if (other is XPathDecimal) {
      return unscaledValue == other.unscaledValue && scale == other.scale;
    }
    if (other is XPathDouble) {
      return !other.value.isNaN && toDouble() == other.value;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(unscaledValue, scale);
}

/// 64-bit IEEE 754 float (xs:double and xs:float).
final class XPathDouble extends XPathNumeric {
  const new(this.value, [this.type = xsDouble]);

  static const nan = XPathDouble(double.nan);
  static const infinity = XPathDouble(double.infinity);
  static const negativeInfinity = XPathDouble(double.negativeInfinity);
  static const zero = XPathDouble(0.0);

  factory parse(String text, [XPathType type = xsDouble]) =>
      tryParse(text, type) ??
      (throw FormatException('Invalid float/double: "$text"'));

  static XPathDouble? tryParse(String text, [XPathType type = xsDouble]) {
    final trimmed = text.trim();
    if (trimmed == 'INF' || trimmed == '+INF') {
      return type == xsDouble ? infinity : XPathDouble(double.infinity, type);
    }
    if (trimmed == '-INF') {
      return type == xsDouble
          ? negativeInfinity
          : XPathDouble(double.negativeInfinity, type);
    }
    if (trimmed == 'NaN') {
      return type == xsDouble ? nan : XPathDouble(double.nan, type);
    }
    final val = double.tryParse(trimmed);
    if (val == null) return null;
    return XPathDouble(type == xsFloat ? roundToFloat(val) : val, type);
  }

  @override
  final double value;

  @override
  final XPathType type;

  @override
  String get stringValue {
    if (value.isNaN) return 'NaN';
    if (value == double.infinity) return 'INF';
    if (value == double.negativeInfinity) return '-INF';
    if (value == 0.0) return value.isNegative ? '-0' : '0';
    var d = value;
    if (type == xsFloat) {
      for (var p = 1; p <= 9; p++) {
        final candidate = double.parse(value.toStringAsPrecision(p));
        if (roundToFloat(candidate) == value) {
          d = candidate;
          break;
        }
      }
    }
    final abs = d.abs();
    if (abs >= 1e-6 && abs < 1e6) {
      final s = d.toString();
      return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    }
    return _toXPathScientific(d);
  }

  @override
  bool get effectiveBooleanValue => !value.isNaN && value != 0.0;

  @override
  double toDouble() => value;

  @override
  BigInt toBigInt() {
    if (value.isNaN || value.isInfinite) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Cannot convert $value to xs:integer',
      );
    }
    if (value.abs() > 9223372036854775807.0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0003,
        'Float value too large for integer: $value',
      );
    }
    return BigInt.from(value.toInt());
  }

  @override
  XPathDecimal toDecimal() {
    if (value.isNaN || value.isInfinite) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0002,
        'Cannot convert $value to xs:decimal',
      );
    }
    if (value.abs() >= 1e100) {
      throw XPathEvaluationException(
        XPathErrorCode.FOCA0001,
        'Float value too large for decimal: $value',
      );
    }
    return XPathDecimal.parse(value.toString());
  }

  @override
  XPathNumeric operator +(XPathNumeric other) =>
      XPathDouble(value + other.toDouble());

  @override
  XPathNumeric operator -(XPathNumeric other) =>
      XPathDouble(value - other.toDouble());

  @override
  XPathNumeric operator *(XPathNumeric other) =>
      XPathDouble(value * other.toDouble());

  @override
  XPathNumeric operator /(XPathNumeric other) =>
      XPathDouble(value / other.toDouble());

  @override
  XPathInteger idiv(XPathNumeric other) {
    final otherD = other.toDouble();
    if (otherD == 0.0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero in idiv',
      );
    }
    if (value.isNaN || otherD.isNaN || value.isInfinite) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0002,
        'Invalid operand in idiv',
      );
    }
    if (otherD.isInfinite) {
      return XPathInteger(BigInt.zero);
    }
    final quotient = value / otherD;
    if (quotient.isNaN ||
        quotient.isInfinite ||
        quotient.abs() > 9223372036854775807.0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0002,
        'Overflow in idiv',
      );
    }
    return XPathInteger(BigInt.from(value ~/ otherD));
  }

  @override
  XPathNumeric operator %(XPathNumeric other) {
    final otherD = other.toDouble();
    if (otherD == 0.0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero in mod',
      );
    }
    return XPathDouble(value.remainder(otherD));
  }

  @override
  XPathDouble operator -() => XPathDouble(-value, type);

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathNumeric) {
      final otherD = other.toDouble();
      if (value.isNaN || otherD.isNaN) return -1;
      if (value == otherD) return 0;
      return value.compareTo(otherD);
    }
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathNumeric) {
      final otherD = other.toDouble();
      if (value.isNaN || otherD.isNaN) return false;
      return value == otherD;
    }
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

String _toXPathScientific(double value) {
  final s = value.toString();
  if (s.contains('e') || s.contains('E')) {
    final parts = s.split(RegExp(r'[eE]'));
    var mantissa = parts[0];
    final exp = int.parse(parts[1]).toString();
    if (!mantissa.contains('.')) {
      mantissa = '$mantissa.0';
    }
    return '${mantissa}E$exp';
  }
  final sign = s.startsWith('-') ? '-' : '';
  final absStr = sign.isNotEmpty ? s.substring(1) : s;
  final dot = absStr.indexOf('.');
  final intPart = dot == -1 ? absStr : absStr.substring(0, dot);
  final fracPart = dot == -1 ? '' : absStr.substring(dot + 1);

  final exp = intPart.length - 1;
  final firstDigit = intPart[0];
  final rest = (intPart.substring(1) + fracPart).replaceAll(RegExp(r'0+$'), '');
  final mantissa = rest.isEmpty ? '$firstDigit.0' : '$firstDigit.$rest';
  return '$sign${mantissa}E$exp';
}
