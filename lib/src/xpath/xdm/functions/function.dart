import '../../../xml/utils/name.dart';
import '../../evaluation/context.dart';
import '../../evaluation/functions.dart';
import '../function_item.dart';
import '../sequence.dart';

typedef XPathFunctionCallback = XPathSequence Function(
  XPathContext context,
  List<XPathSequence> arguments,
);

/// A callable XPath function item (builtin, anonymous, or partial).
final class XPathFunction extends XPathFunctionItem {
  const new({required this.name, required this.arity, required this.function});

  @override
  final XmlName name;

  @override
  final int arity;

  final XPathFunctionCallback function;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) =>
      function(context, arguments);
}

/// Extension to convert a Dart [Function] into an [XPathFunction].
extension XPathWrappedFunctionExtension on Function {
  /// Converts a Dart function into an [XPathFunction] with the provided [name]
  /// and [arity].
  XPathFunction toXPathFunction({XmlName? name, int arity = 0}) =>
      XPathFunction(
        name: name ?? anonymousFunctionName,
        arity: arity,
        function: (context, arguments) =>
            Function.apply(this, [context, arguments]) as XPathSequence,
      );
}
