library xml.visitors.pretty_writer;

import 'package:xml/src/xml/nodes/cdata.dart';
import 'package:xml/src/xml/nodes/comment.dart';
import 'package:xml/src/xml/nodes/doctype.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/processing.dart';
import 'package:xml/src/xml/nodes/text.dart';
import 'package:xml/src/xml/utils/token.dart';
import 'package:xml/src/xml/visitors/writer.dart';

/// A visitor that writes XML nodes correctly indented and with whitespaces
/// adapted.
class XmlPrettyWriter extends XmlWriter {
  int level = 0;
  final String indent;

  XmlPrettyWriter(buffer, this.level, this.indent) : super(buffer);

  @override
  void visitCDATA(XmlCDATA node) {
    newLine();
    super.visitCDATA(node);
  }

  @override
  void visitComment(XmlComment node) {
    newLine();
    super.visitComment(node);
  }

  @override
  void visitDoctype(XmlDoctype node) {
    newLine();
    super.visitDoctype(node);
  }

  @override
  void visitElement(XmlElement node) {
    newLine();
    buffer.write(XmlToken.openElement);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty && node.isSelfClosing) {
      buffer.write(XmlToken.closeEndElement);
    } else {
      buffer.write(XmlToken.closeElement);
      level++;
      writeChildren(node);
      level--;
      if (!node.children.every((each) => each is XmlText)) {
        newLine();
      }
      buffer.write(XmlToken.openEndElement);
      visit(node.name);
      buffer.write(XmlToken.closeElement);
    }
  }

  @override
  void visitProcessing(XmlProcessing node) {
    newLine();
    super.visitProcessing(node);
  }

  @override
  void visitText(XmlText node) {
    // If text is purely whitespace, don't output to the buffer
    // the indentation and newlines will be handled elsewhere.
    if (node.text.trim().isNotEmpty) {
      super.visitText(node);
    }
  }

  void newLine() {
    if (buffer.isNotEmpty) {
      buffer.writeln();
    }
    for (var i = 0; i < level; i++) {
      buffer.write(indent);
    }
  }
}
