import '../mixins/has_visitor.dart';
import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/declaration.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';

/// External transformer that creates an identical copy of the visited nodes.
///
/// Subclass can override one or more of the methods to modify the generated
/// copy.
@Deprecated('Use `XmlNode.copy()` and mutate the DOM in-place, or create a '
    'strongly-typed `XmlVisitor` over your DOM instead')
class XmlTransformer {
  const XmlTransformer();

  T visit<T extends XmlHasVisitor>(T node) => switch (node) {
        XmlAttribute() => visitAttribute(node) as T,
        XmlCDATA() => visitCDATA(node) as T,
        XmlComment() => visitComment(node) as T,
        XmlDeclaration() => visitDeclaration(node) as T,
        XmlDoctype() => visitDoctype(node) as T,
        XmlDocument() => visitDocument(node) as T,
        XmlDocumentFragment() => visitDocumentFragment(node) as T,
        XmlElement() => visitElement(node) as T,
        XmlName() => visitName(node) as T,
        XmlProcessing() => visitProcessing(node) as T,
        XmlText() => visitText(node) as T,
        _ => visitOther(node) as T,
      };

  XmlAttribute visitAttribute(XmlAttribute node) =>
      XmlAttribute(visit(node.name), node.value, node.attributeType);

  XmlCDATA visitCDATA(XmlCDATA node) => XmlCDATA(node.value);

  XmlComment visitComment(XmlComment node) => XmlComment(node.value);

  XmlDeclaration visitDeclaration(XmlDeclaration node) =>
      XmlDeclaration(node.attributes.map(visit));

  XmlDoctype visitDoctype(XmlDoctype node) =>
      XmlDoctype(node.name, node.externalId, node.internalSubset);

  XmlDocument visitDocument(XmlDocument node) =>
      XmlDocument(node.children.map(visit));

  XmlDocumentFragment visitDocumentFragment(XmlDocumentFragment node) =>
      XmlDocumentFragment(node.children.map(visit));

  XmlElement visitElement(XmlElement node) => XmlElement(visit(node.name),
      node.attributes.map(visit), node.children.map(visit), node.isSelfClosing);

  XmlName visitName(XmlName name) => XmlName.fromString(name.qualified);

  XmlProcessing visitProcessing(XmlProcessing node) =>
      XmlProcessing(node.target, node.value);

  XmlText visitText(XmlText node) => XmlText(node.value);

  XmlHasVisitor visitOther(XmlHasVisitor node) =>
      throw StateError('Unknown node type: ${node.runtimeType}');
}
