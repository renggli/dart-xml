import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-number
final fnNumber = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:number'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:number'),
      (context) => _evalNumber(context.item as XPathItem?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:number'),
      (context, arg) => _evalNumber(arg.atomize().firstOrNull),
    ),
  },
);

XPathSequence _evalNumber(XPathItem? arg) {
  if (arg == null) return const XPathSequence.single(XPathDouble.nan);
  if (arg is XPathNumeric) {
    return XPathSequence.single(XPathDouble(arg.toDouble()));
  }
  if (arg is XPathBoolean) {
    return XPathSequence.single(XPathDouble(arg.value ? 1.0 : 0.0));
  }
  final text = arg.stringValue.trim();
  final d = double.tryParse(text);
  if (d != null) return XPathSequence.single(XPathDouble(d));
  return const XPathSequence.single(XPathDouble.nan);
}

XPathNumeric? _coerceNumericArg(XPathSequence arg) {
  final items = arg.atomize();
  if (items.isEmpty) return null;
  if (items.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected at most one item, got ${items.length}',
    );
  }
  final item = items.first;
  if (item is XPathNumeric) return item;
  if (item is XPathUntypedAtomic) {
    final d = double.tryParse(item.stringValue);
    if (d != null) return XPathDouble(d);
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot cast untypedAtomic to numeric',
    );
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Expected numeric item, but got $item',
  );
}

XPathInteger? _coerceIntegerArg(XPathSequence arg) {
  final items = arg.atomize();
  if (items.isEmpty) return null;
  if (items.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected at most one item, got ${items.length}',
    );
  }
  final item = items.first;
  if (item is XPathInteger) return item;
  if (item is XPathUntypedAtomic) {
    final b = BigInt.tryParse(item.stringValue);
    if (b != null) return XPathInteger(b);
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot cast untypedAtomic to integer',
    );
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Expected integer item, but got $item',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
final fnAbs = XPathFunctionItem.fn1(const XmlName.qualified('fn:abs'), (
  context,
  arg,
) {
  final item = _coerceNumericArg(arg);
  if (item == null) return XPathSequence.empty;
  return switch (item) {
    final XPathInteger i => XPathSequence.single(
      XPathInteger(i.value.abs(), i.type),
    ),
    final XPathDecimal d => XPathSequence.single(
      XPathDecimal(d.unscaledValue.abs(), d.scale),
    ),
    final XPathDouble d => XPathSequence.single(
      XPathDouble(d.value.abs(), d.type),
    ),
  };
});

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
final fnCeiling = XPathFunctionItem.fn1(const XmlName.qualified('fn:ceiling'), (
  context,
  arg,
) {
  final item = _coerceNumericArg(arg);
  if (item == null) return XPathSequence.empty;
  return switch (item) {
    final XPathInteger i => XPathSequence.single(i),
    final XPathDecimal d => XPathSequence.single(() {
      if (d.scale == 0) return d;
      final factor = BigInt.from(10).pow(d.scale);
      final q = d.unscaledValue ~/ factor;
      final r = d.unscaledValue.remainder(factor);
      final roundedQ = (r > BigInt.zero) ? q + BigInt.one : q;
      return XPathDecimal(roundedQ, 0);
    }()),
    final XPathDouble d => XPathSequence.single(
      d.value.isNaN || d.value.isInfinite
          ? d
          : XPathDouble(d.value.ceilToDouble(), d.type),
    ),
  };
});

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
final fnFloor = XPathFunctionItem.fn1(const XmlName.qualified('fn:floor'), (
  context,
  arg,
) {
  final item = _coerceNumericArg(arg);
  if (item == null) return XPathSequence.empty;
  return switch (item) {
    final XPathInteger i => XPathSequence.single(i),
    final XPathDecimal d => XPathSequence.single(() {
      if (d.scale == 0) return d;
      final factor = BigInt.from(10).pow(d.scale);
      final q = d.unscaledValue ~/ factor;
      final r = d.unscaledValue.remainder(factor);
      final roundedQ = (r < BigInt.zero) ? q - BigInt.one : q;
      return XPathDecimal(roundedQ, 0);
    }()),
    final XPathDouble d => XPathSequence.single(
      d.value.isNaN || d.value.isInfinite
          ? d
          : XPathDouble(d.value.floorToDouble(), d.type),
    ),
  };
});

/// https://www.w3.org/TR/xpath-functions-31/#func-round
final fnRound = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:round'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:round'),
      (context, arg) => _evalRound(_coerceNumericArg(arg), null),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:round'),
      (context, arg, precision) =>
          _evalRound(_coerceNumericArg(arg), _coerceIntegerArg(precision)),
    ),
  },
);

