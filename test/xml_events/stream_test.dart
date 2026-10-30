import 'dart:async';
import 'dart:math' show Random, min;

import 'package:checks/checks.dart';
import 'package:meta/meta.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../utils/assertions.dart';
import '../utils/checks.dart';
import '../utils/examples.dart';

@isTestGroup
void chunkedTests<T>(
  String title,
  T Function() factory,
  Stream<T> Function(T input, int Function() splitter) chunker,
  FutureOr<void> Function(Stream<T> stream) callback,
) => group(title, () {
  for (var i = 1; i <= 512; i *= 2) {
    test(
      'chunks equally sized $i',
      () => callback(chunker(factory(), () => i)),
    );
  }
  final random = Random(title.hashCode);
  for (var i = 1; i <= 512; i *= 2) {
    test(
      'chunks randomly sized $i',
      () => callback(chunker(factory(), () => random.nextInt(1 + i))),
    );
  }
});

Stream<String> stringChunker(String input, int Function() splitter) async* {
  while (input.isNotEmpty) {
    final size = min(splitter(), input.length);
    yield input.substring(0, size);
    input = input.substring(size);
  }
}

Stream<List<T>> listChunker<T>(List<T> input, int Function() splitter) async* {
  while (input.isNotEmpty) {
    final size = min(splitter(), input.length);
    yield input.sublist(0, size);
    input = input.sublist(size);
  }
}

