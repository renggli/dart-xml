import 'dart:typed_data';

import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../evaluation/cardinality.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import 'atomic.dart';
import 'functions/array.dart';
import 'functions/map.dart';
import 'item.dart';

/// Base class for all sequences in the XDM 3.1 data model.
abstract class XPathSequence extends Iterable<XPathItem> {
  const new _();

  /// Canonical empty sequence.
  static const empty = _XPathEmptySequence();

  /// Singleton true sequence.
  static const trueSequence = _XPathSingleSequence(XPathBoolean.trueInstance);

  /// Singleton false sequence.
  static const falseSequence = _XPathSingleSequence(XPathBoolean.falseInstance);

  /// Singleton empty map sequence.
  static const emptyMap = _XPathSingleSequence(XPathMap.empty);

  /// Singleton empty array sequence.
  static const emptyArray = _XPathSingleSequence(XPathArray.empty);

  /// Creates a sequence with a single [item].
  const factory single(XPathItem item) = _XPathSingleSequence;

  /// Creates a sequence from an iterable of items.
  factory([Iterable<XPathItem>? items]) {
    if (items == null) return empty;
    final list = items is List<XPathItem> ? items : items.toList();
    if (list.isEmpty) return empty;
    if (list.length == 1) return _XPathSingleSequence(list.first);
    return _XPathListSequence(list);
  }

  /// Creates a sequence from an iterable, flattening any nested sequences.
  factory from(Iterable<Object?> items) {
    final flat = _flatten(items).toList();
    if (flat.isEmpty) return empty;
    if (flat.length == 1) return _XPathSingleSequence(flat.first);
    return _XPathListSequence(flat);
  }

  /// Creates a lazily-evaluated cached sequence.
  factory cached(Iterable<XPathItem> items) = _XPathCachedSequence;

  /// Converts an arbitrary object into a valid [XPathItem].
  static XPathItem toItem(Object obj) => switch (obj) {
    final XPathItem item => item,
    final XmlNode node => XPathNode(node),
    final XmlName name => XPathQName(name),
    final bool b => XPathBoolean(b),
    final double d when !d.isFinite => XPathDouble(d),
    final int i => XPathInteger.fromInt(i),
    final BigInt bi => XPathInteger(bi),
    final double d => XPathDouble(d),
    final String s => XPathString(s),
    final DateTime dt => XPathDateTime.fromDateTime(dt, 0),
    final Duration dur => XPathDayTimeDuration.fromDuration(dur),
    final Uint8List bytes => XPathBase64Binary(bytes),
    final Map<XPathAtomic, XPathSequence> m => XPathMap(m),
    final Map<Object, Object?> m => XPathMap({
      for (final entry in m.entries)
        toItem(entry.key) as XPathAtomic: fromObject(entry.value),
    }),
    final List<XPathSequence> l => XPathArray(l),
    final List<Object?> l => XPathArray([for (final e in l) fromObject(e)]),
    _ => throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot convert ${obj.runtimeType} to XPathItem',
    ),
  };

  /// Converts any Dart object or collection into an [XPathSequence].
  static XPathSequence fromObject(Object? value) {
    if (value == null) return empty;
    if (value is XPathSequence) return value;
    if (value is XPathItem) return XPathSequence.single(value);
    if (value is List) return XPathSequence.single(toItem(value));
    if (value is Map) return XPathSequence.single(toItem(value));
    if (value is Iterable<XPathItem>) return XPathSequence(value);
    if (value is Iterable<Object?>) return XPathSequence.from(value);
    return XPathSequence.single(toItem(value));
  }

  static Iterable<XPathItem> _flatten(Iterable<Object?> objects) sync* {
    for (final obj in objects) {
      if (obj == null) continue;
      if (obj is XPathSequence) {
        yield* obj;
      } else if (obj is Iterable<Object?>) {
        yield* _flatten(obj);
      } else {
        yield toItem(obj);
      }
    }
  }

  /// Atomizes this sequence into a list of atomic items.
  Iterable<XPathAtomic> atomize() => expand((item) {
    if (item is XPathArray) {
      return item.members.expand((member) => member.atomize());
    }
    return [item.atomize()];
  });

  /// Single item if length is 1, null otherwise.
  XPathItem? get singleOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    final item = it.current;
    if (it.moveNext()) return null;
    return item;
  }

  /// Effective Boolean Value (EBV) per W3C XPath 3.1 §2.4.3.
  bool get ebv {
    final it = iterator;
    if (!it.moveNext()) return false;
    final first = it.current;
    if (first is XPathNode) return true;
    if (!it.moveNext()) {
      return first.effectiveBooleanValue;
    }
    throw XPathEvaluationException(
      XPathErrorCode.FORG0006,
      'Invalid EBV for sequence of length > 1',
    );
  }

  /// Alias for [ebv].
  bool get effectiveBooleanValue => ebv;

  /// Returns all XML nodes in this sequence.
  Iterable<XmlNode> get nodes => whereType<XPathNode>().map((n) => n.node);

  /// Converts this sequence to a native Dart value:
  /// - `null` if empty
  /// - the unwrapped value if single item
  /// - a `List` of unwrapped values otherwise
  Object? toValue() {
    if (isEmpty) return null;
    if (length == 1) return first.toValue();
    return [for (final item in this) item.toValue()];
  }

  /// Creates a sequence representing an integer range [start] to [stop].
  static XPathSequence range(XPathInteger start, XPathInteger stop) {
    if (start.value > stop.value) return empty;
    if (stop.value - start.value > BigInt.from(10000000)) {
      throw XPathEvaluationException(
        XPathErrorCode.XPDY0130,
        'Sequence size limit exceeded',
      );
    }
    return _XPathRangeSequence(start.value, stop.value);
  }

  /// Cardinality validation.
  bool hasCardinality(XPathCardinality cardinality) => switch (cardinality) {
    XPathCardinality.zeroOrMore => true,
    XPathCardinality.oneOrMore => isNotEmpty,
    XPathCardinality.zeroOrOne => isEmpty || length == 1,
    XPathCardinality.exactlyOne => length == 1,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XPathSequence) return false;
    final it1 = iterator;
    final it2 = other.iterator;
    while (it1.moveNext()) {
      if (!it2.moveNext()) return false;
      if (it1.current != it2.current) return false;
    }
    return !it2.moveNext();
  }

  @override
  int get hashCode => Object.hashAll(this);
}

