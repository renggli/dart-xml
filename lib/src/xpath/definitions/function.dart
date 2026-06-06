import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/node.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import 'cardinality.dart';
import 'type.dart';

export 'package:petitparser/petitparser.dart' show unbounded;

/// Definition of an XPath function.
class XPathFunctionDefinition extends XPathFunction {
  const XPathFunctionDefinition({
    required this.name,
    this.requiredArguments = const [],
    this.optionalArguments = const [],
    this.variadicArgument,
    required this.function,
  });

  @override
  int get arity => requiredArguments.length;

  @override
  final XmlName name;

  /// The required argument definitions.
  final List<XPathArgumentDefinition> requiredArguments;

  /// The optional argument definitions.
  final List<XPathArgumentDefinition> optionalArguments;

  /// The variadic argument definition (if any).
  final XPathArgumentDefinition? variadicArgument;

  /// The implementation of the function.
  final Function function;

  /// Calls the function with the given arguments.
  @override
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
      '${super.toString()}(${requiredArguments.join(', ')}, '
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
    if (type is XPathSequenceType) {
      if (sequence.hasCardinality(cardinality)) {
        return sequence;
      }
      throw XPathEvaluationException(
        'Function "${definition.name.qualified}" expects cardinality $cardinality for '
        'argument "$name", but got sequence with incompatible cardinality.',
      );
    }

    if (type == xsAny &&
        (cardinality == XPathCardinality.oneOrMore ||
            cardinality == XPathCardinality.zeroOrMore)) {
      return sequence;
    }

    final convertedList = sequence
        .expand((e) => _convertItem(definition, e, type))
        .toList();

    return switch (cardinality) {
      XPathCardinality.exactlyOne => switch (convertedList) {
        [final single] => single,
        [] => throw XPathEvaluationException(
          'Function "${definition.name.qualified}" expects exactly one value for '
          'argument "$name", but got none.',
        ),
        _ => throw XPathEvaluationException(
          'Function "${definition.name.qualified}" expects exactly one value for '
          'argument "$name", but got more than one.',
        ),
      },
      XPathCardinality.zeroOrOne => switch (convertedList) {
        [] => null,
        [final single] => single,
        _ => throw XPathEvaluationException(
          'Function "${definition.name.qualified}" expects zero or one value for '
          'argument "$name", but got more than one.',
        ),
      },
      XPathCardinality.oneOrMore => switch (convertedList) {
        [] => throw XPathEvaluationException(
          'Function "${definition.name.qualified}" expects one or more values for '
          'argument "$name", but got none.',
        ),
        _ => XPathSequence(convertedList),
      },
      XPathCardinality.zeroOrMore => XPathSequence(convertedList),
    };
  }

  Iterable<Object> _convertItem(
    XPathFunctionDefinition definition,
    Object item,
    XPathType type,
  ) {
    if (!type.isAtomic) {
      if (type.matches(item)) return [type.cast(item)];
      throw XPathEvaluationException.unsupportedCast(type, item);
    }

    return switch (item) {
      XPathSequence() => item.expand((e) => _convertItem(definition, e, type)),
      XPathArray() => item.expand((e) => _convertItem(definition, e, type)),
      XmlNode() => _convertXmlNode(definition, item, type),
      XPathMap() || Function() => throw XPathEvaluationException(
        'Cannot atomize a map or function item',
      ),
      _ when type.matches(item) => [type.cast(item)],
      _ when definition.name.prefix == 'xs' => _tryCast(type, item),
      _ when type == xsDouble && item is num => [type.cast(item)],
      _ => throw XPathEvaluationException.unsupportedCast(type, item),
    };
  }

  Iterable<Object> _convertXmlNode(
    XPathFunctionDefinition definition,
    XmlNode node,
    XPathType type,
  ) {
    final val = xsNode.castToString(node);
    try {
      return [type.cast(val)];
    } on XPathEvaluationException {
      throw XPathEvaluationException(
        'Function "${definition.name.qualified}" expects type $type for argument "$name", '
        'but got XML node with incompatible value "$val".',
      );
    }
  }

  Iterable<Object> _tryCast(XPathType type, Object item) {
    try {
      return [type.cast(item)];
    } on XPathEvaluationException {
      throw XPathEvaluationException.unsupportedCast(type, item);
    }
  }

  @override
  String toString() => '\$$name as ${type.name}$cardinality';
}
