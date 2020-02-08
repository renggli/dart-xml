library xml.visitors.writer;

import '../entities/entity_mapping.dart';
import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/declaration.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';
import '../utils/token.dart';
import 'visitor.dart';

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter with XmlVisitor {
  final StringBuffer buffer;
  final XmlEntityMapping entityMapping;

  XmlWriter(this.buffer, this.entityMapping);

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlToken.equals);
    buffer.write(entityMapping.encodeAttributeValueWithQuotes(
        node.value, node.attributeType));
  }

  @override
  void visitCDATA(XmlCDATA node) {
    buffer.write(XmlToken.openCDATA);
    buffer.write(node.text);
    buffer.write(XmlToken.closeCDATA);
  }

  @override
  void visitComment(XmlComment node) {
    buffer.write(XmlToken.openComment);
    buffer.write(node.text);
    buffer.write(XmlToken.closeComment);
  }

  @override
  void visitDeclaration(XmlDeclaration node) {
    buffer.write(XmlToken.openDeclaration);
    writeAttributes(node);
    buffer.write(XmlToken.closeDeclaration);
  }

  @override
  void visitDoctype(XmlDoctype node) {
    buffer.write(XmlToken.openDoctype);
    buffer.write(XmlToken.whitespace);
    buffer.write(node.text);
    buffer.write(XmlToken.closeDoctype);
  }

  @override
  void visitDocument(XmlDocument node) {
    writeChildren(node);
  }

  @override
  void visitDocumentFragment(XmlDocumentFragment node) {
    buffer.write('#document-fragment');
  }

  @override
  void visitElement(XmlElement node) {
    buffer.write(XmlToken.openElement);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty && node.isSelfClosing) {
      buffer.write(XmlToken.closeEndElement);
    } else {
      buffer.write(XmlToken.closeElement);
      writeChildren(node);
      buffer.write(XmlToken.openEndElement);
      visit(node.name);
      buffer.write(XmlToken.closeElement);
    }
  }

  @override
  void visitName(XmlName name) {
    buffer.write(name.qualified);
  }

  @override
  void visitProcessing(XmlProcessing node) {
    buffer.write(XmlToken.openProcessing);
    buffer.write(node.target);
    if (node.text.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      buffer.write(node.text);
    }
    buffer.write(XmlToken.closeProcessing);
  }

  @override
  void visitText(XmlText node) {
    buffer.write(entityMapping.encodeText(node.text));
  }

  void writeAttributes(XmlNode node) {
    for (final attribute in node.attributes) {
      buffer.write(XmlToken.whitespace);
      visit(attribute);
    }
  }

  void writeChildren(XmlNode node) {
    node.children.forEach(visit);
  }
}
