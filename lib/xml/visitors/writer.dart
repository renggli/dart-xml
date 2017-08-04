library xml.visitors.writer;

import 'package:xml/xml/grammar.dart' show XmlGrammarDefinition;
import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/cdata.dart' show XmlCDATA;
import 'package:xml/xml/nodes/comment.dart' show XmlComment;
import 'package:xml/xml/nodes/doctype.dart' show XmlDoctype;
import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/nodes/processing.dart' show XmlProcessing;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/utils/entities.dart'
    show attributeQuote, encodeXmlAttributeValue, encodeXmlText;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter extends XmlVisitor {
  final StringBuffer buffer;

  XmlWriter(this.buffer);

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlGrammarDefinition.EQUALS);
    final quote = attributeQuote[node.attributeType];
    buffer.write(quote);
    buffer.write(encodeXmlAttributeValue(node.value, node.attributeType));
    buffer.write(quote);
  }

  @override
  void visitCDATA(XmlCDATA node) {
    buffer.write(XmlGrammarDefinition.OPEN_CDATA);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_CDATA);
  }

  @override
  void visitComment(XmlComment node) {
    buffer.write(XmlGrammarDefinition.OPEN_COMMENT);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_COMMENT);
  }

  @override
  void visitDoctype(XmlDoctype node) {
    buffer.write(XmlGrammarDefinition.OPEN_DOCTYPE);
    buffer.write(XmlGrammarDefinition.WHITESPACE);
    buffer.write(node.text);
    buffer.write(XmlGrammarDefinition.CLOSE_DOCTYPE);
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
    buffer.write(XmlGrammarDefinition.OPEN_ELEMENT);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(XmlGrammarDefinition.CLOSE_END_ELEMENT);
    } else {
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
      writeChildren(node);
      buffer.write(XmlGrammarDefinition.OPEN_END_ELEMENT);
      visit(node.name);
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
    }
  }

  @override
  void visitName(XmlName name) {
    buffer.write(name.qualified);
  }

  @override
  void visitProcessing(XmlProcessing node) {
    buffer.write(XmlGrammarDefinition.OPEN_PROCESSING);
    buffer.write(node.target);
    if (node.text.isNotEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(node.text);
    }
    buffer.write(XmlGrammarDefinition.CLOSE_PROCESSING);
  }

  @override
  void visitText(XmlText node) {
    buffer.write(encodeXmlText(node.text));
  }

  void writeAttributes(XmlNode node) {
    for (var attribute in node.attributes) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      visit(attribute);
    }
  }

  void writeChildren(XmlNode node) {
    node.children.forEach(visit);
  }
}
