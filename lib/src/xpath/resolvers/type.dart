import '../../xml/enums/node_type.dart';
import '../../xml/nodes/processing.dart';
import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class CommentTypeResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(
      value.nodes.where((node) => node.nodeType == XmlNodeType.COMMENT));
}

class NodeTypeResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(value.nodes);
}

class ProcessingTypeResolver implements Resolver {
  ProcessingTypeResolver(this.target);

  final String? target;

  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.where((node) =>
          node is XmlProcessing && (target == null || node.target == target)));
}

class TextTypeResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(value.nodes.where(
      (node) =>
          node.nodeType == XmlNodeType.TEXT ||
          node.nodeType == XmlNodeType.CDATA));
}