XPathSequence _evalRound(XPathNumeric? arg, XPathInteger? precision) {
  if (arg == null) return XPathSequence.empty;
  if (precision != null && precision.value > BigInt.from(1000)) {
    return XPathSequence.single(arg);
  }
  if (precision != null && precision.value < BigInt.from(-1000)) {
    return XPathSequence.single(switch (arg) {
      final XPathDouble d => XPathDouble(
        d.value.isNegative ? -0.0 : 0.0,
        d.type,
      ),
      final XPathInteger i => XPathInteger(BigInt.zero, i.type),
      XPathDecimal _ => XPathDecimal.zero,
    });
  }
  final p = precision?.asInt ?? 0;
  if (arg is XPathDouble) {
    final val = arg.value;
    if (val.isNaN || val.isInfinite || val == 0.0) {
      return XPathSequence.single(arg);
    }
    if (p > 324) return XPathSequence.single(arg);
    if (p < -324) {
      return XPathSequence.single(
        XPathDouble(val.isNegative ? -0.0 : 0.0, arg.type),
      );
    }
    if (val.abs() >= 9007199254740992.0 && p >= 0) {
      return XPathSequence.single(arg);
    }
    final factor = math.pow(10, p).toDouble();
    final scaled = val * factor;
    if (scaled.isInfinite) {
      return XPathSequence.single(
        p > 0 ? arg : XPathDouble(val.isNegative ? -0.0 : 0.0, arg.type),
      );
    }
    final floor = scaled.floorToDouble();
    final diff = scaled - floor;
    final rounded = (diff >= 0.5) ? floor + 1.0 : floor;
    var result = rounded / factor;
    if (result == 0.0 && val.isNegative) {
      result = -0.0;
    }
    if (arg.type == xsFloat) {
      result = roundToFloat(result);
    }
    return XPathSequence.single(XPathDouble(result, arg.type));
  } else if (arg is XPathInteger) {
    if (p >= 0) return XPathSequence.single(arg);
    final shift = -p;
    if (shift > 100) {
      return XPathSequence.single(XPathInteger(BigInt.zero, arg.type));
    }
    final factor = BigInt.from(10).pow(shift);
    final v = arg.value;
    final q = v ~/ factor;
    final r = v.remainder(factor);
    final BigInt roundedQ;
    if (v >= BigInt.zero) {
      roundedQ = (r * BigInt.two >= factor) ? q + BigInt.one : q;
    } else {
      roundedQ = ((-r) * BigInt.two > factor) ? q - BigInt.one : q;
    }
    return XPathSequence.single(XPathInteger(roundedQ * factor, arg.type));
  } else if (arg is XPathDecimal) {
    final shift = arg.scale - p;
    if (shift <= 0) return XPathSequence.single(arg);
    if (shift > 100) {
      return XPathSequence.single(XPathDecimal.zero);
    }
    final factor = BigInt.from(10).pow(shift);
    final v = arg.unscaledValue;
    final q = v ~/ factor;
    final r = v.remainder(factor);
    final BigInt roundedQ;
    if (v >= BigInt.zero) {
      roundedQ = (r * BigInt.two >= factor) ? q + BigInt.one : q;
    } else {
      roundedQ = ((-r) * BigInt.two > factor) ? q - BigInt.one : q;
    }
    if (p < 0) {
      final mult = BigInt.from(10).pow(-p);
      return XPathSequence.single(XPathDecimal(roundedQ * mult, 0));
    }
    return XPathSequence.single(XPathDecimal(roundedQ, p));
  }
  return XPathSequence.single(arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
final fnRoundHalfToEven = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:round-half-to-even'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:round-half-to-even'),
      (context, arg) => _evalRoundHalfToEven(_coerceNumericArg(arg), null),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:round-half-to-even'),
      (context, arg, precision) => _evalRoundHalfToEven(
        _coerceNumericArg(arg),
        _coerceIntegerArg(precision),
      ),
    ),
  },
);

