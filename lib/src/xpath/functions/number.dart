import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../xdm/atomic.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/function.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

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

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
final fnAbs = XPathFunctionItem.fn1(const XmlName.qualified('fn:abs'), (
  context,
  arg,
) {
  final item = arg.atomize().firstOrNull;
  if (item == null) return XPathSequence.empty;
  if (item is! XPathNumeric) return XPathSequence.empty;
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
  final item = arg.atomize().firstOrNull;
  if (item == null) return XPathSequence.empty;
  if (item is! XPathNumeric) return XPathSequence.empty;
  return switch (item) {
    final XPathInteger i => XPathSequence.single(i),
    final XPathDecimal d => XPathSequence.single(
      XPathDecimal.fromBigInt(
        d.scale == 0 ? d.unscaledValue : BigInt.from(d.toDouble().ceil()),
      ),
    ),
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
  final item = arg.atomize().firstOrNull;
  if (item == null) return XPathSequence.empty;
  if (item is! XPathNumeric) return XPathSequence.empty;
  return switch (item) {
    final XPathInteger i => XPathSequence.single(i),
    final XPathDecimal d => XPathSequence.single(
      XPathDecimal.fromBigInt(
        d.scale == 0 ? d.unscaledValue : BigInt.from(d.toDouble().floor()),
      ),
    ),
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
      (context, arg) =>
          _evalRound(arg.atomize().firstOrNull as XPathNumeric?, null),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:round'),
      (context, arg, precision) => _evalRound(
        arg.atomize().firstOrNull as XPathNumeric?,
        precision.atomize().firstOrNull as XPathInteger?,
      ),
    ),
  },
);

XPathSequence _evalRound(XPathNumeric? arg, XPathInteger? precision) {
  if (arg == null) return XPathSequence.empty;
  final p = precision?.asInt ?? 0;
  if (arg is XPathDouble) {
    final val = arg.value;
    if (val.isNaN || val.isInfinite || val == 0.0) {
      return XPathSequence.single(arg);
    }
    final factor = math.pow(10, p);
    final scaled = val * factor;
    final floor = scaled.floorToDouble();
    final diff = scaled - floor;
    final rounded = (diff == 0.5) ? floor + 1.0 : scaled.roundToDouble();
    final result = rounded / factor;
    if (result == 0.0 && val.isNegative) {
      return XPathSequence.single(XPathDouble(-0.0, arg.type));
    }
    return XPathSequence.single(XPathDouble(result, arg.type));
  } else if (arg is XPathInteger) {
    if (p >= 0) return XPathSequence.single(arg);
    final factor = BigInt.from(10).pow(-p);
    final val = arg.value;
    final div = val ~/ factor;
    final rem = (val % factor).abs();
    final half = factor ~/ BigInt.two;
    final rounded = rem >= half
        ? (val.isNegative
              ? (div - BigInt.one) * factor
              : (div + BigInt.one) * factor)
        : div * factor;
    return XPathSequence.single(XPathInteger(rounded, arg.type));
  } else if (arg is XPathDecimal) {
    final val = arg.toDouble();
    final factor = math.pow(10, p);
    final scaled = val * factor;
    final floor = scaled.floorToDouble();
    final diff = scaled - floor;
    final rounded = (diff == 0.5) ? floor + 1.0 : scaled.roundToDouble();
    final result = rounded / factor;
    return XPathSequence.single(XPathDecimal.fromNum(result));
  }
  return XPathSequence.single(arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
final fnRoundHalfToEven = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:round-half-to-even'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:round-half-to-even'),
      (context, arg) => _evalRoundHalfToEven(
        arg.atomize().firstOrNull as XPathNumeric?,
        null,
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:round-half-to-even'),
      (context, arg, precision) => _evalRoundHalfToEven(
        arg.atomize().firstOrNull as XPathNumeric?,
        precision.atomize().firstOrNull as XPathInteger?,
      ),
    ),
  },
);

XPathSequence _evalRoundHalfToEven(XPathNumeric? arg, XPathInteger? precision) {
  if (arg == null) return XPathSequence.empty;
  final p = precision?.asInt ?? 0;
  if (arg is XPathDouble) {
    final val = arg.value;
    if (val.isNaN || val.isInfinite || val == 0.0) {
      return XPathSequence.single(arg);
    }
    final factor = math.pow(10, p);
    final scaled = val * factor;
    final floor = scaled.floor();
    final diff = scaled - floor;
    final rounded = diff == 0.5
        ? (floor % 2 == 0 ? floor.toDouble() : (floor + 1).toDouble())
        : scaled.roundToDouble();
    final result = rounded / factor;
    return XPathSequence.single(XPathDouble(result, arg.type));
  }
  final val = arg.toDouble();
  final factor = math.pow(10, p);
  final scaled = val * factor;
  final floor = scaled.floor();
  final diff = scaled - floor;
  final rounded = diff == 0.5
      ? (floor % 2 == 0 ? floor : floor + 1)
      : scaled.round();
  final result = rounded / factor;
  if (arg is XPathInteger) {
    return XPathSequence.single(XPathInteger.fromInt(result.toInt(), arg.type));
  }
  return XPathSequence.single(XPathDecimal.fromNum(result));
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
  final random = math.Random(seed?.hashCode);
  final entries = <XPathAtomic, XPathSequence>{};
  entries[const XPathString('number')] = XPathSequence.single(
    XPathDouble(random.nextDouble()),
  );
  entries[const XPathString('next')] = XPathSequence.single(
    XPathFunction(
      name: const XmlName.parts('next'),
      arity: 0,
      function: (XPathContext c, List<XPathSequence> args) =>
          XPathSequence.single(
            XPathMap({
              ...entries,
              const XPathString('number'): XPathSequence.single(
                XPathDouble(random.nextDouble()),
              ),
            }),
          ),
    ),
  );
  entries[const XPathString('permute')] = XPathSequence.single(
    XPathFunction(
      name: const XmlName.parts('permute'),
      arity: 1,
      function: (XPathContext c, List<XPathSequence> args) =>
          XPathSequence(args.single.toList().shuffled(random)),
    ),
  );
  return XPathSequence.single(XPathMap(entries));
}
