/// XML pretty printer.
library xml.example.xml_pp;

import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml.dart' as xml;

final args.ArgParser argumentParser = args.ArgParser()
  ..addOption('indent',
      abbr: 'i',
      help: 'Customizes the indention when pretty printing.',
      defaultsTo: '  ');

void printUsage() {
  stdout.writeln('Usage: xml_pp [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

void main(List<String> arguments) {
  final files = <File>[];
  final results = argumentParser.parse(arguments);
  final indent = results['indent'];

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
    final document = xml.parse(file.readAsStringSync());
    stdout.writeln(document.toXmlString(pretty: true, indent: indent));
  }
}
