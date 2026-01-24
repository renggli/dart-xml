import 'package:collection/collection.dart' show DelegatingIterable;

import 'item.dart';

/// An XPath 3.1 sequence.
abstract interface class XPathSequence implements Iterable<XPathItem> {
  /// The empty sequence.
  static const empty = _XPathEmptySequence();

  /// The true sequence.
  static const trueSequence = _XPathSingleSequence(true);

  /// The false sequence.
  static const falseSequence = _XPathSingleSequence(false);

  /// The empty string.
  static const emptyString = _XPathSingleSequence('');

  /// The empty array.
  static const emptyArray = _XPathSingleSequence(<XPathItem>[]);

  /// The empty map.
  static const emptyMap = _XPathSingleSequence(<XPathItem, XPathItem>{});

  /// Creates a sequence from a single [value].
  const factory XPathSequence.single(XPathItem value) = _XPathSingleSequence;

  /// Creates a sequence from an [Iterable].
  const factory XPathSequence(Iterable<XPathItem> iterable) =
      _XPathDefaultSequence;

  /// Creates a sequence from a cached [Iterable].
  factory XPathSequence.cached(Iterable<XPathItem> iterable) =>
      _XPathCachedSequence(iterable);

  /// Creates a sequence from an integer range.
  factory XPathSequence.range(int start, int stop) => start < stop
      ? XPathSequence(Iterable.generate(stop - start + 1, (i) => start + i))
      : start == stop
      ? XPathSequence.single(start)
      : empty;
}

extension XPathSequenceExtension on XPathItem {
  XPathSequence toXPathSequence() {
    final self = this;
    return self is XPathSequence ? self : XPathSequence.single(self);
  }
}

/// The empty sequence.
class _XPathEmptySequence extends Iterable<XPathItem> implements XPathSequence {
  const _XPathEmptySequence();

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  Iterator<XPathItem> get iterator => const <XPathItem>[].iterator;
}

/// A sequence with a single value.
class _XPathSingleSequence extends Iterable<XPathItem>
    implements XPathSequence {
  const _XPathSingleSequence(this._value);

  final XPathItem _value;

  @override
  int get length => 1;

  @override
  bool get isEmpty => false;

  @override
  Iterator<XPathItem> get iterator => _XPathSingleIterator(_value);
}

class _XPathSingleIterator implements Iterator<XPathItem> {
  _XPathSingleIterator(this._value);

  final XPathItem _value;
  int _index = -1;

  @override
  XPathItem get current => _value;

  @override
  bool moveNext() => ++_index < 1;
}

/// The default sequence imlementation wrapping an [Iterable].
class _XPathDefaultSequence extends DelegatingIterable<XPathItem>
    implements XPathSequence {
  const _XPathDefaultSequence(super.base);

  @override
  String toString() => Iterable.iterableToShortString(this);
}

/// An optimized sequence that stores the results of the first iteration.
class _XPathCachedSequence extends Iterable<XPathItem>
    implements XPathSequence {
  _XPathCachedSequence(Iterable<XPathItem> source)
    : _iterator = source.iterator;

  final Iterator<XPathItem> _iterator;
  final List<XPathItem> _results = [];

  @override
  Iterator<XPathItem> get iterator => _XPathCachedIterator(_iterator, _results);
}

class _XPathCachedIterator implements Iterator<XPathItem> {
  _XPathCachedIterator(this._iterator, this._results);

  final Iterator<XPathItem> _iterator;
  final List<XPathItem> _results;
  int _index = -1;

  @override
  XPathItem get current => _results[_index];

  @override
  bool moveNext() {
    _index++;
    if (_index < _results.length) {
      return true;
    }
    if (_iterator.moveNext()) {
      _results.add(_iterator.current);
      return true;
    }
    return false;
  }
}
