import 'package:collection/collection.dart' show DelegatingIterable;

import '../definitions/cardinality.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'any.dart';

/// The XPath empty sequence type.
const xsEmptySequence = _XPathEmptySequenceType();

class _XPathEmptySequenceType extends XPathType<XPathSequence> {
  const _XPathEmptySequenceType();

  @override
  String get name => 'empty-sequence()';

  @override
  bool matches(Object value) => value is XPathSequence && value.isEmpty;

  @override
  XPathSequence cast(Object value) {
    if (matches(value)) return XPathSequence.empty;
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath sequence type.
const xsSequence = XPathSequenceType();

class XPathSequenceType extends XPathType<XPathSequence> {
  const XPathSequenceType({
    this.type = xsAny,
    this.cardinality = XPathCardinality.zeroOrMore,
  });

  /// The type of the values in the sequence.
  final XPathType type;

  /// The cardinality of the sequence.
  final XPathCardinality cardinality;

  @override
  String get name => '$type$cardinality';

  @override
  bool matches(Object value) =>
      value is XPathSequence &&
      value.hasCardinality(cardinality) &&
      (type == xsAny || value.every(type.matches));

  @override
  XPathSequence cast(Object value) {
    if (value is XPathSequence) {
      if (value.hasCardinality(cardinality)) {
        if (type == xsAny) return value;
        return XPathSequence.cached(
          value.map((each) => type.cast(each) as Object),
        );
      }
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    return XPathSequence.single(
      type == xsAny ? value : type.cast(value) as Object,
    );
  }
}

/// An XPath 3.1 sequence.
abstract mixin class XPathSequence implements Iterable<Object> {
  /// The empty sequence.
  static const empty = _XPathEmptySequence();

  /// The true sequence.
  static const trueSequence = _XPathSingleSequence(true);

  /// The false sequence.
  static const falseSequence = _XPathSingleSequence(false);

  /// The empty string.
  static const emptyString = _XPathSingleSequence('');

  /// The empty array.
  static const emptyArray = _XPathSingleSequence(<Object>[]);

  /// The empty map.
  static const emptyMap = _XPathSingleSequence(<Object, Object>{});

  /// Creates a sequence from a single [value].
  const factory XPathSequence.single(Object value) = _XPathSingleSequence;

  /// Creates a sequence from an [Iterable].
  const factory XPathSequence(Iterable<Object> iterable) =
      _XPathDefaultSequence;

  /// Creates a sequence from a cached [Iterable].
  factory XPathSequence.cached(Iterable<Object> iterable) =
      _XPathCachedSequence;

  /// Creates a sequence from an integer range.
  factory XPathSequence.range(int start, int stop) => start < stop
      ? XPathSequence(Iterable.generate(stop - start + 1, (i) => start + i))
      : start == stop
      ? XPathSequence.single(start)
      : empty;

  /// Checks the cardinality of the sequence.
  bool hasCardinality(XPathCardinality cardinality) {
    if (XPathCardinality.zeroOrMore == cardinality) return true;
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      if (XPathCardinality.oneOrMore == cardinality) return true;
      if (!iterator.moveNext()) {
        return XPathCardinality.exactlyOne == cardinality ||
            XPathCardinality.zeroOrOne == cardinality;
      }
    } else {
      return XPathCardinality.zeroOrOne == cardinality;
    }
    return false;
  }

  /// Converts the sequence to an atomic value if it contains a single value.
  Object toAtomicValue() {
    final iter = iterator;
    if (!iter.moveNext()) return this;
    final value = iter.current;
    if (!iter.moveNext()) return value;
    return this;
  }
}

/// The empty sequence.
class _XPathEmptySequence extends Iterable<Object> with XPathSequence {
  const _XPathEmptySequence();

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  Iterator<Object> get iterator => const <Object>[].iterator;

  @override
  bool hasCardinality(XPathCardinality cardinality) =>
      XPathCardinality.zeroOrMore == cardinality ||
      XPathCardinality.zeroOrOne == cardinality;

  @override
  Object toAtomicValue() => this;
}

/// A sequence with a single value.
class _XPathSingleSequence extends Iterable<Object> with XPathSequence {
  const _XPathSingleSequence(this._value);

  final Object _value;

  @override
  int get length => 1;

  @override
  bool get isEmpty => false;

  @override
  Iterator<Object> get iterator => _XPathSingleIterator(_value);

  @override
  bool hasCardinality(XPathCardinality cardinality) => true;

  @override
  Object toAtomicValue() => _value;
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
    with XPathSequence {
  const _XPathDefaultSequence(super.base);

  @override
  String toString() => Iterable.iterableToShortString(this);
}

/// An optimized sequence that stores the results of the first iteration.
class _XPathCachedSequence extends Iterable<Object> with XPathSequence {
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
