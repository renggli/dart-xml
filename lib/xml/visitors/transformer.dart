library xml.visitors.transformer;

import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/cdata.dart' show XmlCDATA;
import 'package:xml/xml/nodes/comment.dart' show XmlComment;
import 'package:xml/xml/nodes/doctype.dart' show XmlDoctype;
import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/processing.dart' show XmlProcessing;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/visitors/visitable.dart' show XmlVisitable;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// Transformer that creates an identical copy of the visited nodes.
///
/// Subclass can override one or more of the methods to modify the generated copy.
class XmlTransformer extends XmlVisitor<XmlVisitable> {
  @override
  XmlAttribute visitAttribute(XmlAttribute node) =>
      new XmlAttribute(visit(node.name), node.value, node.attributeType);

  @override
  XmlCDATA visitCDATA(XmlCDATA node) => new XmlCDATA(node.text);

  @override
  XmlComment visitComment(XmlComment node) => new XmlComment(node.text);

  @override
  XmlDoctype visitDoctype(XmlDoctype node) => new XmlDoctype(node.text);

  @override
  XmlDocument visitDocument(XmlDocument node) => new XmlDocument(visitAll(node.children));

  @override
  XmlDocumentFragment visitDocumentFragment(XmlDocumentFragment node) =>
      new XmlDocumentFragment(visitAll(node.children));

  @override
  XmlElement visitElement(XmlElement node) =>
      new XmlElement(visit(node.name), visitAll(node.attributes), visitAll(node.children));

  @override
  XmlName visitName(XmlName name) => new XmlName.fromString(name.qualified);

  @override
  XmlProcessing visitProcessing(XmlProcessing node) => new XmlProcessing(node.target, node.text);

  @override
  XmlText visitText(XmlText node) => new XmlText(node.text);
}
