part of xml;

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter extends XmlVisitor {

  final StringBuffer buffer;

  XmlWriter(this.buffer);

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlGrammarDefinition.EQUALS);
    final attributeQuote = _attributeQuote[node.attributeType];
    buffer.write(attributeQuote);
    buffer.write(_encodeXmlAttributeValue(node.value, node.attributeType));
    buffer.write(attributeQuote);
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
    buffer.write(_encodeXmlText(node.text));
  }

  void writeAttributes(XmlNode node) {
    for (var attribute in node.attributes) {
      buffer.write(XmlGrammarDefinition.WHITESPACE);
      visit(attribute);
    }
  }

  void writeChildren(XmlNode node) {
    for (var child in node.children) {
      visit(child);
    }
  }
}


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
    for (int i = 0; i < level; i++) {
      buffer.write(indent);
    }
  }
}
