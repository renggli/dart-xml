import '../../../xpath.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../evaluation/namespaces.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import 'array.dart';
import 'map.dart';
import 'sequence.dart';

/// Abstract base class for functions in XPath.
abstract class XPathFunction {
  const XPathFunction();

  /// The name of the function.
  XmlName get name;

  /// The arity of the function (number of required arguments).
  int get arity;

  /// Calls the function with the given arguments.
  XPathSequence call(XPathContext context, List<XPathSequence> arguments);

  @override
  String toString() => '$name#$arity';
}

/// Extension to convert a Dart [Function] into an [XPathFunction].
extension XPathWrappedFunctionExtension on Function {
  /// Converts a Dart function into an [XPathFunction] with the provided [name]
  /// and [arity].
  XPathFunction toXPathFunction({
    XmlName name = const XmlName.qualified(''),
    int arity = 0,
  }) => _XPathWrappedFunction(name, arity, this);
}

/// A function that wraps a Dart function definition.
class _XPathWrappedFunction extends XPathFunction {
  _XPathWrappedFunction(this.name, this.arity, this.function);

  @override
  final XmlName name;

  @override
  final int arity;

  final Function function;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) =>
      Function.apply(function, [context, arguments]) as XPathSequence;
}

/// A function wrapper for a casted XPathArray.
class XPathArrayFunction extends XPathFunction {
  XPathArrayFunction(this._array);

  final XPathArray _array;

  @override
  XmlName get name =>
      const XmlName.qualified('get', namespaceUri: xpathArrayNamespace);

  @override
  int get arity => 1;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        'Arrays expect exactly 1 argument, but got ${arguments.length}',
      );
    }
    final index = xsInteger.cast(arguments.single);
    if (index < 1 || index > _array.length) {
      throw XPathEvaluationException('Array index out of bounds: $index');
    }
    return xsSequence.cast(_array[index - 1]);
  }
}

/// A function wrapper for a casted XPathMap.
class XPathMapFunction extends XPathFunction {
  XPathMapFunction(this._map);

  final XPathMap _map;

  @override
  XmlName get name =>
      const XmlName.qualified('get', namespaceUri: xpathMapNamespace);

  @override
  int get arity => 1;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        'Maps expects exactly 1 argument, but got ${arguments.length}',
      );
    }
    final key = arguments[0].toAtomicValue();
    final result = _map[key];
    return result != null ? xsSequence.cast(result) : XPathSequence.empty;
  }
}
