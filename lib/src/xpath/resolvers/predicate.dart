import '../../xml/nodes/node.dart';
import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class PredicateResolver implements Resolver {
  PredicateResolver(this.resolver);

  final Resolver resolver;

  @override
  Value call(Context context, Value value) {
    final output = <XmlNode>[];
    final input = value.nodes.toList();
    for (var i = 0; i < input.length; i++) {
      final result = resolver(context, NodesValue([input[i]]));
      if (_matches(result, i, input.length)) {
        output.add(input[i]);
      }
    }
    return NodesValue(output);
  }

  static bool _matches(Value value, int index, int length) {
    if (value is NumberValue) {
      final result = value.number.round();
      return result == index + 1 || result == index - length;
    }
    return value.boolean;
  }
}
