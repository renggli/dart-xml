import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/sequence.dart';
import 'cardinality.dart';
import 'type.dart';

export 'package:petitparser/petitparser.dart' show unbounded;

/// Definition of an XPath function.
class XPathFunctionDefinition {
  const XPathFunctionDefinition({
    required this.name,
    this.requiredArguments = const [],
    this.optionalArguments = const [],
    this.variadicArgument,
    required this.function,
  });

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
          'Function "$name" expects at least '
          '${requiredArguments.length} arguments, but got ${arguments.length}.',
        );
      }
    }
    // Process optional arguments.
    for (final definition in optionalArguments) {
      if (index < arguments.length) {
        positionalArguments.add(definition.convert(this, arguments[index++]));
      } else if (definition.defaultValue != null) {
        positionalArguments.add(definition.defaultValue!(context));
      } else if (variadicArgument != null) {
        positionalArguments.add(null);
      }
    }
    // Process variadic arguments.
    if (variadicArgument != null) {
      final rest = <Object>[];
      while (index < arguments.length) {
        rest.add(variadicArgument!.convert(this, arguments[index++])!);
      }
      positionalArguments.add(rest);
    } else if (index < arguments.length) {
      throw XPathEvaluationException(
        'Function "$name" expects at most '
        '${requiredArguments.length + optionalArguments.length} '
        'arguments, but got ${arguments.length}.',
      );
    }
    // Evaluate the function.
    return Function.apply(function, positionalArguments) as XPathSequence;
  }

  @override
  String toString() =>
      '$name(${requiredArguments.join(', ')}, '
      '${optionalArguments.join(', ')}, '
      '${variadicArgument != null ? '...' : ''})';
}

/// Definition of an XPath function argument.
class XPathArgumentDefinition {
  const XPathArgumentDefinition({
    required this.name,
    required this.type,
    this.cardinality = XPathCardinality.exactlyOne,
    this.defaultValue,
  });

  /// The name of the argument.
  final String name;

  /// The expected type of the argument.
  final XPathType<Object> type;

  /// The cardinality of the argument.
  final XPathCardinality cardinality;

  /// The default value of the argument.
  final Object? Function(XPathContext context)? defaultValue;

  /// Process the argument.
  Object? convert(XPathFunctionDefinition definition, XPathSequence sequence) {
    switch (cardinality) {
      case XPathCardinality.exactlyOne:
        final iterable = sequence.iterator;
        if (!iterable.moveNext()) {
          throw XPathEvaluationException(
            'Function "${definition.name}" expects exactly one value for '
            'argument "$name", but got none.',
          );
        }
        final value = iterable.current;
        if (iterable.moveNext()) {
          throw XPathEvaluationException(
            'Function "${definition.name}" expects exactly one value for '
            'argument "$name", but got more than one.',
          );
        }
        return type.cast(value);
      case XPathCardinality.zeroOrOne:
        final iterable = sequence.iterator;
        if (!iterable.moveNext()) {
          return null;
        }
        final value = iterable.current;
        if (iterable.moveNext()) {
          throw XPathEvaluationException(
            'Function "${definition.name}" expects zero or one value for '
            'argument "$name", but got more than one.',
          );
        }
        return type.cast(value);
      case XPathCardinality.oneOrMore:
        final iterable = sequence.iterator;
        if (!iterable.moveNext()) {
          throw XPathEvaluationException(
            'Function "${definition.name}" expects one or more values for '
            'argument "$name", but got none.',
          );
        }
        return type == xsAny
            ? sequence
            : XPathSequence(sequence.map(type.cast));
      case XPathCardinality.zeroOrMore:
        return type == xsAny
            ? sequence
            : XPathSequence(sequence.map(type.cast));
    }
  }

  @override
  String toString() => '\$$name as ${type.name}$cardinality';
}
