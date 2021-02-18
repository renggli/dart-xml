import 'dart:convert';
import 'dart:math' show min, Random;

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'assertions.dart';
import 'examples.dart';

void assertComplete(Iterator<XmlEvent> iterator) {
  for (var i = 0; i < 2; i++) {
    expect(iterator.moveNext(), isFalse);
  }
}

Stream<String> splitString(String input, int Function() splitter) async* {
  while (input.isNotEmpty) {
    final size = min(splitter(), input.length);
    yield input.substring(0, size);
    input = input.substring(size);
  }
}

Stream<List<T>> splitList<T>(List<T> input, int Function() splitter) async* {
  while (input.isNotEmpty) {
    final size = min(splitter(), input.length);
    yield input.sublist(0, size);
    input = input.sublist(size);
  }
}

void main() {
  group('iterable', () {
    group('events', () {
      test('cdata', () {
        final iterator = parseEvents('<![CDATA[<nasty>]]>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlCDATAEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.CDATA);
        expect(event.text, '<nasty>');
        final other = XmlCDATAEvent(event.text);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('comment', () {
        final iterator = parseEvents('<!--for amusement only-->').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlCommentEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.COMMENT);
        expect(event.text, 'for amusement only');
        final other = XmlCommentEvent(event.text);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('declaration', () {
        final iterator = parseEvents('<?xml?>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlDeclarationEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.DECLARATION);
        expect(event.attributes, isEmpty);
        final other = XmlDeclarationEvent(event.attributes);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('declaration (attributes)', () {
        final iterator =
            parseEvents('<?xml version="1.0" author=\'lfr\'?>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlDeclarationEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.DECLARATION);
        expect(event.attributes, hasLength(2));
        expect(event.attributes[0].name, 'version');
        expect(event.attributes[0].value, '1.0');
        expect(
            event.attributes[0].attributeType, XmlAttributeType.DOUBLE_QUOTE);
        expect(event.attributes[1].name, 'author');
        expect(event.attributes[1].value, 'lfr');
        expect(
            event.attributes[1].attributeType, XmlAttributeType.SINGLE_QUOTE);
        final other = XmlDeclarationEvent(event.attributes);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('doctype', () {
        final iterator = parseEvents('<!DOCTYPE html>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlDoctypeEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.DOCUMENT_TYPE);
        expect(event.text, 'html');
        final other = XmlDoctypeEvent(event.text);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('end element', () {
        final iterator = parseEvents('</bar>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlEndElementEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.ELEMENT);
        expect(event.name, 'bar');
        final other = XmlEndElementEvent(event.name);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('processing', () {
        final iterator = parseEvents('<?pi test?>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlProcessingEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.PROCESSING);
        expect(event.target, 'pi');
        expect(event.text, 'test');
        final other = XmlProcessingEvent(event.target, event.text);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('start element', () {
        final iterator = parseEvents('<foo>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlStartElementEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.ELEMENT);
        expect(event.name, 'foo');
        expect(event.attributes, isEmpty);
        expect(event.isSelfClosing, isFalse);
        final other = XmlStartElementEvent(
            event.name, event.attributes, event.isSelfClosing);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('start element (attributes, self-closing)', () {
        final iterator = parseEvents('<foo a="1" b=\'2\'/>').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlStartElementEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.ELEMENT);
        expect(event.name, 'foo');
        expect(event.attributes, hasLength(2));
        expect(event.attributes[0].name, 'a');
        expect(event.attributes[0].value, '1');
        expect(
            event.attributes[0].attributeType, XmlAttributeType.DOUBLE_QUOTE);
        expect(event.attributes[1].name, 'b');
        expect(event.attributes[1].value, '2');
        expect(
            event.attributes[1].attributeType, XmlAttributeType.SINGLE_QUOTE);
        expect(event.isSelfClosing, isTrue);
        final other = XmlStartElementEvent(
            event.name,
            event.attributes
                .map((attr) => XmlEventAttribute(
                    attr.name, attr.value, attr.attributeType))
                .toList(),
            event.isSelfClosing);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
      });
      test('text', () {
        final iterator = parseEvents('Hello World!').iterator;
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlTextEvent;
        assertComplete(iterator);
        expect(event.nodeType, XmlNodeType.TEXT);
        expect(event.text, 'Hello World!');
        final other = XmlTextEvent(event.text);
        expect(event, other);
        expect(event.hashCode, other.hashCode);
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
        expect(iterator.moveNext(), isTrue);
        final event = iterator.current as XmlTextEvent;
        expect(event.text, 'hello');
        assertComplete(iterator);
      });
      test('unexpected end tag', () {
        expect(
            () => const XmlNodeDecoder().convert([
                  XmlEndElementEvent('foo'),
                ]),
            throwsA(isXmlTagException));
      });
      test('not matching end tag', () {
        expect(
            () => const XmlNodeDecoder().convert([
                  XmlStartElementEvent('foo', [], false),
                  XmlEndElementEvent('bar')
                ]),
            throwsA(isXmlTagException));
      });
      test('missing end tag', () {
        expect(
            () => const XmlNodeDecoder().convert([
                  XmlStartElementEvent('foo', [], false),
                ]),
            throwsA(isXmlTagException));
      });
      test('not consumed input', () {
        final accumulator = ChunkedConversionSink<List<XmlEvent>>.withCallback(
            (accumulated) => fail('Not supposed to be reached.'));
        final converter = XmlEventDecoder().startChunkedConversion(accumulator);
        expect(() => converter.addSlice('a<', 0, 2, true),
            throwsA(isXmlParserException));
        expect(converter.close, throwsA(isXmlParserException));
      });
    });
  });
  group('chunked', () {
    void chunkedTest(
        String title,
        String input,
        void Function(String string, List<XmlEvent> events,
                XmlDocument document, int Function() splitter)
            callback) {
      group(title, () {
        final string = XmlDocument.parse(input).toXmlString(pretty: true);
        for (var i = string.length; i > 0; i ~/= 2) {
          test('chunks sized $i', () {
            final events = parseEvents(string).toList(growable: false);
            final document = XmlDocument.parse(string);
            callback(string, events, document, () => i);
          });
        }
        final random = Random(title.hashCode);
        for (var i = 1; i <= 64; i *= 2) {
          test('chunks randomly sized up to $i', () {
            final events = parseEvents(string).toList(growable: false);
            final document = XmlDocument.parse(string);
            callback(string, events, document, () => random.nextInt(i + 1));
          });
        }
      });
    }

    chunkedTest('string -> events', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitString(string, splitter)
          .toXmlEvents()
          .normalizeEvents()
          .flatten()
          .toList();
      expect(actual, events);
    });
    chunkedTest('events -> nodes', complicatedXml,
        (string, events, document, splitter) async {
      final actual =
          await splitList(events, splitter).toXmlNodes().flatten().toList();
      expect(
          actual,
          pairwiseCompare<XmlNode, XmlNode>(document.children,
              (actual, expected) {
            compareNode(actual, expected);
            return true;
          }, 'not matching'));
    });
    chunkedTest('nodes -> events', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(document.children, splitter)
          .toXmlEvents()
          .flatten()
          .toList();
      expect(actual, events);
    });
    chunkedTest('events -> string', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter).toXmlString().join();
      expect(actual, string);
    });
    chunkedTest('string -> events -> string', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitString(string, splitter)
          .toXmlEvents()
          .toXmlString()
          .join();
      expect(actual, string);
    });
    chunkedTest('events -> string -> events', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter)
          .toXmlString()
          .toXmlEvents()
          .normalizeEvents()
          .flatten()
          .toList();
      expect(actual, events);
    });
    chunkedTest('events -> nodes -> events', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter)
          .toXmlNodes()
          .toXmlEvents()
          .flatten()
          .toList();
      expect(actual, events);
    });
    chunkedTest('nodes -> events -> nodes', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(document.children, splitter)
          .toXmlEvents()
          .toXmlNodes()
          .flatten()
          .toList();
      expect(
          actual,
          pairwiseCompare<XmlNode, XmlNode>(document.children,
              (actual, expected) {
            compareNode(actual, expected);
            return true;
          }, 'not matching'));
    });
    chunkedTest('events -> subtree -> nodes', shiporderXsd,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter)
          .selectSubtreeEvents((event) => event.name == 'xsd:element')
          .toXmlNodes()
          .flatten()
          .toList();
      final expected = document
          .findAllElements('element', namespace: '*')
          .where((element) => !element.ancestors
              .whereType<XmlElement>()
              .any((parent) => parent.name.local == 'element'))
          .toList();
      expect(
          actual,
          pairwiseCompare<XmlNode, XmlNode>(expected, (actual, expected) {
            compareNode(actual, expected);
            return true;
          }, 'not matching'));
      actual
          .expand((node) => [node, ...node.descendants])
          .whereType<XmlHasName>()
          .forEach((node) => expect(node.name.namespaceUri, isNull));
    });
    chunkedTest('events -> parents -> subtree -> nodes', shiporderXsd,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter)
          .withParentEvents()
          .selectSubtreeEvents((event) => event.name == 'xsd:element')
          .toXmlNodes()
          .flatten()
          .toList();
      final expected = document
          .findAllElements('element', namespace: '*')
          .where((element) => !element.ancestors
              .whereType<XmlElement>()
              .any((parent) => parent.name.local == 'element'))
          .toList();
      expect(
          actual,
          pairwiseCompare<XmlNode, XmlNode>(expected, (actual, expected) {
            compareNode(actual, expected);
            return true;
          }, 'not matching'));
      actual
          .expand((node) => [node, ...node.descendants])
          .whereType<XmlHasName>()
          .where((node) => node.name.prefix == 'xsd')
          .forEach((node) => expect(
              node.name.namespaceUri, 'http://www.w3.org/2001/XMLSchema'));
    });
    chunkedTest('events -> handler', complicatedXml,
        (string, events, document, splitter) async {
      final cdata = <XmlCDATAEvent>[];
      final comment = <XmlCommentEvent>[];
      final declaration = <XmlDeclarationEvent>[];
      final doctype = <XmlDoctypeEvent>[];
      final endElement = <XmlEndElementEvent>[];
      final processing = <XmlProcessingEvent>[];
      final startElement = <XmlStartElementEvent>[];
      final text = <XmlTextEvent>[];
      await splitList(events, splitter).forEachEvent(
        onCDATA: cdata.add,
        onComment: comment.add,
        onDeclaration: declaration.add,
        onDoctype: doctype.add,
        onEndElement: endElement.add,
        onProcessing: processing.add,
        onStartElement: startElement.add,
        onText: text.add,
      );
      expect(cdata, events.whereType<XmlCDATAEvent>());
      expect(comment, events.whereType<XmlCommentEvent>());
      expect(declaration, events.whereType<XmlDeclarationEvent>());
      expect(doctype, events.whereType<XmlDoctypeEvent>());
      expect(endElement, events.whereType<XmlEndElementEvent>());
      expect(processing, events.whereType<XmlProcessingEvent>());
      expect(startElement, events.whereType<XmlStartElementEvent>());
      expect(text, events.whereType<XmlTextEvent>());
    });
    chunkedTest('events -> withParent -> map', complicatedXml,
        (string, events, document, splitter) async {
      final stacks = await splitList(events, splitter)
          .withParentEvents()
          .flatten()
          .map((event) {
        final stack = <XmlEvent>[];
        for (XmlEvent? current = event;
            current != null;
            current = current.parentEvent) {
          stack.insert(0, current);
        }
        return stack;
      }).toList();
      expect(stacks.map((events) => events.last), events);
    });
    chunkedTest('events -> withParent -> where', complicatedXml,
        (string, events, document, splitter) async {
      final actual = await splitList(events, splitter)
          .withParentEvents()
          .flatten()
          .where((event) =>
              event.parentEvent != null && event is! XmlEndElementEvent)
          .toList();
      final expected =
          const XmlNodeCodec().encode(document.rootElement.children);
      expect(actual, expected);
    });
  });
  group('normalizeEvents', () {
    test('empty', () async {
      final input = <XmlEvent>[XmlTextEvent('')];
      final output = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      const expected = <XmlEvent>[];
      expect(output, expected);
    });
    test('whitespace', () async {
      final input = <XmlEvent>[XmlTextEvent(' \n\t')];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[XmlTextEvent(' \n\t')];
      expect(actual, expected);
    });
    test('combine two', () async {
      final input = <XmlEvent>[XmlTextEvent('a'), XmlTextEvent('b')];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[XmlTextEvent('ab')];
      expect(actual, expected);
    });
    test('combine many', () async {
      final input = <XmlEvent>[
        XmlTextEvent('a'),
        XmlTextEvent('b'),
        XmlTextEvent('c'),
        XmlTextEvent('d'),
        XmlTextEvent('e'),
      ];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[XmlTextEvent('abcde')];
      expect(actual, expected);
    });
    test('chunked up', () async {
      final input = <XmlEvent>[
        XmlTextEvent('a'),
        XmlTextEvent('b'),
        XmlTextEvent('c'),
        XmlStartElementEvent('br', [], true),
        XmlTextEvent('d'),
        XmlTextEvent('e'),
      ];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[
        XmlTextEvent('abc'),
        XmlStartElementEvent('br', [], true),
        XmlTextEvent('de'),
      ];
      expect(actual, expected);
    });
  });
  group('withParentEvents', () {
    test('not parented', () async {
      final input = <XmlEvent>[
        XmlCDATAEvent('cdata'),
        XmlCommentEvent('comment'),
        XmlDeclarationEvent([]),
        XmlDoctypeEvent('doctype'),
        XmlProcessingEvent('target', 'text'),
        XmlStartElementEvent('element', [], true),
        XmlTextEvent('text'),
      ];
      final output = await Stream.fromIterable([input])
          .withParentEvents()
          .flatten()
          .toList();
      expect(output, input, reason: 'equality is unaffected');
      for (var i = 0; i < input.length; i++) {
        expect(input[i], same(output[i]), reason: 'root element is identical');
      }
    });
    test('basic parented', () async {
      final input = <XmlEvent>[
        XmlStartElementEvent('element', [], false),
        XmlCDATAEvent('cdata'),
        XmlCommentEvent('comment'),
        XmlDeclarationEvent([]),
        XmlDoctypeEvent('doctype'),
        XmlProcessingEvent('target', 'text'),
        XmlStartElementEvent('element', [], true),
        XmlTextEvent('text'),
        XmlEndElementEvent('element'),
      ];
      final output = await Stream.fromIterable([input])
          .withParentEvents()
          .flatten()
          .toList();
      expect(output, input, reason: 'equality is unaffected');
      for (var i = 1; i < input.length; i++) {
        expect(output[i].parentEvent, same(output[0]));
        expect(output[i].parentEvent, same(input[0]));
      }
    });
    test('deeply parented', () async {
      final input = <XmlEvent>[
        XmlStartElementEvent('first', [], false),
        XmlStartElementEvent('second', [], false),
        XmlStartElementEvent('third', [], false),
        XmlEndElementEvent('third'),
        XmlEndElementEvent('second'),
        XmlEndElementEvent('first'),
      ];
      final output = await Stream.fromIterable([input])
          .withParentEvents()
          .flatten()
          .toList();
      expect(output, input, reason: 'equality is unaffected');
      expect(output[0], same(input[0]), reason: 'root element is identical');
      expect(output[0].parentEvent, isNull);
      expect(output[1].parentEvent, same(output[0]));
      expect(output[2].parentEvent, same(output[1]));
      expect(output[3].parentEvent, same(output[2]));
      expect(output[4].parentEvent, same(output[1]));
      expect(output[5].parentEvent, same(output[0]));
    });
    test('closing tag mismatch', () {
      final input = <List<XmlEvent>>[
        [XmlStartElementEvent('open', [], false)],
        [XmlEndElementEvent('close')],
        [XmlTextEvent('after')],
      ];
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      expect(
          stream,
          emitsInOrder([
            input[0][0],
            emitsError(isXmlTagException.having(
              (error) => error.message,
              'message',
              'Expected closing tag </open>, but found </close>.',
            )),
          ]));
    });
    test('closing tag missing', () {
      final input = <List<XmlEvent>>[
        [XmlStartElementEvent('open', [], false)],
      ];
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      expect(
          stream,
          emitsInOrder([
            input[0][0],
            emitsError(isXmlTagException.having(
              (error) => error.message,
              'message',
              'Missing closing tag </open>.',
            )),
          ]));
    });
    test('closing tag unexpected', () {
      final input = <List<XmlEvent>>[
        [XmlEndElementEvent('close')],
        [XmlTextEvent('after')],
      ];
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      expect(
        stream,
        emitsError(isXmlTagException.having(
          (error) => error.message,
          'message',
          'Unexpected closing tag </close>.',
        )),
      );
    });
    test('after normalization', () {
      final input = [
        XmlStartElementEvent('outer', [], false),
        XmlTextEvent('first'),
        XmlTextEvent(' '),
        XmlTextEvent('second'),
        XmlEndElementEvent('outer'),
      ];
      final actual = const XmlWithParentEvents()
          .convert(const XmlNormalizeEvents().convert(input));
      expect(actual, hasLength(3));
      expect(actual[1].parentEvent, same(actual[0]));
      expect(actual[2].parentEvent, same(actual[0]));
    });
    test('before normalization', () {
      final input = [
        XmlStartElementEvent('outer', [], false),
        XmlTextEvent('first'),
        XmlTextEvent(' '),
        XmlTextEvent('second'),
        XmlEndElementEvent('outer'),
      ];
      final actual = const XmlNormalizeEvents()
          .convert(const XmlWithParentEvents().convert(input));
      expect(actual, hasLength(3));
      expect(actual[1].parentEvent, same(actual[0]));
      expect(actual[2].parentEvent, same(actual[0]));
    });
    test('default namespace', () async {
      const url = 'http://www.w3.org/1999/xhtml';
      const input = '<html xmlns="$url"><body lang="en"/></html>';
      final events = await Stream.fromIterable([input])
          .toXmlEvents()
          .withParentEvents()
          .flatten()
          .toList();
      for (final event in events) {
        if (event is XmlStartElementEvent) {
          expect(event.namespaceUri, url);
          event.attributes
              .where((attribute) => attribute.localName != 'xmlns')
              .forEach((attribute) => expect(attribute.namespaceUri, url));
        } else if (event is XmlEndElementEvent) {
          expect(event.namespaceUri, url);
        }
      }
    });
    test('prefix namespace', () async {
      const url = 'http://www.w3.org/1999/xhtml';
      const input = '<xhtml:html xmlns:xhtml="$url">'
          '<xhtml:body xhtml:lang="en"/>'
          '</xhtml:html>';
      final events = await Stream.fromIterable([input])
          .toXmlEvents()
          .withParentEvents()
          .flatten()
          .toList();
      for (final event in events) {
        if (event is XmlStartElementEvent) {
          expect(event.namespaceUri, url);
          event.attributes
              .where((attribute) => attribute.namespacePrefix != 'xmlns')
              .forEach((attribute) => expect(attribute.namespaceUri, url));
        } else if (event is XmlEndElementEvent) {
          expect(event.namespaceUri, url);
        }
      }
    });
    test('disallow re-parenting', () {
      const input = '<outer><inner/></outer>';
      final stream = Stream.fromIterable([input])
          .toXmlEvents()
          .withParentEvents()
          .withParentEvents();
      expect(stream, emitsError(isStateError));
    });
  });
  group('examples', () {
    test('extract non-empty text', () {
      final texts = parseEvents(bookstoreXml)
          .whereType<XmlTextEvent>()
          .map((event) => event.text.trim())
          .where((text) => text.isNotEmpty);
      expect(texts, ['Harry Potter', '29.99', 'Learning XML', '39.95']);
    });
    test('extract specific attribute', () {
      final maxExclusive = parseEvents(shiporderXsd)
          .whereType<XmlStartElementEvent>()
          .singleWhere((event) => event.name == 'xsd:maxExclusive')
          .attributes
          .singleWhere((attribute) => attribute.name == 'value')
          .value;
      expect(maxExclusive, '100');
    });
    test('extract all genres', () {
// Some libraries provide a sliding window iterator
// https://github.com/renggli/dart-more/blob/main/lib/src/iterable/window.dart
// which would make this code trivial to write and read:
      final genres = <String>{};
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
