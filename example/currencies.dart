/// Prints currency exchange table using www.floatrates.com.
library;

import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

final HttpClient _httpClient = HttpClient();

void _writeCell([Object? output]) {
  final contents = output?.toString() ?? '';
  stdout.write(contents.padLeft(14, ' '));
  stdout.write('  ');
}

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stdout.writeln('Example: currencies EUR CHF ...');
    exit(1);
  }
  final currencies = arguments
      .map((argument) => argument.trim().toLowerCase())
      .toSet();
  _writeCell();
  currencies.forEach(_writeCell);
  stdout.writeln();
  for (final sourceCurrency in currencies) {
    final url = 'https://www.floatrates.com/daily/$sourceCurrency.xml';
    final request = await _httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final stream = response.transform(utf8.decoder);
    final contents = await stream.join();
    final document = XmlDocument.parse(contents);
    _writeCell(sourceCurrency);
    for (final targetCurrency in currencies) {
      if (sourceCurrency == targetCurrency) {
        _writeCell();
      } else {
        _writeCell(
          document.rootElement
              .findElements('item')
              .where(
                (item) => item
                    .findElements('targetCurrency')
                    .any(
                      (element) =>
                          element.innerText.toLowerCase() == targetCurrency,
                    ),
              )
              .first
              .findElements('exchangeRate')
              .first
              .innerText,
        );
      }
    }
    stdout.writeln();
  }
}
