import 'package:collection/collection.dart' show DelegatingIterable;
import '../../xml/nodes/node.dart';

import '../definitions/cardinality.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'any.dart';
import 'array.dart';
import 'map.dart';

/// The XPath empty sequence type.
const xsEmptySequence = _XPathEmptySequenceType();

class _XPathEmptySequenceType extends XPathType<XPathSequence<Never>> {
  const _XPathEmptySequenceType();

  @override
  String get name => 'empty-sequence()';

  @override
  bool matches(Object value) => value is XPathSequence && value.isEmpty;

  @override
  XPathSequence<Never> cast(Object value) {
    if (matches(value)) return XPathSequence.empty;
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath sequence type.
const xsSequence = XPathSequenceType(type: xsAny);

class XPathSequenceType<T extends Object> extends XPathType<XPathSequence<T>> {
  const XPathSequenceType({
    required this.type,
    this.cardinality = XPathCardinality.zeroOrMore,
  });

  /// The type of the values in the sequence.
  final XPathType<T> type;

  /// The cardinality of the sequence.
  final XPathCardinality cardinality;

  @override
  String get name => '$type$cardinality';

  @override
  bool matches(Object value) =>
      value is XPathSequence<T> &&
      value.hasCardinality(cardinality) &&
      (identical(type, xsAny) || value.every(type.matches));

  @override
  XPathSequence<T> cast(Object value) {
    if (value is XPathSequence) {
      if (value.hasCardinality(cardinality)) {
        return XPathSequence.cached(value.map(type.cast));
      }
      throw XPathEvaluationException.unsupportedCast(this, value);
    }
    return XPathSequence.single(type.cast(value));
  }
}

/// An XPath sequence.
abstract mixin class XPathSequence<T extends Object> implements Iterable<T> {
  /// The empty sequence.
  static const empty = _XPathEmptySequence();

  /// The true sequence.
  static const trueSequence = _XPathSingleSequence<bool>(true);

  /// The false sequence.
  static const falseSequence = _XPathSingleSequence<bool>(false);

  /// The empty string.
  static const emptyString = _XPathSingleSequence<String>('');

  /// The NaN sequence.
  static const nan = _XPathSingleSequence<double>(double.nan);

  /// The empty array.
  static const emptyArray = _XPathSingleSequence<XPathArray>([]);

  /// The empty map.
  static const emptyMap = _XPathSingleSequence<XPathMap>({});

  /// Creates a sequence from a single [value].
  const factory XPathSequence.single(T value) = _XPathSingleSequence;

  /// Creates a sequence from an [Iterable].
  const factory XPathSequence(Iterable<T> iterable) = _XPathDefaultSequence;

  /// Creates a sequence from an [Iterable] that is cached on first iteration.
  factory XPathSequence.cached(Iterable<T> iterable) = _XPathCachedSequence;

  /// Creates a sequence from an integer range.
  static XPathSequence<int> range(int start, int stop) => start < stop
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

  /// Computes the Effective Boolean Value (EBV) of the sequence.
  bool get ebv {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return false;
    final item = iterator.current;
    if (item is XmlNode) return true;
    if (!iterator.moveNext()) {
      if (item is bool) return item;
      if (item is num) return item != 0 && !item.isNaN;
      if (item is String) return item.isNotEmpty;
      throw XPathEvaluationException(
        'Invalid type for EBV: ${item.runtimeType}',
      );
    }
    throw XPathEvaluationException('Invalid EBV for sequence of length > 1');
  }
}

extension XPathSequenceExtension on Object {
  /// Unwraps this object if it is an [XPathSequence] with a single value.
  Object toAtomicValue() {
    final self = this;
    if (self is XPathSequence) {
      final iter = self.iterator;
      if (!iter.moveNext()) return self;
      final value = iter.current;
      if (!iter.moveNext()) return value;
    }
    return self;
  }

  /// Wraps this object in an [XPathSequence] if it is not already in one.
  XPathSequence toXPathSequence() {
    final self = this;
    if (self is XPathSequence) return self;
    return XPathSequence.single(self);
  }
}

/// The empty sequence.
class _XPathEmptySequence extends Iterable<Never> with XPathSequence<Never> {
  const _XPathEmptySequence();

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  Iterator<Never> get iterator => const <Never>[].iterator;

  @override
  bool hasCardinality(XPathCardinality cardinality) =>
      XPathCardinality.zeroOrMore == cardinality ||
      XPathCardinality.zeroOrOne == cardinality;
}

/// A sequence with a single value.
class _XPathSingleSequence<T extends Object> extends Iterable<T>
    with XPathSequence<T> {
  const _XPathSingleSequence(this._value);

  final T _value;

  @override
  int get length => 1;

  @override
  bool get isEmpty => false;

  @override
  Iterator<T> get iterator => _XPathSingleIterator(_value);

  @override
  bool hasCardinality(XPathCardinality cardinality) => true;
}

class _XPathSingleIterator<T> implements Iterator<T> {
  _XPathSingleIterator(this._value);

  final T _value;
  int _index = -1;

  @override
  T get current => _value;

  @override
  bool moveNext() => ++_index < 1;
}

/// The default sequence imlementation wrapping an [Iterable].
class _XPathDefaultSequence<T extends Object> extends DelegatingIterable<T>
    with XPathSequence<T> {
  const _XPathDefaultSequence(super.base);

  @override
  String toString() => Iterable.iterableToShortString(this);
}

/// An optimized sequence that stores the results of the first iteration.
class _XPathCachedSequence<T extends Object> extends Iterable<T>
    with XPathSequence<T> {
  _XPathCachedSequence(Iterable<T> source) : _iterator = source.iterator;

  final Iterator<T> _iterator;
  final List<T> _values = [];

  @override
  Iterator<T> get iterator => _XPathCachedIterator(_iterator, _values);
}

class _XPathCachedIterator<T extends Object> implements Iterator<T> {
  _XPathCachedIterator(this._iterator, this._values);

  final Iterator<T> _iterator;
  final List<T> _values;
  int _index = -1;

  @override
  T get current => _values[_index];

  @override
  bool moveNext() {
    _index++;
    if (_index < _values.length) {
      return true;
    }
    if (_iterator.moveNext()) {
      _values.add(_iterator.current);
      return true;
    }
    return false;
  }
}
