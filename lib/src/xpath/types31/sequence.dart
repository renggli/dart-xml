import 'package:collection/collection.dart' show DelegatingIterable;

/// An XPath 3.1 sequence.
abstract interface class XPathSequence implements Iterable<Object> {
  /// The empty sequence.
  static const empty = _XPathEmptySequence();

  /// The true sequence.
  static const trueSequence = _XPathSingleSequence(true);

  /// The false sequence.
  static const falseSequence = _XPathSingleSequence(false);

  /// Creates a sequence from a single [value].
  const factory XPathSequence.single(Object value) = _XPathSingleSequence;

  /// Creates a sequence from an [Iterable].
  const factory XPathSequence(Iterable<Object> iterable) =
      _XPathDefaultSequence;

  /// Creates a sequence from a cached [Iterable].
  factory XPathSequence.cached(Iterable<Object> iterable) =>
      _XPathCachedSequence(iterable);

  /// Creates a sequence from an integer range.
  factory XPathSequence.range(int start, int stop) => start < stop
      ? XPathSequence(Iterable.generate(stop - start + 1, (i) => start + i))
      : start == stop
      ? XPathSequence.single(start)
      : empty;
}

extension XPathSequenceExtension on Object {
  XPathSequence toXPathSequence() {
    final self = this;
    return self is XPathSequence ? self : XPathSequence.single(self);
  }

  Object toAtomicValue() {
    final self = this;
    return self is XPathSequence ? (self.singleOrNull ?? self) : self;
  }
}

/// The empty sequence.
class _XPathEmptySequence extends Iterable<Object> implements XPathSequence {
  const _XPathEmptySequence();

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  Iterator<Object> get iterator => const <Object>[].iterator;
}

/// A sequence with a single value.
class _XPathSingleSequence extends Iterable<Object> implements XPathSequence {
  const _XPathSingleSequence(this._value);

  final Object _value;

  @override
  int get length => 1;

  @override
  bool get isEmpty => false;

  @override
  Iterator<Object> get iterator => _XPathSingleIterator(_value);
}

class _XPathSingleIterator implements Iterator<Object> {
  _XPathSingleIterator(this._value);

  final Object _value;
  int _index = -1;

  @override
  Object get current => _value;

  @override
  bool moveNext() => ++_index < 1;
}

/// The default sequence imlementation wrapping an [Iterable].
class _XPathDefaultSequence extends DelegatingIterable<Object>
    implements XPathSequence {
  const _XPathDefaultSequence(super.base);

  @override
  String toString() => Iterable.iterableToShortString(this);
}

/// An optimized sequence that stores the results of the first iteration.
class _XPathCachedSequence extends Iterable<Object> implements XPathSequence {
  _XPathCachedSequence(Iterable<Object> source) : _iterator = source.iterator;

  final Iterator<Object> _iterator;
  final List<Object> _results = [];

  @override
  Iterator<Object> get iterator => _XPathCachedIterator(_iterator, _results);
}

class _XPathCachedIterator implements Iterator<Object> {
  _XPathCachedIterator(this._iterator, this._results);

  final Iterator<Object> _iterator;
  final List<Object> _results;
  int _index = -1;

  @override
  Object get current => _results[_index];

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