XPathSequence _evalRoundHalfToEven(XPathNumeric? arg, XPathInteger? precision) {
  if (arg == null) return XPathSequence.empty;
  if (precision != null && precision.value > BigInt.from(1000)) {
    return XPathSequence.single(arg);
  }
  if (precision != null && precision.value < BigInt.from(-1000)) {
    return XPathSequence.single(switch (arg) {
      final XPathDouble d => XPathDouble(
        d.value.isNegative ? -0.0 : 0.0,
        d.type,
      ),
      final XPathInteger i => XPathInteger(BigInt.zero, i.type),
      XPathDecimal _ => XPathDecimal.zero,
    });
  }
  final p = precision?.asInt ?? 0;
  if (arg is XPathDouble) {
    final val = arg.value;
    if (val.isNaN || val.isInfinite || val == 0.0) {
      return XPathSequence.single(arg);
    }
    if (p > 324) return XPathSequence.single(arg);
    if (p < -324) {
      return XPathSequence.single(
        XPathDouble(val.isNegative ? -0.0 : 0.0, arg.type),
      );
    }
    if (val.abs() >= 9007199254740992.0 && p >= 0) {
      return XPathSequence.single(arg);
    }
    final factor = math.pow(10, p).toDouble();
    final scaled = val * factor;
    if (scaled.isInfinite) {
      return XPathSequence.single(
        p > 0 ? arg : XPathDouble(val.isNegative ? -0.0 : 0.0, arg.type),
      );
    }
    final floor = scaled.floorToDouble();
    final diff = scaled - floor;
    final double rounded;
    if ((diff - 0.5).abs() < 1e-12) {
      final isEven = (floor % 2.0).abs() == 0.0;
      rounded = isEven ? floor : floor + 1.0;
    } else if (diff > 0.5) {
      rounded = floor + 1.0;
    } else {
      rounded = floor;
    }
    var result = rounded / factor;
    if (result == 0.0 && val.isNegative) {
      result = -0.0;
    }
    if (arg.type == xsFloat) {
      result = roundToFloat(result);
    }
    return XPathSequence.single(XPathDouble(result, arg.type));
  } else if (arg is XPathInteger) {
    if (p >= 0) return XPathSequence.single(arg);
    final shift = -p;
    if (shift > 100) {
      return XPathSequence.single(XPathInteger(BigInt.zero, arg.type));
    }
    final factor = BigInt.from(10).pow(shift);
    final v = arg.value;
    final q = v ~/ factor;
    final r = v.remainder(factor);
    final BigInt roundedQ;
    if (v >= BigInt.zero) {
      final comp = (r * BigInt.two).compareTo(factor);
      if (comp > 0) {
        roundedQ = q + BigInt.one;
      } else if (comp < 0) {
        roundedQ = q;
      } else {
        roundedQ = q.isEven ? q : q + BigInt.one;
      }
    } else {
      final comp = ((-r) * BigInt.two).compareTo(factor);
      if (comp > 0) {
        roundedQ = q - BigInt.one;
      } else if (comp < 0) {
        roundedQ = q;
      } else {
        roundedQ = q.isEven ? q : q - BigInt.one;
      }
    }
    return XPathSequence.single(XPathInteger(roundedQ * factor, arg.type));
  } else if (arg is XPathDecimal) {
    final shift = arg.scale - p;
    if (shift <= 0) return XPathSequence.single(arg);
    if (shift > 100) {
      return XPathSequence.single(XPathDecimal.zero);
    }
    final factor = BigInt.from(10).pow(shift);
    final v = arg.unscaledValue;
    final q = v ~/ factor;
    final r = v.remainder(factor);
    final BigInt roundedQ;
    if (v >= BigInt.zero) {
      final comp = (r * BigInt.two).compareTo(factor);
      if (comp > 0) {
        roundedQ = q + BigInt.one;
      } else if (comp < 0) {
        roundedQ = q;
      } else {
        roundedQ = q.isEven ? q : q + BigInt.one;
      }
    } else {
      final comp = ((-r) * BigInt.two).compareTo(factor);
      if (comp > 0) {
        roundedQ = q - BigInt.one;
      } else if (comp < 0) {
        roundedQ = q;
      } else {
        roundedQ = q.isEven ? q : q - BigInt.one;
      }
    }
    if (p < 0) {
      final mult = BigInt.from(10).pow(-p);
      return XPathSequence.single(XPathDecimal(roundedQ * mult, 0));
    }
    return XPathSequence.single(XPathDecimal(roundedQ, p));
  }
  return XPathSequence.single(arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
final fnRandomNumberGenerator = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:random-number-generator'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:random-number-generator'),
      (context) => _evalRandomNumberGenerator(null),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:random-number-generator'),
      (context, seed) => _evalRandomNumberGenerator(seed.atomize().firstOrNull),
    ),
  },
);

XPathSequence _evalRandomNumberGenerator(XPathItem? seed) {
  final random = math.Random(seed != null ? (seed.hashCode & 0x7FFFFFFF) : 0);
  final entries = <XPathAtomic, XPathSequence>{};
  final map = XPathMap(entries);
  entries[const XPathString('number')] = XPathSequence.single(
    XPathDouble(random.nextDouble()),
  );
  entries[const XPathString('next')] = XPathSequence.single(
    XPathFunctionItem.fn0(const XmlName.parts('next'), (context) {
      entries[const XPathString('number')] = XPathSequence.single(
        XPathDouble(random.nextDouble()),
      );
      return XPathSequence.single(map);
    }),
  );
  entries[const XPathString('permute')] = XPathSequence.single(
    XPathFunctionItem.fn1(
      const XmlName.parts('permute'),
      (context, sequence) => XPathSequence(sequence.toList().shuffled(random)),
    ),
  );
  return XPathSequence.single(map);
}
