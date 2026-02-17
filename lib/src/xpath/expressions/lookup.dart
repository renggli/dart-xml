import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/array.dart';
import '../types/map.dart';
import '../types/sequence.dart';

/// A postfix lookup expression (`expr?key`).
///
/// https://www.w3.org/TR/xpath-31/#id-postfix-lookup
class LookupExpression implements XPathExpression {
  const LookupExpression(this.base, this.key);

  /// The base expression to look up into.
  final XPathExpression base;

  /// The key specifier, or `null` for wildcard (`?*`).
  final XPathExpression? key;

  @override
  XPathSequence call(XPathContext context) {
    final items = base(context);
    return XPathSequence(items.expand((item) => _lookup(context, item)));
  }

  Iterable<Object> _lookup(XPathContext context, Object item) {
    if (key == null) return _lookupWildcard(item);
    final keyValue = key!(context).single;
    return _lookupKey(item, keyValue);
  }
}

/// A unary lookup expression (`?key`), using the context item as base.
///
/// https://www.w3.org/TR/xpath-31/#id-unary-lookup
class UnaryLookupExpression implements XPathExpression {
  const UnaryLookupExpression(this.key);

  /// The key specifier, or `null` for wildcard (`?*`).
  final XPathExpression? key;

  @override
  XPathSequence call(XPathContext context) {
    final item = context.item;
    if (key == null) {
      return XPathSequence(_lookupWildcard(item));
    }
    final keyValue = key!(context).single;
    return XPathSequence(_lookupKey(item, keyValue));
  }
}

Iterable<Object> _lookupWildcard(Object item) {
  if (item is XPathMap) {
    return item.values;
  } else if (item is XPathArray) {
    return item;
  }
  throw XPathEvaluationException(
    'Lookup requires a map or array, but got ${item.runtimeType}',
  );
}

Iterable<Object> _lookupKey(Object item, Object key) {
  if (item is XPathMap) {
    final value = item[key];
    if (value == null) return const [];
    return [value];
  } else if (item is XPathArray) {
    final index = (key as int) - 1;
    if (index < 0 || index >= item.length) {
      throw XPathEvaluationException('Array index out of bounds: ${index + 1}');
    }
    return [item[index]];
  }
  throw XPathEvaluationException(
    'Lookup requires a map or array, but got ${item.runtimeType}',
  );
}
