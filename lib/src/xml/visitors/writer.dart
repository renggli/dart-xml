import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../mixins/has_attributes.dart';
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
import '../utils/token.dart';
import 'visitor.dart';

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter with XmlVisitor {
  XmlWriter(this.buffer, {XmlEntityMapping? entityMapping})
    : entityMapping = entityMapping ?? defaultEntityMapping,
      isHtml =
          entityMapping == const XmlDefaultEntityMapping.html() ||
          entityMapping == const XmlDefaultEntityMapping.html5();

  final StringSink buffer;
  final XmlEntityMapping entityMapping;
  final bool isHtml;
  bool inHtmlScript = false;

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlToken.equals);
    buffer.write(
      entityMapping.encodeAttributeValueWithQuotes(
        node.value,
        node.attributeType,
      ),
    );
  }

  @override
  void visitCDATA(XmlCDATA node) {
    buffer.write(XmlToken.openCDATA);
    buffer.write(node.value);
    buffer.write(XmlToken.closeCDATA);
  }

  @override
  void visitComment(XmlComment node) {
    buffer.write(XmlToken.openComment);
    buffer.write(node.value);
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
    buffer.write(node.name);
    if (node.externalId != null) {
      buffer.write(XmlToken.whitespace);
      buffer.write(node.externalId);
    }
    if (node.internalSubset != null) {
      buffer.write(XmlToken.whitespace);
      buffer.write(XmlToken.openDoctypeIntSubset);
      buffer.write(node.internalSubset);
      buffer.write(XmlToken.closeDoctypeIntSubset);
    }
    buffer.write(XmlToken.closeDoctype);
  }

  @override
  void visitDocument(XmlDocument node) {
    writeIterable(node.children);
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
      if (isHtml && node.qualifiedName == XmlToken.htmlScriptElement) {
        inHtmlScript = true;
      }
      writeIterable(node.children);
      if (inHtmlScript) {
        inHtmlScript = false;
      }
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
    if (node.value.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      buffer.write(node.value);
    }
    buffer.write(XmlToken.closeProcessing);
  }

  @override
  void visitText(XmlText node) {
    if (inHtmlScript) {
      buffer.write(node.value);
      return;
    }
    buffer.write(entityMapping.encodeText(node.value));
  }

  void writeAttributes(XmlHasAttributes node) {
    if (node.attributes.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      writeIterable(node.attributes, XmlToken.whitespace);
    }
  }

  void writeIterable(Iterable<XmlHasVisitor> nodes, [String? separator]) {
    final iterator = nodes.iterator;
    if (iterator.moveNext()) {
      if (separator == null || separator.isEmpty) {
        do {
          visit(iterator.current);
        } while (iterator.moveNext());
      } else {
        visit(iterator.current);
        while (iterator.moveNext()) {
          buffer.write(separator);
          visit(iterator.current);
        }
      }
    }
  }
}
