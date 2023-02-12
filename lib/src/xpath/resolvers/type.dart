import '../../xml/enums/node_type.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../resolver.dart';

class CommentTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.COMMENT);
}

class NodeTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes;
}

class ProcessingTypeResolver implements Resolver {
  ProcessingTypeResolver(this.target);

  final String? target;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.where((node) =>
      node is XmlProcessing && (target == null || node.target == target));
}

class TextTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.where((node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA);
}
