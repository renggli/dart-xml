import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-add-durations
XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.single as XPathDuration) + (right.single as XPathDuration),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-durations
XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.single as XPathDuration) - (right.single as XPathDuration),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-duration
XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = left.single as XPathDuration;
  final factor = (right.single as XPathNumeric).toDouble();
  if (factor.isNaN) {
    throw XPathEvaluationException(
      XPathErrorCode.FOCA0005,
      'NaN multiplier in duration multiplication',
    );
  }
  if (factor.isInfinite) {
    throw XPathEvaluationException(
      XPathErrorCode.FODT0002,
      'Overflow: duration multiplication by Infinity',
    );
  }
  return XPathSequence.single(duration * factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-duration
XPathSequence opDivideDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = left.single as XPathDuration;
  final divisor = (right.single as XPathNumeric).toDouble();
  if (divisor.isNaN) {
    throw XPathEvaluationException(
      XPathErrorCode.FOCA0005,
      'NaN divisor in duration division',
    );
  }
  if (divisor.isInfinite) {
    return XPathSequence.single(XPathDuration(type: duration.type));
  }
  if (divisor == 0.0) {
    throw XPathEvaluationException(XPathErrorCode.FODT0002, 'Division by zero');
  }
  final resMonths = duration.totalMonths / divisor;
  final resMicroseconds = duration.totalMicroseconds / divisor;
  if (resMonths.isInfinite || resMicroseconds.isInfinite) {
    throw XPathEvaluationException(
      XPathErrorCode.FODT0002,
      'Overflow: duration division overflow',
    );
  }
  return XPathSequence.single(duration / divisor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-duration-by-duration
XPathSequence opDivideDurationByDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final divisor = right.single as XPathDuration;
  if ((d1.isYearMonth && divisor.isYearMonth) ||
      (d1.isDayTime && divisor.isDayTime)) {
    if (d1.isYearMonth && divisor.totalMonths == 0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero',
      );
    }
    if (d1.isDayTime && divisor.totalMicroseconds == 0) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAR0001,
        'Division by zero',
      );
    }
    return XPathSequence.single(XPathDouble(d1.divideByDuration(divisor)));
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot divide ${d1.type} by ${divisor.type}',
  );
}
