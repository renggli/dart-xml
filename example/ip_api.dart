/// IP Geolocation API using ip-api.com.
library xml.example.ip_api;

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart' as args;
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml_events.dart' as xml_events;

final HttpClient httpClient = HttpClient();

final args.ArgParser argumentParser = args.ArgParser()
  ..addFlag(
    'incremental',
    abbr: 'i',
    defaultsTo: true,
    help: 'Incrementally parses and prints the response',
  )
  ..addMultiOption('fields',
      abbr: 'f',
      defaultsTo: ['status', 'message', 'query', 'country', 'city'],
      allowed: [
        'as',
        'asname',
        'city',
        'continent',
        'continentCode',
        'country',
        'countryCode',
        'currency',
        'district',
        'isp',
        'lat',
        'lon',
        'message',
        'mobile',
        'org',
        'proxy',
        'query',
        'region',
        'regionName',
        'reverse',
        'status',
        'timezone',
        'zip',
      ],
      help: 'Fields to be returned')
  ..addOption(
    'lang',
    abbr: 'l',
    defaultsTo: 'en',
    allowed: ['en', 'de', 'es', 'pt-BR', 'fr', 'ja', 'zh-CN', 'ru'],
    help: 'Localizes city, region and country names',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    defaultsTo: false,
    help: 'Displays the help text',
  );

void printUsage() {
  stdout.writeln('Usage: ip_lookup -s [query]');
  stdout.writeln();
  stdout.writeln(argumentParser.usage);
  exit(1);
}

Future<void> lookupIp(args.ArgResults results, [String query = '']) async {
  final bool incremental = results['incremental'];
  final List<String> fields = results['fields'];
  final String lang = results['lang'];

  // Build the query URL, perform the request, and convert response to UTF-8.
  final url = Uri.parse(
      'http://ip-api.com/xml/$query?fields=${fields.join(',')}&lang=$lang');
  final request = await httpClient.getUrl(url);
  final response = await request.close();
  final stream = response.transform(utf8.decoder);

  // Typically you would only implement one of the following two approaches,
  // but for demonstration sake we show both in this example:
  if (incremental) {
    // Decode the input stream, normalize it and serialize events, then extract
    // the information to be printed. This approach uses less memory and is
    // emitting results immediately; thought the implementation is more
    // involved.
    var level = 0;
    String currentField;
    await stream
        .transform(const xml_events.XmlEventDecoder())
        .transform(const xml_events.XmlNormalizer())
        .expand((events) => events)
        .forEach((event) {
      if (event is xml_events.XmlStartElementEvent) {
        level++;
        if (level == 2) {
          currentField = event.name;
          stdout.write('$currentField: ');
        }
      } else if (event is xml_events.XmlTextEvent && currentField != null) {
        stdout.write(event.text);
      } else if (event is xml_events.XmlCDATAEvent && currentField != null) {
        stdout.write(event.text);
      } else if (event is xml_events.XmlEndElementEvent) {
        if (event.name == currentField) {
          currentField = null;
          stdout.writeln();
        }
        level--;
      }
    });
  } else {
    // Wait until we have the full response body, then parse the input to a
    // XML DOM tree and extract the information to be printed. This approach
    // uses more memory and waits for the complete data to be downloaded
    // and parsed before printing any results; thought the implementation is
    // simpler.
    final input = await stream.join();
    final document = xml.parse(input);
    for (final element in document.rootElement.children) {
      if (element is xml.XmlElement) {
        stdout.writeln('${element.name}: ${element.text}');
      }
    }
  }
}

Future<void> main(List<String> arguments) async {
  final results = argumentParser.parse(arguments);

  if (results['help']) {
    printUsage();
  }

  if (results.rest.isEmpty) {
    await lookupIp(results);
  } else {
    for (final query in results.rest) {
      await lookupIp(results, query);
      stdout.writeln();
    }
  }
}
