import '../../xml/enums/node_type.dart';
import '../../xml/nodes/node.dart';
import '../resolver.dart';

class DocumentTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.DOCUMENT);
}

class ElementTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.ELEMENT);
}

class AttributeTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.ATTRIBUTE);
}

class CommentTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.COMMENT);
}

class TextTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.where((node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA);
}

class ProcessingTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node.nodeType == XmlNodeType.PROCESSING);
}

class NodeTypeResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes;
}
