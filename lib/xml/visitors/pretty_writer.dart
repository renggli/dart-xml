library xml.visitors.pretty_writer;

import 'package:xml/xml/grammar.dart' show XmlGrammarDefinition;
import 'package:xml/xml/nodes/cdata.dart' show XmlCDATA;
import 'package:xml/xml/nodes/comment.dart' show XmlComment;
import 'package:xml/xml/nodes/doctype.dart' show XmlDoctype;
import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/processing.dart' show XmlProcessing;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/visitors/writer.dart' show XmlWriter;

/// A visitor that writes XML nodes correctly indented and with whitespaces adapted.
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
    buffer.write(XmlGrammarDefinition.OPEN_ELEMENT);
    visit(node.name);
    writeAttributes(node);
    if (node.children.isEmpty) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      buffer.write(XmlGrammarDefinition.CLOSE_END_ELEMENT);
    } else {
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
      level++;
      writeChildren(node);
      level--;
      if (!node.children.every((each) => each is XmlText)) {
        newLine();
      }
      buffer.write(XmlGrammarDefinition.OPEN_END_ELEMENT);
      visit(node.name);
      buffer.write(XmlGrammarDefinition.CLOSE_ELEMENT);
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
