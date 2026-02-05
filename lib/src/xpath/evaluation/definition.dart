import '../exceptions/evaluation_exception.dart';
import '../expressions/node_test.dart';
import '../types/array.dart';
import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/node.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';
import 'context.dart';

export 'package:petitparser/petitparser.dart' show unbounded;

/// Definition of an XPath type.
abstract class XPathTypeDefinition {
  const XPathTypeDefinition();

  /// Returns `true` if the [sequence] matches this type.
  bool matches(XPathSequence sequence);
}

/// A sequence type.
class XPathSequenceType extends XPathTypeDefinition {
  const XPathSequenceType(
    this.itemType, {
    this.cardinality = XPathArgumentCardinality.exactlyOne,
  });

  final XPathItemType itemType;

  final XPathArgumentCardinality cardinality;

  @override
  bool matches(XPathSequence sequence) {
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
    for (final item in sequence) {
      if (!itemType.matches(item)) {
        return false;
      }
    }
    return true;
  }
}

/// An item type.
abstract class XPathItemType {
  const XPathItemType();

  /// Returns `true` if the [item] matches this type.
  bool matches(Object item);

  /// Casts the [item] to this type.
  XPathSequence cast(Object item) {
    if (matches(item)) return XPathSequence.single(item);
    throw XPathEvaluationException('Cannot cast $item to $this');
  }
}

/// An empty sequence type.
class XPathEmptySequenceType extends XPathSequenceType {
  const XPathEmptySequenceType()
    : super(
        const XPathAnyItemType(),
        cardinality: XPathArgumentCardinality.zeroOrOne,
      );

  @override
  bool matches(XPathSequence sequence) => sequence.isEmpty;
}

/// An item type that matches anything.
class XPathAnyItemType extends XPathItemType {
  const XPathAnyItemType();

  @override
  bool matches(Object item) => true;
}

/// An item type that matches a specific node.
class XPathNodeTestItemType extends XPathItemType {
  const XPathNodeTestItemType(this.nodeTest);

  final NodeTest nodeTest;

  @override
  bool matches(Object item) => item is XPathNode && nodeTest.matches(item);
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
      final rest = <Object?>[];
      while (index < arguments.length) {
        rest.add(variadicArgument!.convert(this, arguments[index++]));
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
    this.cardinality = XPathArgumentCardinality.exactlyOne,
    this.defaultValue,
  });

  /// The name of the argument.
  final String name;

  /// The expected type of the argument.
  final Type type;

  /// The cardinality of the argument.
  final XPathArgumentCardinality cardinality;

  /// The default value of the argument.
  final Object? Function(XPathContext context)? defaultValue;

  /// Process the argument.
  Object? convert(XPathFunctionDefinition definition, XPathSequence sequence) {
    switch (cardinality) {
      case XPathArgumentCardinality.exactlyOne:
        return _convertExactlyOne(definition, sequence);
      case XPathArgumentCardinality.zeroOrOne:
        return _convertZeroOrOne(definition, sequence);
      case XPathArgumentCardinality.oneOrMore:
        return _convertOneOrMore(definition, sequence);
      case XPathArgumentCardinality.zeroOrMore:
        return sequence;
    }
  }

  /// Converts an argument that has exactly one item.
  Object _convertExactlyOne(
    XPathFunctionDefinition definition,
    XPathSequence sequence,
  ) {
    final iterator = sequence.iterator;
    if (iterator.moveNext()) {
      final item = iterator.current;
      if (!iterator.moveNext()) return _convertItem(item);
    }
    throw XPathEvaluationException(
      'Function "${definition.namespace}:${definition.name}" argument "$name" '
      'expects exactly-one item, but got $sequence',
    );
  }

  /// Converts an argument that has zero or one item.
  Object? _convertZeroOrOne(
    XPathFunctionDefinition definition,
    XPathSequence sequence,
  ) {
    final iterator = sequence.iterator;
    if (!iterator.moveNext()) return null;
    final item = iterator.current;
    if (!iterator.moveNext()) return _convertItem(item);
    throw XPathEvaluationException(
      'Function "${definition.namespace}:${definition.name}" argument "$name" '
      'expects zero-or-one items, but got $sequence',
    );
  }

  XPathSequence _convertOneOrMore(
    XPathFunctionDefinition definition,
    XPathSequence sequence,
  ) {
    if (sequence.isNotEmpty) return sequence;
    throw XPathEvaluationException(
      'Function "${definition.namespace}:${definition.name}" argument "$name" '
      'expects one-or-more items, but got $sequence',
    );
  }

  /// Converts the given value to the expected type.
  Object _convertItem(Object value) {
    switch (type) {
      case const (XPathSequence):
        return value is XPathSequence ? value : XPathSequence.single(value);
      case const (XPathBoolean):
        return value.toXPathBoolean();
      case const (XPathBase64Binary):
        return value.toXPathBase64Binary();
      case const (XPathHexBinary):
        return value.toXPathHexBinary();
      case const (XPathDateTime):
        return value.toXPathDateTime();
      case const (XPathDuration):
        return value.toXPathDuration();
      case const (XPathFunction):
        return value.toXPathFunction();
      case const (XPathNode):
        return value.toXPathNode();
      case const (XPathNumber):
        return value.toXPathNumber();
      case const (XPathString):
        return value.toXPathString();
      case const (XPathArray):
        return value.toXPathArray();
      case const (XPathMap):
        return value.toXPathMap();
      default:
        return value;
    }
  }
}

/// The cardinality of the argument.
enum XPathArgumentCardinality {
  /// The argument must have exactly one value.
  exactlyOne,

  /// The argument must have zero or one value `?`.
  zeroOrOne,

  /// The argument must have one or more values `+`.
  oneOrMore,

  /// The argument can have any number of values `*`.
  zeroOrMore,
}
