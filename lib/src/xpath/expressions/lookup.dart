import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// A postfix lookup expression (`expr?key`).
///
/// https://www.w3.org/TR/xpath-31/#id-postfix-lookup
class LookupExpression implements XPathExpression {
  const new(this.base, this.key);

  /// The base expression to look up into.
  final XPathExpression base;

  /// The key specifier, or `null` for wildcard (`?*`).
  final XPathExpression? key;

  @override
  XPathSequence call(XPathContext context) {
    final items = base(context);
    return XPathSequence(items.expand((item) => _lookup(context, item)));
  }

  Iterable<XPathItem> _lookup(XPathContext context, XPathItem item) {
    if (key == null) return _lookupWildcard(item);
    final keyValues = key!(context).atomize();
    return keyValues.expand((keyValue) => _lookupKey(item, keyValue));
  }
}

/// A unary lookup expression (`?key`), using the context item as base.
///
/// https://www.w3.org/TR/xpath-31/#id-unary-lookup
class UnaryLookupExpression implements XPathExpression {
  const new(this.key);

  /// The key specifier, or `null` for wildcard (`?*`).
  final XPathExpression? key;

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (item is! XPathItem) {
      throw XPathEvaluationException(
        XPathErrorCode.XPDY0002,
        'Context item is undefined',
      );
    }
    if (key == null) {
      return XPathSequence(_lookupWildcard(item));
    }
    final keyValues = key!(context).atomize();
    return XPathSequence(
      keyValues.expand((keyValue) => _lookupKey(item, keyValue)),
    );
  }
}

/// A helper wrapping a key specifier for the lookup postfix.
class LookupKey {
  const new(this.key);

  /// The key specifier expression, or `null` for wildcard (`?*`).
  final XPathExpression? key;
}

Iterable<XPathItem> _lookupWildcard(XPathItem item) => switch (item) {
  XPathMap() => item.entries.values.expand((v) => v),
  XPathArray() => item.members.expand((m) => m),
  _ => throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Lookup requires a map or array, but got ${item.type}',
  ),
};

Iterable<XPathItem> _lookupKey(XPathItem item, XPathItem key) => switch (item) {
  XPathMap() => _lookupMapKey(item, key),
  XPathArray() => _lookupArrayKey(item, key),
  _ => throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Lookup requires a map or array, but got ${item.type}',
  ),
};

Iterable<XPathItem> _lookupMapKey(XPathMap map, XPathItem key) {
  final atomicKey = key.atomize();
  final value = map.get(atomicKey);
  return value ?? const [];
}

Iterable<XPathItem> _lookupArrayKey(XPathArray array, XPathItem key) {
  final atomicKey = key.atomize();
  if (atomicKey is! XPathNumeric) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Array lookup key must be an integer, got ${atomicKey.type}',
    );
  }
  final index = atomicKey.toBigInt().toInt();
  if (index < 1 || index > array.length) {
    return const [];
  }
  return array[index - 1];
}
