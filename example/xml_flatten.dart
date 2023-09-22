/// XML flatten.
library xml_flatten;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml_events.dart';

final formatRegExp = RegExp(r'%(.)');

final args.ArgParser argumentParser = args.ArgParser()
  ..addOption(
    'format',
    abbr: 'f',
    help: 'Format string of each event:\n'
        '\t%s Event string\n'
        '\t%t Node type\n'
        '\t%p Position',
    defaultsTo: '%t: %s',
  )
  ..addFlag(
    'normalize',
    abbr: 'n',
    help: 'Normalize the output stream.',
    defaultsTo: true,
  );

void printUsage() {
  stdout.writeln('Usage: xml_flatten [options] {files}');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

String formatEvent(XmlEvent event, String format) =>
    format.splitMapJoin(formatRegExp, onMatch: (match) {
      switch (match.group(1)) {
        case 's':
          return event.toString();
        case 't':
          return event.nodeType.toString();
        case 'p':
          return event.start.toString();
        default:
          return match.group(1)!;
      }
    });

Future<void> main(List<String> arguments) async {
  final files = <File>[];
  final results = argumentParser.parse(arguments);
  final format = results['format'] as String;
  final normalize = results['normalize'] as bool;

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
    var stream =
        file.openRead().transform(utf8.decoder).toXmlEvents(withLocation: true);
    if (normalize) {
      stream = stream.normalizeEvents();
    }
    await stream
        .flatten()
        .map((event) => formatEvent(event, format))
        .forEach(stdout.writeln);
  }
}