class _XPathRangeSequence extends XPathSequence {
  const new(this._start, this._end) : super._();

  final BigInt _start;
  final BigInt _end;

  @override
  int get length => (_end - _start).toInt() + 1;

  @override
  bool get isEmpty => _start > _end;

  @override
  bool get isNotEmpty => _start <= _end;

  @override
  Iterator<XPathItem> get iterator => _RangeIterator(_start, _end);
}

class _RangeIterator implements Iterator<XPathItem> {
  new(BigInt start, this._end) : _current = start - BigInt.one;

  final BigInt _end;
  BigInt _current;

  @override
  XPathItem get current => XPathInteger(_current);

  @override
  bool moveNext() {
    if (_current < _end) {
      _current += BigInt.one;
      return true;
    }
    return false;
  }
}

class _XPathEmptySequence extends XPathSequence {
  const new() : super._();

  @override
  Iterator<XPathItem> get iterator => const <XPathItem>[].iterator;

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  bool get ebv => false;

  @override
  bool hasCardinality(XPathCardinality cardinality) =>
      cardinality == XPathCardinality.zeroOrMore ||
      cardinality == XPathCardinality.zeroOrOne;

  @override
  Object? toValue() => null;

  @override
  String toString() => '()';
}

class _XPathSingleSequence extends XPathSequence {
  const new(this._item) : super._();

  final XPathItem _item;

  @override
  Iterator<XPathItem> get iterator => _SingleIterator(_item);

  @override
  int get length => 1;

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  XPathItem? get singleOrNull => _item;

  @override
  Object? toValue() => _item.toValue();

  @override
  bool get ebv => _item is XPathNode || _item.effectiveBooleanValue;

  @override
  bool hasCardinality(XPathCardinality cardinality) => true;

  @override
  String toString() => '($_item)';
}

class _SingleIterator implements Iterator<XPathItem> {
  new(this._item);
  final XPathItem _item;
  int _idx = -1;

  @override
  XPathItem get current => _item;

  @override
  bool moveNext() => ++_idx == 0;
}

class _XPathListSequence extends XPathSequence {
  const new(this._items) : super._();

  final List<XPathItem> _items;

  @override
  Iterator<XPathItem> get iterator => _items.iterator;

  @override
  int get length => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  String toString() => '(${_items.join(', ')})';
}

class _XPathCachedSequence extends XPathSequence {
  new(Iterable<XPathItem> source) : _iterator = source.iterator, super._();

  final Iterator<XPathItem> _iterator;
  final List<XPathItem> _cache = [];

  @override
  Iterator<XPathItem> get iterator => _CachedIterator(_iterator, _cache);
}

class _CachedIterator implements Iterator<XPathItem> {
  new(this._source, this._cache);
  final Iterator<XPathItem> _source;
  final List<XPathItem> _cache;
  int _idx = -1;

  @override
  XPathItem get current => _cache[_idx];

  @override
  bool moveNext() {
    _idx++;
    if (_idx < _cache.length) return true;
    if (_source.moveNext()) {
      _cache.add(_source.current);
      return true;
    }
    return false;
  }
}
