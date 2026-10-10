import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../utils/checks.dart';
import '../utils/examples.dart';

void assertComplete(Iterator<XmlEvent> iterator) {
  for (var i = 0; i < 2; i++) {
    check(iterator.moveNext()).isFalse();
  }
}

void main() {
  group('events', () {
    test('empty', () {
      final iterator = parseEvents('').iterator;
      assertComplete(iterator);
    });
    test('cdata', () {
      final iterator = parseEvents('<![CDATA[<nasty>]]>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlCDATAEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.CDATA);
      check(event.value).equals('<nasty>');
      final other = XmlCDATAEvent(event.value);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('comment', () {
      final iterator = parseEvents('<!--for amusement only-->').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlCommentEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.COMMENT);
      check(event.value).equals('for amusement only');
      final other = XmlCommentEvent(event.value);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('declaration', () {
      final iterator = parseEvents('<?xml?>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlDeclarationEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.DECLARATION);
      check(event.attributes).isEmpty();
      final other = XmlDeclarationEvent(event.attributes);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('declaration (attributes)', () {
      final iterator = parseEvents('<?xml version="1.0" author=\'lfr\'?>')
          .iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlDeclarationEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.DECLARATION);
      check(event.attributes).length.equals(2);
      check(event.attributes[0].name).equals('version');
      check(event.attributes[0].value).equals('1.0');
      check(event.attributes[0].attributeType)
          .equals(XmlAttributeType.DOUBLE_QUOTE);
      check(event.attributes[1].name).equals('author');
      check(event.attributes[1].value).equals('lfr');
      check(event.attributes[1].attributeType)
          .equals(XmlAttributeType.SINGLE_QUOTE);
      final other = XmlDeclarationEvent(event.attributes);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('doctype', () {
      final iterator = parseEvents(
        '<!DOCTYPE note\n'
        'PUBLIC "public.dtd" "system.dtd"\n'
        '[<!ENTITY copy "(c)">]\n'
        '>',
      ).iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlDoctypeEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.DOCUMENT_TYPE);
      check(event.name).equals('note');
      check(event.externalId).isNotNull();
      check(event.externalId!.publicId).equals('public.dtd');
      check(event.externalId!.systemId).equals('system.dtd');
      check(event.internalSubset).equals('<!ENTITY copy "(c)">');
      final other = XmlDoctypeEvent(
        event.name,
        event.externalId,
        event.internalSubset,
      );
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('end element', () {
      final iterator = parseEvents('</bar>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlEndElementEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.ELEMENT);
      check(event.name).equals('bar');
      final other = XmlEndElementEvent(event.name);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('processing', () {
      final iterator = parseEvents('<?pi test?>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlProcessingEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.PROCESSING);
      check(event.target).equals('pi');
      check(event.value).equals('test');
      final other = XmlProcessingEvent(event.target, event.value);
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('start element', () {
      final iterator = parseEvents('<foo>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlStartElementEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.ELEMENT);
      check(event.name).equals('foo');
      check(event.attributes).isEmpty();
      check(event.isSelfClosing).isFalse();
      final other = XmlStartElementEvent(
        event.name,
        event.attributes,
        event.isSelfClosing,
      );
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('start element (attributes, self-closing)', () {
      final iterator = parseEvents('<foo a="1" b=\'2\'/>').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlStartElementEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.ELEMENT);
      check(event.name).equals('foo');
      check(event.attributes).length.equals(2);
      check(event.attributes[0].name).equals('a');
      check(event.attributes[0].value).equals('1');
      check(event.attributes[0].attributeType)
          .equals(XmlAttributeType.DOUBLE_QUOTE);
      check(event.attributes[1].name).equals('b');
      check(event.attributes[1].value).equals('2');
      check(event.attributes[1].attributeType)
          .equals(XmlAttributeType.SINGLE_QUOTE);
      check(event.isSelfClosing).isTrue();
      final other = XmlStartElementEvent(
        event.name,
        event.attributes
            .map(
              (attr) =>
                  XmlEventAttribute(attr.name, attr.value, attr.attributeType),
            )
            .toList(),
        event.isSelfClosing,
      );
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
    test('text', () {
      final iterator = parseEvents('Hello World!').iterator;
      check(iterator.moveNext()).isTrue();
      final event = iterator.current as XmlTextEvent;
      assertComplete(iterator);
      check(event.nodeType).equals(XmlNodeType.TEXT);
      // ignore: deprecated_member_use_from_same_package
      check(event.text).equals('Hello World!');
      final other = XmlTextEvent(event.value);
      // ignore: deprecated_member_use_from_same_package
      check(other.text).equals('Hello World!');
      check(event).equals(other);
      check(event.hashCode).equals(other.hashCode);
    });
  });
  group('errors', () {
    group('parser error', () {
      test('missing tag closing', () {
        final iterator = parseEvents('<hello').iterator;
        check(iterator.moveNext).throws<XmlParserException>().which(
          isXmlParserException(
            message: '">" expected',
            buffer: '<hello',
            position: 6,
          ),
        );
        check(iterator.moveNext()).isTrue();
        final event = iterator.current as XmlTextEvent;
        check(event.value).equals('hello');
        assertComplete(iterator);
      });
      test('missing attribute closing', () {
        final iterator = parseEvents('<foo bar="abc').iterator;
        check(iterator.moveNext).throws<XmlParserException>().which(
          isXmlParserException(
            message: '">" expected',
            buffer: '<foo bar="abc',
            position: 8,
          ),
        );
        check(iterator.moveNext()).isTrue();
        final event = iterator.current as XmlTextEvent;
        check(event.value).equals('foo bar="abc');
        assertComplete(iterator);
      });
      test('missing comment closing', () {
        final iterator = parseEvents('<!-- comment').iterator;
        check(iterator.moveNext).throws<XmlParserException>().which(
          isXmlParserException(
            message: '"-->" expected',
            buffer: '<!-- comment',
            position: 4,
          ),
        );
        check(iterator.moveNext()).isTrue();
        final event = iterator.current as XmlTextEvent;
        check(event.value).equals('!-- comment');
        assertComplete(iterator);
      });
    });
    group('not validated', () {
      test('unexpected end tag', () {
        final events = parseEvents('</foo>');
        check(events).deepEquals([XmlEndElementEvent('foo')]);
      });
      test('missing end tag', () {
        final events = parseEvents('<foo>');
        check(events).deepEquals([XmlStartElementEvent('foo', [], false)]);
      });
      test('not matching end tag', () {
        final events = parseEvents('<foo></bar></foo>');
        check(events).deepEquals([
          XmlStartElementEvent('foo', [], false),
          XmlEndElementEvent('bar'),
          XmlEndElementEvent('foo'),
        ]);
      });
    });
    group('validated', () {
      test('unexpected end tag', () {
        final iterator = parseEvents('</foo>', validateNesting: true).iterator;
        check(iterator.moveNext)
            .throws<XmlTagException>()
            .which(isXmlTagException(actualName: 'foo', position: 0));
        check(iterator.current).equals(XmlEndElementEvent('foo'));
        assertComplete(iterator);
      });
      test('missing end tag', () {
        final iterator = parseEvents('<foo>', validateNesting: true).iterator;
        check(iterator.moveNext()).isTrue();
        check(iterator.current).equals(XmlStartElementEvent('foo', [], false));
        check(iterator.moveNext)
            .throws<XmlTagException>()
            .which(isXmlTagException(expectedName: 'foo', position: 5));
        assertComplete(iterator);
      });
      test('not matching end tag', () {
        final iterator = parseEvents(
          '<foo></bar></foo>',
          validateNesting: true,
        ).iterator;
        check(iterator.moveNext()).isTrue();
        check(iterator.current).equals(XmlStartElementEvent('foo', [], false));
        check(iterator.moveNext).throws<XmlTagException>().which(
          isXmlTagException(
            expectedName: 'foo',
            actualName: 'bar',
            position: 5,
          ),
        );
        check(iterator.current).equals(XmlEndElementEvent('bar'));
        check(iterator.moveNext()).isTrue();
        check(iterator.current).equals(XmlEndElementEvent('foo'));
        assertComplete(iterator);
      });
    });
  });
  group('annotations', () {
    test('default', () {
      for (final event in parseEvents(shiporderXsd)) {
        check(event.buffer).isNull();
        check(event.start).isNull();
        check(event.stop).isNull();
        check(event.parent).isNull();
        // ignore: deprecated_member_use_from_same_package
        check(event.parentEvent).isNull();
      }
    });
    test('buffer', () {
      for (final event in parseEvents(shiporderXsd, withBuffer: true)) {
        check(event.buffer).equals(shiporderXsd);
      }
    });
    test('location', () {
      for (final event in parseEvents(shiporderXsd, withLocation: true)) {
        check(event.start).isNotNull();
        check(event.stop).isNotNull();
        check(event.start! <= event.stop!).isTrue();
        final outtake = shiporderXsd.substring(event.start!, event.stop);
        check(parseEvents(outtake)).deepEquals([event]);
      }
    });
    test('parent', () {
      final stack = <XmlStartElementEvent>[];
      for (final event in parseEvents(shiporderXsd, withParent: true)) {
        if (stack.isNotEmpty) {
          check(event.parent).equals(stack.last);
          // ignore: deprecated_member_use_from_same_package
          check(event.parentEvent).equals(stack.last);
        } else {
          check(event.parent).isNull();
          // ignore: deprecated_member_use_from_same_package
          check(event.parentEvent).isNull();
        }
        if (event is XmlStartElementEvent && !event.isSelfClosing) {
          stack.add(event);
        } else if (event is XmlEndElementEvent) {
          stack.removeLast();
        }
      }
      check(stack).isEmpty();
    });
  });
  group('examples', () {
    test('extract non-empty text', () {
      final texts = parseEvents(bookstoreXml)
          .whereType<XmlTextEvent>()
          .map((event) => event.value.trim())
          .where((text) => text.isNotEmpty);
      check(texts)
          .deepEquals(['Harry Potter', '29.99', 'Learning XML', '39.95']);
    });
    test('extract specific attribute', () {
      final maxExclusive = parseEvents(shiporderXsd)
          .whereType<XmlStartElementEvent>()
          .singleWhere((event) => event.name == 'xsd:maxExclusive')
          .attributes
          .singleWhere((attribute) => attribute.name == 'value')
          .value;
      check(maxExclusive).equals('100');
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
          genres.add(current.value);
        }
        return current;
      });
      for (final expected in [
        'Computer',
        'Fantasy',
        'Romance',
        'Horror',
        'Science Fiction',
      ]) {
        check(genres).contains(expected);
      }
    });
  });
}
