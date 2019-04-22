/// XML flatten.
library xml.example.xml_flatten;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml_events.dart' as xml_events;

final args.ArgParser argumentParser = args.ArgParser()
  ..addFlag(
    'normalize',
    abbr: 'n',
    help: 'Normalizes the output stream.',
  )
  ..addFlag(
    'text',
    abbr: 't',
    help: 'Only display text events',
  );

void printUsage() {
  stdout.writeln('Usage: xml_flatten [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

Future<void> main(List<String> arguments) async {
  final files = <File>[];
  final results = argumentParser.parse(arguments);
  final normalize = results['normalize'];
  final text = results['text'];

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
    var stream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const xml_events.XmlEventDecoder());
    if (normalize) {
      stream = stream.transform(const xml_events.XmlNormalizer());
    }
    var flatStream = stream.expand((events) => events);
    if (text) {
      flatStream =
          flatStream.where((event) => event is xml_events.XmlTextEvent);
    }
    await flatStream.forEach(print);
  }
}
