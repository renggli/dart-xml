import 'dart:convert';
import 'dart:io';

import 'package:xml/xml_events.dart';

final HttpClient httpClient = HttpClient();

void main() async {
  final url = Uri.parse('https://ip-api.com/xml/');
  final request = await httpClient.getUrl(url);
  final response = await request.close();
  await response
      .transform(utf8.decoder)
      .toXmlEvents()
      .normalizeEvents()
      .expand((events) => events)
      .forEach((event) => print(event));
}
