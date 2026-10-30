import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

void main() {
  group('XmlByteStreamDecoder', () {
    test('utf-8 without bom', () async {
      const xml = '<root>hello</root>';
      final bytes = Stream.value(utf8.encode(xml));
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('utf-8 with bom', () async {
      const xml = '<root>hello</root>';
      final bytes = Stream.value([0xEF, 0xBB, 0xBF, ...utf8.encode(xml)]);
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('utf-16 be with bom', () async {
      const xml = '<root>hello</root>';
      final beBytes = <int>[0xFE, 0xFF];
      for (final codeUnit in xml.codeUnits) {
        beBytes.add((codeUnit >> 8) & 0xFF);
        beBytes.add(codeUnit & 0xFF);
      }
      final bytes = Stream.fromIterable(
        beBytes.map((b) => [b]),
      ); // 1 byte per chunk
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('utf-16 le with bom', () async {
      const xml = '<root>hello</root>';
      final leBytes = <int>[0xFF, 0xFE];
      for (final codeUnit in xml.codeUnits) {
        leBytes.add(codeUnit & 0xFF);
        leBytes.add((codeUnit >> 8) & 0xFF);
      }
      final bytes = Stream.fromIterable(
        leBytes.map((b) => [b]),
      ); // 1 byte per chunk
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('latin-1 with encoding declaration', () async {
      const xml = '<?xml version="1.0" encoding="ISO-8859-1"?><root>©</root>';
      final bytes = Stream.value(latin1.encode(xml));
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('ascii with encoding declaration', () async {
      const xml = '<?xml version="1.0" encoding="us-ascii"?><root>test</root>';
      final bytes = Stream.value(ascii.encode(xml));
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals(xml);
    });

    test('multi-chunk stream after initialization', () async {
      const chunk1 = '<root>';
      const chunk2 = 'content';
      const chunk3 = '</root>';
      final bytes = Stream.fromIterable([
        utf8.encode(chunk1),
        utf8.encode(chunk2),
        utf8.encode(chunk3),
      ]);
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals('$chunk1$chunk2$chunk3');
    });

    test('short stream with fewer than 4 bytes', () async {
      final bytes = Stream.value(utf8.encode('<a'));
      final decoded = await bytes.decodeXmlStream().join();
      check(decoded).equals('<a');
    });

    test('stream toXmlEvents', () async {
      const xml = '<root id="1">text</root>';
      final bytes = Stream.value(utf8.encode(xml));
      final events = await bytes.toXmlEvents().flatten().toList();
      check(events).length.equals(3);
      check(events[0]).isA<XmlStartElementEvent>();
      check(events[1]).isA<XmlTextEvent>();
      check(events[2]).isA<XmlEndElementEvent>();
    });
  });

  group('XmlDocument BOM stripping', () {
    test('document parse with bom', () {
      final doc = XmlDocument.parse('\uFEFF<root><child/></root>');
      check(doc.rootElement.name.local).equals('root');
    });

    test('document fragment parse with bom', () {
      final frag = XmlDocumentFragment.parse('\uFEFF<a/><b/>');
      check(frag.children).length.equals(2);
    });
  });
}
