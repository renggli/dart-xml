/// XML pretty printer and highlighter.
library;

import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml.dart';

const _entityMapping = XmlDefaultEntityMapping.xml();

const String _ansiReset = '\u001b[0m';
const String _ansiRed = '\u001b[31m';
const String _ansiGreen = '\u001b[32m';
const String _ansiYellow = '\u001b[33m';
const String _ansiBlue = '\u001b[34m';
const String _ansiMagenta = '\u001b[35m';
const String _ansiCyan = '\u001b[36m';

const String _attributeStyle = _ansiBlue;
const String _cdataStyle = _ansiYellow;
const String _commentStyle = _ansiGreen;
const String _declarationStyle = _ansiCyan;
const String _doctypeStyle = _ansiCyan;
const String _documentStyle = _ansiReset;
const String _documentFragmentStyle = _ansiCyan;
const String _elementStyle = _ansiMagenta;
const String _nameStyle = _ansiRed;
const String _processingStyle = _ansiCyan;
const String _textStyle = _ansiReset;
const String _namespaceStyle = _ansiRed;

final args.ArgParser _argumentParser = args.ArgParser()
  ..addFlag(
    'color',
    abbr: 'c',
    help: 'Colorize the output.',
    defaultsTo: stdout.supportsAnsiEscapes,
  )
  ..addOption(
    'indent',
    abbr: 'i',
    help: 'Customize the indention when pretty printing.',
    defaultsTo: '  ',
  )
  ..addOption(
    'newline',
    abbr: 'n',
    help: 'Change the newline character when pretty printing.',
    defaultsTo: '\n',
  )
  ..addFlag(
    'pretty',
    abbr: 'p',
    help: 'Reformat the output to be pretty.',
    defaultsTo: true,
  );

void _printUsage() {
  stdout.writeln('Usage: xml_pp [options] {files}');
  stdout.writeln();
  stdout.writeln(_argumentParser.usage);
  exit(1);
}

void main(List<String> arguments) {
  final files = <File>[];
  final results = _argumentParser.parse(arguments);
  final color = results['color'] as bool;
  final indent = results['indent'] as String;
  final newLine = results['newline'] as String;
  final pretty = results['pretty'] as bool;

  for (final argument in results.rest) {
    final file = File(argument);
    if (file.existsSync()) {
      files.add(file);
    } else {
      stderr.writeln('File not found: $file');
      exit(2);
    }
  }
  if (files.isEmpty) {
    _printUsage();
  }

  // Select the appropriate printing visitor. For simpler use-cases one would
  // just call `document.toXmlString(pretty: true, indent: '  ')`.
  final visitor = pretty
      ? (color
            ? XmlColoredPrettyWriter(
                stdout,
                entityMapping: _entityMapping,
                indent: indent,
                newLine: newLine,
              )
            : XmlPrettyWriter(
                stdout,
                entityMapping: _entityMapping,
                indent: indent,
                newLine: newLine,
              ))
      : (color
            ? XmlColoredWriter(stdout, entityMapping: _entityMapping)
            : XmlWriter(stdout, entityMapping: _entityMapping));
  for (final file in files) {
    visitor.visit(XmlDocument.parse(file.readAsStringSync()));
  }
}

mixin ColoredWriter {
  StringSink get buffer;

  List<String> get styles;

  void style(String style, void Function() callback) {
    styles.add(style);
    buffer.write(style);
    callback();
    styles.removeLast();
    buffer.write(styles.isEmpty ? _ansiReset : styles.last);
  }
}

class XmlColoredWriter extends XmlWriter with ColoredWriter {
  XmlColoredWriter(super.buffer, {super.entityMapping});

  @override
  final List<String> styles = [];

  @override
  void visitAttribute(XmlAttribute node) =>
      style(_attributeStyle, () => super.visitAttribute(node));

  @override
  void visitCDATA(XmlCDATA node) =>
      style(_cdataStyle, () => super.visitCDATA(node));

  @override
  void visitComment(XmlComment node) =>
      style(_commentStyle, () => super.visitComment(node));

  @override
  void visitDeclaration(XmlDeclaration node) =>
      style(_declarationStyle, () => super.visitDeclaration(node));

  @override
  void visitDocument(XmlDocument node) =>
      style(_documentStyle, () => super.visitDocument(node));

  @override
  void visitDocumentFragment(XmlDocumentFragment node) =>
      style(_documentFragmentStyle, () => super.visitDocumentFragment(node));

  @override
  void visitDoctype(XmlDoctype node) =>
      style(_doctypeStyle, () => super.visitDoctype(node));

  @override
  void visitElement(XmlElement node) =>
      style(_elementStyle, () => super.visitElement(node));

  @override
  void visitName(XmlName name) =>
      style(_nameStyle, () => super.visitName(name));

  @override
  void visitProcessing(XmlProcessing node) =>
      style(_processingStyle, () => super.visitProcessing(node));

  @override
  void visitText(XmlText node) =>
      style(_textStyle, () => super.visitText(node));

  @override
  void visitNamespace(XmlNamespace node) =>
      style(_namespaceStyle, () => super.visitNamespace(node));
}

class XmlColoredPrettyWriter extends XmlPrettyWriter with ColoredWriter {
  XmlColoredPrettyWriter(
    super.buffer, {
    super.entityMapping,
    super.indent,
    super.newLine,
  });
  @override
  final List<String> styles = [];

  @override
  void visitAttribute(XmlAttribute node) =>
      style(_attributeStyle, () => super.visitAttribute(node));

  @override
  void visitCDATA(XmlCDATA node) =>
      style(_cdataStyle, () => super.visitCDATA(node));

  @override
  void visitComment(XmlComment node) =>
      style(_commentStyle, () => super.visitComment(node));

  @override
  void visitDeclaration(XmlDeclaration node) =>
      style(_declarationStyle, () => super.visitDeclaration(node));

  @override
  void visitDocument(XmlDocument node) =>
      style(_documentStyle, () => super.visitDocument(node));

  @override
  void visitDocumentFragment(XmlDocumentFragment node) =>
      style(_documentFragmentStyle, () => super.visitDocumentFragment(node));

  @override
  void visitDoctype(XmlDoctype node) =>
      style(_doctypeStyle, () => super.visitDoctype(node));

  @override
  void visitElement(XmlElement node) =>
      style(_elementStyle, () => super.visitElement(node));

  @override
  void visitName(XmlName name) =>
      style(_nameStyle, () => super.visitName(name));

  @override
  void visitProcessing(XmlProcessing node) =>
      style(_processingStyle, () => super.visitProcessing(node));

  @override
  void visitText(XmlText node) =>
      style(_textStyle, () => super.visitText(node));

  @override
  void visitNamespace(XmlNamespace node) =>
      style(_namespaceStyle, () => super.visitNamespace(node));
}
