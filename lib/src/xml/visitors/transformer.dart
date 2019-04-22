library xml.visitors.transformer;

import 'package:xml/src/xml/nodes/attribute.dart';
import 'package:xml/src/xml/nodes/cdata.dart';
import 'package:xml/src/xml/nodes/comment.dart';
import 'package:xml/src/xml/nodes/doctype.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/nodes/document_fragment.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/processing.dart';
import 'package:xml/src/xml/nodes/text.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// Transformer that creates an identical copy of the visited nodes.
///
/// Subclass can override one or more of the methods to modify the generated
/// copy.
class XmlTransformer with XmlVisitor {
  static final XmlTransformer defaultInstance = XmlTransformer();

  @override
  XmlAttribute visitAttribute(XmlAttribute node) =>
      XmlAttribute(visit(node.name), node.value, node.attributeType);

  @override
  XmlCDATA visitCDATA(XmlCDATA node) => XmlCDATA(node.text);

  @override
  XmlComment visitComment(XmlComment node) => XmlComment(node.text);

  @override
  XmlDoctype visitDoctype(XmlDoctype node) => XmlDoctype(node.text);

  @override
  XmlDocument visitDocument(XmlDocument node) =>
      XmlDocument(node.children.map(visit));

  @override
  XmlDocumentFragment visitDocumentFragment(XmlDocumentFragment node) =>
      XmlDocumentFragment(node.children.map(visit));

  @override
  XmlElement visitElement(XmlElement node) => XmlElement(visit(node.name),
      node.attributes.map(visit), node.children.map(visit), node.isSelfClosing);

  @override
  XmlName visitName(XmlName name) => XmlName.fromString(name.qualified);

  @override
  XmlProcessing visitProcessing(XmlProcessing node) =>
      XmlProcessing(node.target, node.text);

  @override
  XmlText visitText(XmlText node) => XmlText(node.text);
}
