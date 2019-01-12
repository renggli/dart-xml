library xml.test.axis_test;

import 'dart:async';
import 'dart:math' show min, Random;

import 'package:test/test.dart';
import 'package:xml/xml_events.dart';

import 'assertions.dart';
import 'examples.dart';

// A stream of strings split into chunks of the given size.
Stream<String> split(String input, int Function() provider) async* {
  while (input.isNotEmpty) {
    final size = min(provider(), input.length);
    yield input.substring(0, size);
    input = input.substring(size);
  }
}

// Normalizes an iterable of events, by joining adjacent text events.
List<XmlEvent> normalize(List<XmlEvent> input) {
  final result = <XmlEvent>[];
  for (var event in input) {
    if (result.isNotEmpty &&
        result.last is XmlTextEvent &&
        event is XmlTextEvent) {
      final XmlTextEvent last = result.last;
      result.last = XmlTextEvent(last.text + event.text);
    } else {
      result.add(event);
    }
  }
  return result;
}

void assertComplete(Iterator<XmlEvent> iterator) {
  for (var i = 0; i < 2; i++) {
    expect(iterator.moveNext(), isFalse);
    expect(iterator.current, isNull);
  }
}

void main() {
  group('events', () {
    test('cdata', () {
      final iterator = parseEvents('<![CDATA[<nasty>]]>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlCDATAEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.CDATA);
      expect(event.text, '<nasty>');
      assertComplete(iterator);
    });
    test('comment', () {
      final iterator = parseEvents('<!--for amusement only-->').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlCommentEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.COMMENT);
      expect(event.text, 'for amusement only');
      assertComplete(iterator);
    });
    test('doctype', () {
      final iterator = parseEvents('<!DOCTYPE html>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlDoctypeEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.DOCUMENT_TYPE);
      expect(event.text, 'html');
      assertComplete(iterator);
    });
    test('end element', () {
      final iterator = parseEvents('</bar>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlEndElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'bar');
      assertComplete(iterator);
    });
    test('processing', () {
      final iterator = parseEvents('<?pi test?>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlProcessingEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.PROCESSING);
      expect(event.target, 'pi');
      expect(event.text, 'test');
      assertComplete(iterator);
    });
    test('start element', () {
      final iterator = parseEvents('<foo>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlStartElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'foo');
      expect(event.attributes, isEmpty);
      expect(event.isSelfClosing, isFalse);
      assertComplete(iterator);
    });
    test('start element (attributes, self-closing)', () {
      final iterator = parseEvents('<foo a="1" b=\'2\'/>').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlStartElementEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.ELEMENT);
      expect(event.name, 'foo');
      expect(event.attributes, hasLength(2));
      expect(event.attributes[0].name, 'a');
      expect(event.attributes[0].value, '1');
      expect(event.attributes[0].attributeType, XmlAttributeType.DOUBLE_QUOTE);
      expect(event.attributes[1].name, 'b');
      expect(event.attributes[1].value, '2');
      expect(event.attributes[1].attributeType, XmlAttributeType.SINGLE_QUOTE);
      expect(event.isSelfClosing, isTrue);
      assertComplete(iterator);
    });
    test('text', () {
      final iterator = parseEvents('Hello World!').iterator;
      expect(iterator.moveNext(), isTrue);
      final XmlTextEvent event = iterator.current;
      expect(event.nodeType, XmlNodeType.TEXT);
      expect(event.text, 'Hello World!');
      assertComplete(iterator);
    });
  });
  group('errors', () {
    test('empty', () {
      final iterator = parseEvents('').iterator;
      assertComplete(iterator);
    });
    test('invalid', () {
      final iterator = parseEvents('<hello').iterator;
      expect(iterator.moveNext, throwsA(isXmlParserException));
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      final XmlTextEvent event = iterator.current;
      expect(event.text, 'hello');
      assertComplete(iterator);
    });
  });
  group('chunked', () {
    final expected = parseEvents(complicatedXml)
        .map((event) => event.toString())
        .toList(growable: false);
    void chunkedTest(String title, int Function() callback) {
      test(title, () async {
        final stream = split(complicatedXml, callback);
        final actual = await stream
            .transform(const XmlDecoder())
            .expand((event) => event)
            .toList();
        expect(normalize(actual).map((event) => event.toString()), expected);
      });
    }

    for (var i = 1; i < complicatedXml.length; i++) {
      chunkedTest('fixed size $i', () => i);
    }
    for (var i = 1; i < complicatedXml.length; i++) {
      final random = Random(i);
      chunkedTest('random size $i', () => random.nextInt(i + 1));
    }
  });
  group('examples', () {
    test('extract non-empty text', () {
      final texts = parseEvents(bookstoreXml)
          .whereType<XmlTextEvent>()
          .map((event) => event.text.trim())
          .where((text) => text.isNotEmpty);
      expect(texts, ['Harry Potter', '29.99', 'Learning XML', '39.95']);
    });
    test('find specific attribute', () {
      final maxExclusive = parseEvents(shiporderXsd)
          .whereType<XmlStartElementEvent>()
          .singleWhere((event) => event.name == 'xsd:maxExclusive')
          .attributes
          .singleWhere((attribute) => attribute.name == 'value')
          .value;
      expect(maxExclusive, '100');
    });
    test('find all the genres', () {
      // Some libraries provide a sliding window iterator
      // https://github.com/renggli/dart-more/blob/master/lib/src/iterable/window.dart
      // which would make this code trivial to write and read:
      final genres = Set<String>();
      parseEvents(booksXml).reduce((previous, current) {
        if (previous is XmlStartElementEvent &&
            previous.name == 'genre' &&
            current is XmlTextEvent) {
          genres.add(current.text);
        }
        return current;
      });
      expect(
          genres,
          containsAll([
            'Computer',
            'Fantasy',
            'Romance',
            'Horror',
            'Science Fiction',
          ]));
    });
  });
}
