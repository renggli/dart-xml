/// XML position printer.
import 'dart:io';
import 'dart:math';

// ignore: import_of_legacy_library_into_null_safe
import 'package:args/args.dart' as args;
import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';

final args.ArgParser argumentParser = args.ArgParser()
  ..addOption(
    'position',
    abbr: 'p',
    help: 'Print character index instead of line:column.',
    allowed: ['start', 'stop', 'startstop', 'line', 'column', 'linecolumn'],
    defaultsTo: 'linecolumn',
  )
  ..addOption(
    'limit',
    abbr: 'l',
    help: 'Limit output to the specified number of characters.',
    defaultsTo: '60',
  );

void printUsage() {
  stdout.writeln('Usage: xml_pos [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

void main(List<String> arguments) {
  final files = <File>[];
  final results = argumentParser.parse(arguments);
  final position = results['position'];
  final limit = int.parse(results['limit']);

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
        final positionString = outputPosition(position, token).padLeft(10);
        final tokenString = outputString(limit, token);
        stdout.writeln('$positionString: $tokenString');
      }
    }
    tokens.clear();
  }
}

String outputPosition(String position, Token token) {
  switch (position) {
    case 'start':
      return '${token.start}';
    case 'stop':
      return '${token.stop}';
    case 'startstop':
      return '${token.start}-${token.stop}';
    case 'line':
      return '${token.line}';
    case 'column':
      return '${token.column}';
    default:
      return '${token.line}:${token.column}';
  }
}

String outputString(int limit, Token token) {
  final input = token.input.trim();
  final index = input.indexOf('\n');
  final length = min(limit, index < 0 ? input.length : index);
  final output = input.substring(0, length);
  return output.length < input.length ? '$output...' : output;
}

// Custom parser that produces a mapping of nodes to tokens as a side-effect.

final Map<XmlNode, Token> tokens = {};

final Parser parser = PositionParserDefinition(defaultEntityMapping).build();

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
