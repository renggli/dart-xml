/// XML XPath evaluator.
library;

import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final args.ArgParser _argumentParser = args.ArgParser()
  ..addOption('xpath', abbr: 'x', help: 'XPath expression to evaluate.')
  ..addFlag(
    'pretty',
    abbr: 'p',
    help: 'Pretty print matching XML node results.',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Display this help message.',
  );

Never _printUsage([int exitCode = 1]) {
  stdout.writeln('Usage: xml_xpath [options] -x <expression> [files]');
  stdout.writeln('       xml_xpath [options] <expression> [files]');
  stdout.writeln();
  stdout.writeln(_argumentParser.usage);
  exit(exitCode);
}

void _printSequence(XPathSequence sequence, {required bool pretty}) {
  for (final item in sequence) {
    if (item is XPathNode) {
      final node = item.node;
      if (node is XmlText) {
        stdout.writeln(node.value);
      } else {
        stdout.writeln(node.toXmlString(pretty: pretty));
      }
    } else {
      stdout.writeln(item.stringValue);
    }
  }
}

void main(List<String> arguments) {
  final args.ArgResults results;
  try {
    results = _argumentParser.parse(arguments);
  } on args.ArgParserException catch (error) {
    stderr.writeln(error.message);
    _printUsage();
  }

  if (results['help'] as bool) {
    _printUsage(0);
  }

  var expression = results['xpath'] as String?;
  final rest = results.rest.toList();

  if (expression == null) {
    if (rest.isEmpty) {
      _printUsage();
    }
    expression = rest.removeAt(0);
  }

  final files = <File>[];
  for (final argument in rest) {
    final file = File(argument);
    if (file.existsSync()) {
      files.add(file);
    } else {
      stderr.writeln('File not found: $file');
      exit(2);
    }
  }

  final pretty = results['pretty'] as bool;

  if (files.isEmpty) {
    final XPathSequence sequence;
    try {
      sequence = XPathConfiguration.standard().context().evaluate(expression);
    } on XmlException catch (exception) {
      stderr.writeln('XPath error: ${exception.message}');
      exit(4);
    }
    _printSequence(sequence, pretty: pretty);
    return;
  }

  for (final file in files) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(file.readAsStringSync());
    } on XmlException catch (exception) {
      stderr.writeln('XML error in $file: ${exception.message}');
      exit(3);
    }

    final XPathSequence sequence;
    try {
      sequence = document.xpathEvaluate(expression);
    } on XmlException catch (exception) {
      stderr.writeln('XPath error: ${exception.message}');
      exit(4);
    }

    _printSequence(sequence, pretty: pretty);
  }
}
