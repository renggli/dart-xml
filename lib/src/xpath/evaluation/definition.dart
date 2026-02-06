import 'package:collection/collection.dart' show DelegatingIterable;
import '../../xml/nodes/node.dart';
import '../exceptions/evaluation_exception.dart';
import '../expressions/node_test.dart';
import 'context.dart';

export 'package:petitparser/petitparser.dart' show unbounded;

/// Definition of an XPath type.
abstract class XPathType {
  const XPathType();

  /// Returns `true` if the [item] matches this type.
  bool matches(Object item);

  /// Casts the [item] to this type.
  XPathSequence cast(Object item);
}

/// A basic XPath type for single items.
class XPathTypeDefinition extends XPathType {
  const XPathTypeDefinition(
    this.name, {
    required bool Function(Object item) matches,
    required XPathSequence Function(Object item) cast,
  }) : _matches = matches,
       _cast = cast;

  /// The name of the type.
  final String name;

  final bool Function(Object item) _matches;

  final XPathSequence Function(Object item) _cast;

  @override
  bool matches(Object item) => _matches(item);

  @override
  XPathSequence cast(Object item) => _cast(item);

  @override
  String toString() => name;
}

/// An item type that matches anything (`item()`).
class XPathAnyItemType extends XPathType {
  const XPathAnyItemType();

  @override
  bool matches(Object item) => true;

  @override
  XPathSequence cast(Object item) => item.toXPathSequence();

  @override
  String toString() => 'item()';
}

/// The XPath any type.
const xsAny = XPathAnyItemType();

/// An item type that matches a node test.
class XPathNodeTestItemType extends XPathType {
  const XPathNodeTestItemType(this.nodeTest);

  final NodeTest nodeTest;

  @override
  bool matches(Object item) => item is XmlNode && nodeTest.matches(item);

  @override
  XPathSequence cast(Object item) {
    if (matches(item)) return item.toXPathSequence();
    throw XPathEvaluationException('Cannot cast $item to node test');
  }

  @override
  String toString() => nodeTest.toString();
}

/// A type that matches only the empty sequence.
class XPathEmptySequenceType extends XPathType {
  const XPathEmptySequenceType();

  @override
  bool matches(Object item) =>
      item is XPathSequence && item.isEmpty ||
      (item is! XPathSequence && false); // Should only be checked against sequences

  @override
  XPathSequence cast(Object item) {
    if (matches(item)) return XPathSequence.empty;
    throw XPathEvaluationException('Cannot cast $item to empty-sequence()');
  }

  @override
  String toString() => 'empty-sequence()';
}

/// A sequence type with a specific cardinality.
class XPathSequenceType extends XPathType {
  const XPathSequenceType(
    this.itemType, {
    this.cardinality = XPathArgumentCardinality.exactlyOne,
  });

  /// The type of the items in the sequence.
  final XPathType itemType;

  /// The cardinality of the sequence.
  final XPathArgumentCardinality cardinality;

  @override
  bool matches(Object item) {
    final sequence = item.toXPathSequence();
    if (sequence.isEmpty) {
      return cardinality == XPathArgumentCardinality.zeroOrOne ||
          cardinality == XPathArgumentCardinality.zeroOrMore;
    }
    if (sequence.length > 1) {
      if (cardinality == XPathArgumentCardinality.exactlyOne ||
          cardinality == XPathArgumentCardinality.zeroOrOne) {
        return false;
      }
    }
    for (final element in sequence) {
      if (!itemType.matches(element)) {
        return false;
      }
    }
    return true;
  }

  @override
  XPathSequence cast(Object item) {
    if (matches(item)) return item.toXPathSequence();
    final sequence = item.toXPathSequence();
    return XPathSequence(sequence.expand((element) => itemType.cast(element)));
  }

  @override
  String toString() => '$itemType${cardinality.suffix}';
}

/// An XPath 3.1 sequence.
abstract interface class XPathSequence implements Iterable<Object> {
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
}

