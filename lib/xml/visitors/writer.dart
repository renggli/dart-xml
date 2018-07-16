library xml.visitors.writer;

import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/cdata.dart';
import 'package:xml/xml/nodes/comment.dart';
import 'package:xml/xml/nodes/doctype.dart';
import 'package:xml/xml/nodes/document.dart';
import 'package:xml/xml/nodes/document_fragment.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/nodes/node.dart';
import 'package:xml/xml/nodes/processing.dart';
import 'package:xml/xml/nodes/text.dart';
import 'package:xml/xml/utils/entities.dart';
import 'package:xml/xml/utils/name.dart';
import 'package:xml/xml/utils/token.dart';
import 'package:xml/xml/visitors/visitor.dart';

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter extends XmlVisitor {
  final StringBuffer buffer;

  XmlWriter(this.buffer);

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlToken.equals);
    final quote = attributeQuote[node.attributeType];
    buffer.write(quote);
    buffer.write(encodeXmlAttributeValue(node.value, node.attributeType));
    buffer.write(quote);
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
    if (node.children.isEmpty) {
      buffer.write(XmlToken.whitespace);
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
    buffer.write(encodeXmlText(node.text));
  }

  void writeAttributes(XmlNode node) {
    for (var attribute in node.attributes) {
      buffer.write(XmlToken.whitespace);
      visit(attribute);
    }
  }

  void writeChildren(XmlNode node) {
    node.children.forEach(visit);
  }
}
