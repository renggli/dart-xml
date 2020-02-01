/// XML position printer.
library xml.example.xml_pos;

import 'dart:io';
import 'dart:math';

import 'package:args/args.dart' as args;
import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';

final args.ArgParser argumentParser = args.ArgParser();

void printUsage() {
  stdout.writeln('Usage: xml_pos [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

void main(List<String> arguments) {
  final files = <File>[];
  final results = argumentParser.parse(arguments);

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
    printUsage();
  }

  for (final file in files) {
    final result = parser.parse(file.readAsStringSync());
    if (result.isFailure) {
      stdout.writeln('Parse error in $file: $result.message');
      exit(3);
    }
    final XmlDocument document = result.value;
    for (final node in document.descendants) {
      final token = tokens[node];
      if (token != null) {
        // Print line and column of the element:
        stdout.write('${token.line}:${token.column}: ');
        // Print 50 characters, or until the next newline character:
        final newline = token.input.indexOf('\n');
        final length = newline < 0 ? token.input.length : min(50, newline);
        stdout.write(token.input.substring(0, length));
        stdout.writeln(length < token.input.length ? '...' : '');
      }
    }
    tokens.clear();
  }
}

// Custom parser that produces a mapping of nodes to tokens as a side-effect.

final Map<XmlNode, Token> tokens = {};

final Parser parser =
    PositionParserDefinition(const XmlDefaultEntityMapping.xml()).build();

class PositionParserDefinition extends XmlParserDefinition {
  PositionParserDefinition(XmlEntityMapping entityMapping)
      : super(entityMapping);

  @override
  Parser comment() => collectPosition(super.comment());

  @override
  Parser cdata() => collectPosition(super.cdata());

  @override
  Parser doctype() => collectPosition(super.doctype());

  @override
  Parser document() => collectPosition(super.document());

  @override
  Parser element() => collectPosition(super.element());

  @override
  Parser processing() => collectPosition(super.processing());

  Parser<XmlNode> collectPosition(Parser parser) => parser.token().map((token) {
        tokens[token.value] = token;
        return token.value;
      });
}