extension XPathSequenceExtension on Object {
  XPathSequence toXPathSequence() {
    final self = this;
    return self is XPathSequence ? self : XPathSequence.single(self);
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

/// Definition of an XPath function.
class XPathFunctionDefinition {
  const XPathFunctionDefinition({
    required this.namespace,
    required this.name,
    this.requiredArguments = const [],
    this.optionalArguments = const [],
    this.variadicArgument,
    required this.function,
  });

  /// The namespace of the function.
  final String namespace;

  /// The name of the function.
  final String name;

  /// The required argument definitions.
  final List<XPathArgumentDefinition> requiredArguments;

  /// The optional argument definitions.
  final List<XPathArgumentDefinition> optionalArguments;

  /// The variadic argument definition (if any).
  final XPathArgumentDefinition? variadicArgument;

  /// The implementation of the function.
  final Function function;

  /// Calls the function with the given arguments.
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    var index = 0;
    final positionalArguments = <Object?>[context];
    // Process required arguments.
    for (final definition in requiredArguments) {
      if (index < arguments.length) {
        positionalArguments.add(definition.convert(this, arguments[index++]));
      } else {
        throw XPathEvaluationException(
          'Function "$namespace:$name" expects at least '
          '${requiredArguments.length} arguments, but got ${arguments.length}',
        );
      }
    }
    // Process optional arguments.
    for (final definition in optionalArguments) {
      if (index < arguments.length) {
        positionalArguments.add(definition.convert(this, arguments[index++]));
      } else if (definition.defaultValue != null) {
        positionalArguments.add(definition.defaultValue!(context));
      }
    }
    // Process variadic arguments.
    if (variadicArgument != null) {
      final rest = <Object>[];
      while (index < arguments.length) {
        rest.add(variadicArgument!.convert(this, arguments[index++]) as Object);
      }
      positionalArguments.add(rest);
    } else if (index < arguments.length) {
      throw XPathEvaluationException(
        'Function "$namespace:$name" expects at most '
        '${requiredArguments.length + optionalArguments.length} '
        'arguments, but got ${arguments.length}',
      );
    }
    // Evaluate the function.
    return Function.apply(function, positionalArguments) as XPathSequence;
  }
}

/// Definition of an XPath function argument.
class XPathArgumentDefinition {
  const XPathArgumentDefinition({
    required this.name,
    required this.type,
    this.defaultValue,
  });

  /// The name of the argument.
  final String name;

  /// The expected type of the argument.
  final XPathType type;

  /// The default value of the argument.
  final Object? Function(XPathContext context)? defaultValue;

  /// Process the argument.
  Object? convert(XPathFunctionDefinition definition, XPathSequence sequence) {
    try {
      final result = type.cast(sequence);
      if (type is XPathSequenceType) {
        final sequenceType = type as XPathSequenceType;
        if (sequenceType.cardinality == XPathArgumentCardinality.exactlyOne) {
          return result.first;
        } else if (sequenceType.cardinality ==
            XPathArgumentCardinality.zeroOrOne) {
          return result.isEmpty ? null : result.first;
        }
      } else if (type is! XPathAnyItemType &&
          type is! XPathEmptySequenceType &&
          type is! XPathNodeTestItemType) {
        // Basic TypeDefinitions also return single values.
        return result.first;
      }
      return result;
    } on XPathEvaluationException catch (error) {
      throw XPathEvaluationException(
        'Function "${definition.namespace}:${definition.name}" argument "$name" '
        'expects $type, but got $sequence: ${error.message}',
      );
    }
  }
}

/// The cardinality of the argument.
enum XPathArgumentCardinality {
  /// The argument must have exactly one value.
  exactlyOne(''),

  /// The argument must have zero or one value `?`.
  zeroOrOne('?'),

  /// The argument must have one or more values `+`.
  oneOrMore('+'),

  /// The argument can have any number of values `*`.
  zeroOrMore('*');

  const XPathArgumentCardinality(this.suffix);

  /// The suffix of the cardinality.
  final String suffix;
}