void main() {
  group('events', () {
    for (final entry in allXml.entries) {
      group(entry.key, () {
        late XmlDocument document;
        late String source;
        late List<XmlEvent> events;
        setUp(() {
          document = XmlDocument.parse(entry.value);
          source = document.toXmlString();
          events = parseEvents(
            source,
            withNamespace: true,
          ).toList(growable: false);
        });
        chunkedTests<String>('string -> events', () => source, stringChunker, (
          stream,
        ) async {
          final actual = await stream
              .toXmlEvents(withNamespace: true)
              .normalizeEvents()
              .flatten()
              .toList();
          check(actual).deepEquals(events);
        });
        chunkedTests<List<XmlEvent>>(
          'events -> nodes',
          () => events,
          listChunker,
          (stream) async {
            final actual = await stream.toXmlNodes().flatten().toList();
            check(actual).length.equals(document.children.length);
            for (var i = 0; i < actual.length; i++) {
              compareNode(actual[i], document.children[i]);
            }
          },
        );
        chunkedTests<List<XmlNode>>(
          'nodes -> events',
          () => document.children,
          listChunker,
          (stream) async {
            final actual = await stream.toXmlEvents().flatten().toList();
            check(actual).deepEquals(events);
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> string',
          () => events,
          listChunker,
          (stream) async {
            final actual = await stream.toXmlString().join();
            check(actual).equals(source);
          },
        );
        chunkedTests<String>(
          'string -> events -> string',
          () => source,
          stringChunker,
          (stream) async {
            final actual = await stream
                .toXmlEvents(withNamespace: true)
                .normalizeEvents()
                .toXmlString()
                .join();
            check(actual).equals(source);
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> string -> events',
          () => events,
          listChunker,
          (stream) async {
            final actual = await stream
                .toXmlString()
                .toXmlEvents(withNamespace: true)
                .normalizeEvents()
                .flatten()
                .toList();
            check(actual).deepEquals(events);
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> nodes -> events',
          () => events,
          listChunker,
          (stream) async {
            final actual = await stream
                .toXmlNodes()
                .toXmlEvents()
                .flatten()
                .toList();
            check(actual).deepEquals(events);
          },
        );
        chunkedTests<List<XmlNode>>(
          'nodes -> events -> nodes',
          () => document.children,
          listChunker,
          (stream) async {
            final actual = await stream
                .toXmlEvents()
                .toXmlNodes()
                .flatten()
                .toList();
            check(actual).length.equals(document.children.length);
            for (var i = 0; i < actual.length; i++) {
              compareNode(actual[i], document.children[i]);
            }
          },
        );
        if (entry.value == shiporderXsd) {
          chunkedTests<List<XmlEvent>>(
            'events -> subtree -> nodes',
            () => events,
            listChunker,
            (stream) async {
              final actual = await stream
                  .selectSubtreeEvents((event) => event.name == 'xsd:element')
                  .toXmlNodes()
                  .flatten()
                  .toList();
              final expected = document
                  .findAllElements('element', namespaceUri: '*')
                  .where(
                    (element) => !element.ancestors.whereType<XmlElement>().any(
                      (parent) => parent.qualifiedName == 'xsd:element',
                    ),
                  )
                  .toList();
              check(actual).length.equals(expected.length);
              for (var i = 0; i < actual.length; i++) {
                compareNode(actual[i], expected[i]);
              }
            },
          );
          chunkedTests<List<XmlEvent>>(
            'events -> parents -> subtree -> nodes',
            () => events,
            listChunker,
            (stream) async {
              final actual = await stream
                  // ignore: deprecated_member_use_from_same_package
                  .withParentEvents()
                  .selectSubtreeEvents((event) => event.name == 'xsd:element')
                  .toXmlNodes()
                  .flatten()
                  .toList();
              final expected = document
                  .findAllElements('element', namespaceUri: '*')
                  .where(
                    (element) => !element.ancestors.whereType<XmlElement>().any(
                      (parent) => parent.name.local == 'element',
                    ),
                  )
                  .toList();
              check(actual).length.equals(expected.length);
              for (var i = 0; i < actual.length; i++) {
                compareNode(actual[i], expected[i]);
              }
              actual
                  .expand((node) => [node, ...node.descendants])
                  .whereType<XmlHasName>()
                  .where((node) => node.name.prefix == 'xsd')
                  .forEach(
                    (node) =>
                        check(node.name.namespaceUri)
                            .equals('http://www.w3.org/2001/XMLSchema'),
                  );
            },
          );
        }
        chunkedTests<List<XmlEvent>>(
          'event -> forEachEvent',
          () => events,
          listChunker,
          (stream) async {
            final cdata = <XmlCDATAEvent>[];
            final comment = <XmlCommentEvent>[];
            final declaration = <XmlDeclarationEvent>[];
            final doctype = <XmlDoctypeEvent>[];
            final endElement = <XmlEndElementEvent>[];
            final processing = <XmlProcessingEvent>[];
            final startElement = <XmlStartElementEvent>[];
            final text = <XmlTextEvent>[];
            await stream.flatten().forEachEvent(
              onCDATA: cdata.add,
              onComment: comment.add,
              onDeclaration: declaration.add,
              onDoctype: doctype.add,
              onEndElement: endElement.add,
              onProcessing: processing.add,
              onStartElement: startElement.add,
              onText: text.add,
            );
            check(cdata).deepEquals(events.whereType<XmlCDATAEvent>());
            check(comment).deepEquals(events.whereType<XmlCommentEvent>());
            check(declaration)
                .deepEquals(events.whereType<XmlDeclarationEvent>());
            check(doctype).deepEquals(events.whereType<XmlDoctypeEvent>());
            check(endElement)
                .deepEquals(events.whereType<XmlEndElementEvent>());
            check(processing)
                .deepEquals(events.whereType<XmlProcessingEvent>());
            check(startElement)
                .deepEquals(events.whereType<XmlStartElementEvent>());
            check(text).deepEquals(events.whereType<XmlTextEvent>());
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> tapEachEvent',
          () => events,
          listChunker,
          (stream) async {
            final cdata = <XmlCDATAEvent>[];
            final comment = <XmlCommentEvent>[];
            final declaration = <XmlDeclarationEvent>[];
            final doctype = <XmlDoctypeEvent>[];
            final endElement = <XmlEndElementEvent>[];
            final processing = <XmlProcessingEvent>[];
            final startElement = <XmlStartElementEvent>[];
            final text = <XmlTextEvent>[];
            await stream
                .flatten()
                .tapEachEvent(
                  onCDATA: cdata.add,
                  onComment: comment.add,
                  onDeclaration: declaration.add,
                  onDoctype: doctype.add,
                  onEndElement: endElement.add,
                  onProcessing: processing.add,
                  onStartElement: startElement.add,
                  onText: text.add,
                )
                .drain<void>();
            check(cdata).deepEquals(events.whereType<XmlCDATAEvent>());
            check(comment).deepEquals(events.whereType<XmlCommentEvent>());
            check(declaration)
                .deepEquals(events.whereType<XmlDeclarationEvent>());
            check(doctype).deepEquals(events.whereType<XmlDoctypeEvent>());
            check(endElement)
                .deepEquals(events.whereType<XmlEndElementEvent>());
            check(processing)
                .deepEquals(events.whereType<XmlProcessingEvent>());
            check(startElement)
                .deepEquals(events.whereType<XmlStartElementEvent>());
            check(text).deepEquals(events.whereType<XmlTextEvent>());
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> forEachEvent',
          () => events,
          listChunker,
          (stream) async {
            final cdata = <XmlCDATAEvent>[];
            final comment = <XmlCommentEvent>[];
            final declaration = <XmlDeclarationEvent>[];
            final doctype = <XmlDoctypeEvent>[];
            final endElement = <XmlEndElementEvent>[];
            final processing = <XmlProcessingEvent>[];
            final startElement = <XmlStartElementEvent>[];
            final text = <XmlTextEvent>[];
            await stream.forEachEvent(
              onCDATA: cdata.add,
              onComment: comment.add,
              onDeclaration: declaration.add,
              onDoctype: doctype.add,
              onEndElement: endElement.add,
              onProcessing: processing.add,
              onStartElement: startElement.add,
              onText: text.add,
            );
            check(cdata).deepEquals(events.whereType<XmlCDATAEvent>());
            check(comment).deepEquals(events.whereType<XmlCommentEvent>());
            check(declaration)
                .deepEquals(events.whereType<XmlDeclarationEvent>());
            check(doctype).deepEquals(events.whereType<XmlDoctypeEvent>());
            check(endElement)
                .deepEquals(events.whereType<XmlEndElementEvent>());
            check(processing)
                .deepEquals(events.whereType<XmlProcessingEvent>());
            check(startElement)
                .deepEquals(events.whereType<XmlStartElementEvent>());
            check(text).deepEquals(events.whereType<XmlTextEvent>());
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> tapEachEvent',
          () => events,
          listChunker,
          (stream) async {
            final cdata = <XmlCDATAEvent>[];
            final comment = <XmlCommentEvent>[];
            final declaration = <XmlDeclarationEvent>[];
            final doctype = <XmlDoctypeEvent>[];
            final endElement = <XmlEndElementEvent>[];
            final processing = <XmlProcessingEvent>[];
            final startElement = <XmlStartElementEvent>[];
            final text = <XmlTextEvent>[];
            await stream
                .tapEachEvent(
                  onCDATA: cdata.add,
                  onComment: comment.add,
                  onDeclaration: declaration.add,
                  onDoctype: doctype.add,
                  onEndElement: endElement.add,
                  onProcessing: processing.add,
                  onStartElement: startElement.add,
                  onText: text.add,
                )
                .drain<void>();
            check(cdata).deepEquals(events.whereType<XmlCDATAEvent>());
            check(comment).deepEquals(events.whereType<XmlCommentEvent>());
            check(declaration)
                .deepEquals(events.whereType<XmlDeclarationEvent>());
            check(doctype).deepEquals(events.whereType<XmlDoctypeEvent>());
            check(endElement)
                .deepEquals(events.whereType<XmlEndElementEvent>());
            check(processing)
                .deepEquals(events.whereType<XmlProcessingEvent>());
            check(startElement)
                .deepEquals(events.whereType<XmlStartElementEvent>());
            check(text).deepEquals(events.whereType<XmlTextEvent>());
          },
        );
        chunkedTests<List<XmlEvent>>(
          'events -> withParent -> map',
          () => events,
          listChunker,
          (stream) async {
            final stacks = await stream
                // ignore: deprecated_member_use_from_same_package
                .withParentEvents()
                .normalizeEvents()
                .flatten()
                .map((event) {
                  final stack = <XmlEvent>[];
                  for (
                    XmlEvent? current = event;
                    current != null;
                    current = current.parent
                  ) {
                    stack.insert(0, current);
                  }
                  return stack;
                })
                .toList();
            check(stacks.map((events) => events.last)).deepEquals(events);
          },
        );
      });
    }
  });
  group('errors', () {
    chunkedTests<String>('missing tag closing', () => '<hello', stringChunker, (
      stream,
    ) async {
      await check(stream.toXmlEvents(withLocation: true).drain<void>())
          .throws<XmlParserException>(
            (it) => it.which(
              isXmlParserException(message: '">" expected', position: 6),
            ),
          );
    });
    chunkedTests<String>(
      'missing attribute closing',
      () => '<foo bar="abc',
      stringChunker,
      (stream) async {
        await check(stream.toXmlEvents(withLocation: true).drain<void>())
            .throws<XmlParserException>(
              (it) => it.which(
                isXmlParserException(message: '">" expected', position: 8),
              ),
            );
      },
    );
    chunkedTests<String>(
      'missing comment closing',
      () => '<!-- comment',
      stringChunker,
      (stream) async {
        await check(stream.toXmlEvents(withLocation: true).drain<void>())
            .throws<XmlParserException>(
              (it) => it.which(
                isXmlParserException(message: '"-->" expected', position: 4),
              ),
            );
      },
    );
    group('tags not validated', () {
      chunkedTests<String>(
        'unexpected end tag',
        () => '</foo>',
        stringChunker,
        (stream) async {
          final actual = await stream
              .toXmlEvents(withLocation: true)
              .flatten()
              .toList();
          check(actual).deepEquals([XmlEndElementEvent('foo')]);
        },
      );
      chunkedTests<String>('missing end tag', () => '<foo>', stringChunker, (
        stream,
      ) async {
        final actual = await stream
            .toXmlEvents(withLocation: true)
            .flatten()
            .toList();
        check(actual).deepEquals([XmlStartElementEvent('foo', [], false)]);
      });
      chunkedTests<String>(
        'not matching end tag',
        () => '<foo></bar></foo>',
        stringChunker,
        (stream) async {
          final actual = await stream
              .toXmlEvents(withLocation: true)
              .flatten()
              .toList();
          check(actual).deepEquals([
            XmlStartElementEvent('foo', [], false),
            XmlEndElementEvent('bar'),
            XmlEndElementEvent('foo'),
          ]);
        },
      );
    });
    group('tags validated', () {
      chunkedTests<String>(
        'unexpected end tag',
        () => '</foo>',
        stringChunker,
        (stream) async {
          await check(
            stream
                .toXmlEvents(validateNesting: true, withLocation: true)
                .flatten()
                .drain<void>(),
          ).throws<XmlTagException>(
            (it) => it.which(isXmlTagException(actualName: 'foo', position: 0)),
          );
        },
      );
      chunkedTests<String>('missing end tag', () => '<foo>', stringChunker, (
        stream,
      ) async {
        await check(
          stream
              .toXmlEvents(validateNesting: true, withLocation: true)
              .flatten()
              .drain<void>(),
        ).throws<XmlTagException>(
          (it) => it.which(isXmlTagException(expectedName: 'foo', position: 5)),
        );
      });
      chunkedTests<String>(
        'not matching end tag',
        () => '<foo></bar></foo>',
        stringChunker,
        (stream) async {
          await check(
            stream
                .toXmlEvents(validateNesting: true, withLocation: true)
                .flatten()
                .drain<void>(),
          ).throws<XmlTagException>(
            (it) => it.which(
              isXmlTagException(
                expectedName: 'foo',
                actualName: 'bar',
                position: 5,
              ),
            ),
          );
        },
      );
    });
    group('node decoder', () {
      const decoder = XmlNodeDecoder();
      test('mismatch closing tag', () {
        check(
          () => decoder.convert([
            XmlStartElementEvent('foo', [], false),
            XmlEndElementEvent('bar'),
          ]),
        ).throws<XmlTagException>().which(
          isXmlTagException(
            message: 'Expected </foo>, but found </bar>',
            expectedName: 'foo',
            actualName: 'bar',
          ),
        );
      });
      test('unexpected closing tag', () {
        check(() => decoder.convert([XmlEndElementEvent('foo')]))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Unexpected closing tag </foo>',
                expectedNameCondition: (n) => n.isNull(),
                actualName: 'foo',
              ),
            );
      });
      test('missing closing tag', () {
        check(() => decoder.convert([XmlStartElementEvent('foo', [], false)]))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Missing closing tag </foo>',
                expectedName: 'foo',
                actualNameCondition: (n) => n.isNull(),
              ),
            );
      });
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
      check(output).deepEquals(expected);
    });
    test('whitespace', () async {
      final input = <XmlEvent>[XmlTextEvent(' \n\t')];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[XmlTextEvent(' \n\t')];
      check(actual).deepEquals(expected);
    });
    test('combine two', () async {
      final input = <XmlEvent>[XmlTextEvent('a'), XmlTextEvent('b')];
      final actual = await Stream.fromIterable([input])
          .normalizeEvents()
          .flatten()
          .toList();
      final expected = <XmlEvent>[XmlTextEvent('ab')];
      check(actual).deepEquals(expected);
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
      check(actual).deepEquals(expected);
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
      check(actual).deepEquals(expected);
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
      final output = await Stream.fromIterable([
        input,
        // ignore: deprecated_member_use_from_same_package
      ]).withParentEvents().flatten().toList();
      check(because: 'equality is unaffected', output).deepEquals(input);
      for (var i = 0; i < input.length; i++) {
        check(
          because: 'root element is identical',
          input[i],
        ).identicalTo(output[i]);
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
      final output = await Stream.fromIterable([
        input,
        // ignore: deprecated_member_use_from_same_package
      ]).withParentEvents().flatten().toList();
      check(because: 'equality is unaffected', output).deepEquals(input);
      for (var i = 1; i < input.length; i++) {
        check(output[i].parent).identicalTo(output[0] as XmlStartElementEvent);
        check(output[i].parent).identicalTo(input[0] as XmlStartElementEvent);
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
      final output = await Stream.fromIterable([
        input,
        // ignore: deprecated_member_use_from_same_package
      ]).withParentEvents().flatten().toList();
      check(because: 'equality is unaffected', output).deepEquals(input);
      check(
        because: 'root element is identical',
        output[0],
      ).identicalTo(input[0]);
      check(output[0].parent).isNull();
      check(output[1].parent).identicalTo(output[0] as XmlStartElementEvent);
      check(output[2].parent).identicalTo(output[1] as XmlStartElementEvent);
      check(output[3].parent).identicalTo(output[2] as XmlStartElementEvent);
      check(output[4].parent).identicalTo(output[1] as XmlStartElementEvent);
      check(output[5].parent).identicalTo(output[0] as XmlStartElementEvent);
    });
    test('closing tag mismatch', () async {
      final input = <List<XmlEvent>>[
        [XmlStartElementEvent('open', [], false)],
        [XmlEndElementEvent('close')],
        [XmlTextEvent('after')],
      ];
      // ignore: deprecated_member_use_from_same_package
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      await check(stream.drain<void>()).throws<XmlTagException>(
        (it) => it.which(
          isXmlTagException(message: 'Expected </open>, but found </close>'),
        ),
      );
    });
    test('closing tag missing', () async {
      final input = <List<XmlEvent>>[
        [XmlStartElementEvent('open', [], false)],
      ];
      // ignore: deprecated_member_use_from_same_package
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      await check(stream.drain<void>()).throws<XmlTagException>(
        (it) =>
            it.which(isXmlTagException(message: 'Missing closing tag </open>')),
      );
    });
    test('closing tag unexpected', () async {
      final input = <List<XmlEvent>>[
        [XmlEndElementEvent('close')],
        [XmlTextEvent('after')],
      ];
      // ignore: deprecated_member_use_from_same_package
      final stream = Stream.fromIterable(input).withParentEvents().flatten();
      await check(stream.drain<void>()).throws<XmlTagException>(
        (it) => it.which(
          isXmlTagException(message: 'Unexpected closing tag </close>'),
        ),
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
      final actual = const XmlWithParentEvents().convert(
        const XmlNormalizeEvents().convert(input),
      );
      check(actual).length.equals(3);
      check(actual[1].parent).identicalTo(actual[0] as XmlStartElementEvent);
      check(actual[2].parent).identicalTo(actual[0] as XmlStartElementEvent);
    });
    test('before normalization', () {
      final input = [
        XmlStartElementEvent('outer', [], false),
        XmlTextEvent('first'),
        XmlTextEvent(' '),
        XmlTextEvent('second'),
        XmlEndElementEvent('outer'),
      ];
      final actual = const XmlNormalizeEvents().convert(
        const XmlWithParentEvents().convert(input),
      );
      check(actual).length.equals(3);
      check(actual[1].parent).identicalTo(actual[0] as XmlStartElementEvent);
      check(actual[2].parent).identicalTo(actual[0] as XmlStartElementEvent);
    });
    test('default namespace', () async {
      const url = 'http://www.w3.org/1999/xhtml';
      const input = '<html xmlns="$url"><body lang="en"/></html>';
      final events = await Stream.fromIterable([
        input,
        // ignore: deprecated_member_use_from_same_package
      ]).toXmlEvents(withNamespace: true).withParentEvents().flatten().toList();
      for (final event in events) {
        if (event is XmlStartElementEvent) {
          check(event.namespaceUri).equals(url);
          event.attributes
              .where((attribute) => attribute.localName != 'xmlns')
              .forEach(
                (attribute) => check(attribute.namespaceUri).equals(url),
              );
        } else if (event is XmlEndElementEvent) {
          check(event.namespaceUri).equals(url);
        }
      }
    });
    test('prefix namespace', () async {
      const url = 'http://www.w3.org/1999/xhtml';
      const input =
          '<xhtml:html xmlns:xhtml="$url">'
          '<xhtml:body xhtml:lang="en"/>'
          '</xhtml:html>';
      final events = await Stream.fromIterable([
        input,
        // ignore: deprecated_member_use_from_same_package
      ]).toXmlEvents(withNamespace: true).withParentEvents().flatten().toList();
      for (final event in events) {
        if (event is XmlStartElementEvent) {
          check(event.namespaceUri).equals(url);
          event.attributes
              .where((attribute) => attribute.namespacePrefix != 'xmlns')
              .forEach(
                (attribute) => check(attribute.namespaceUri).equals(url),
              );
        } else if (event is XmlEndElementEvent) {
          check(event.namespaceUri).equals(url);
        }
      }
    });
  });
  group('selectSubtreeEvents', () {
    test('missing closing tag throws XmlTagException', () async {
      final input = <List<XmlEvent>>[
        [XmlStartElementEvent('item', [], false)],
      ];
      final stream = Stream.fromIterable(input)
          .selectSubtreeEvents((event) => event.name == 'item')
          .flatten();
      await check(stream.drain<void>()).throws<XmlTagException>(
        (it) =>
            it.which(isXmlTagException(message: 'Missing closing tag </item>')),
      );
    });
  });
}
