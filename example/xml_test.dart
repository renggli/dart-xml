/// XML test.
library;

import 'dart:convert';
import 'dart:io';

import 'package:xml/xml_events.dart';

void printUsage() {
  stdout.writeln('Usage: xml_test {files}');
  exit(1);
}

Future<void> main(List<String> arguments) async {
  final files = <File>[];

  for (final argument in arguments) {
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
    stdout.writeln(file.path);
    await file.openRead().transform(utf8.decoder).toXmlEvents()
        .handleError((Object error) => stderr.writeln('$error'))
        .drain<void>();
  }
}
