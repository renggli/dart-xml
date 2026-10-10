import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:xml/xpath.dart';

import 'utils/assertions.dart';

void main() {
  const bookshelfXml = '''<?xml version="1.0"?>
    <bookshelf>
      <book>
        <title lang="en">Growing a Language</title>
        <price>29.99</price>
      </book>
      <book>
        <title lang="en">Learning XML</title>
        <price>39.95</price>
      </book>
      <price>132.00</price>
    </bookshelf>''';
  final document = XmlDocument.parse(bookshelfXml);
  group('reading and writing', () {
    test('parse document', () {
      assertDocumentInvariants(document);
    });
    test('printing document', () {
      check(document.toString()).equals(bookshelfXml);
      check(document.toXmlString(pretty: true, indent: '\t'))
          .startsWith('<?xml version="1.0"?>');
    });
  });
  group('traversing and querying', () {
    test('extract text', () {
      final textual = document.descendants
          .whereType<XmlText>()
          .map((text) => text.value.trim())
          .where((string) => string.isNotEmpty)
          .join('\n');
      check(textual).equals(
        'Growing a Language\n'
        '29.99\n'
        'Learning XML\n'
        '39.95\n'
        '132.00',
      );
      check(document.innerText).equals(
        '\n'
        '    \n'
        '      \n'
        '        Growing a Language\n'
        '        29.99\n'
        '      \n'
        '      \n'
        '        Learning XML\n'
        '        39.95\n'
        '      \n'
        '      132.00\n'
        '    ',
      );
    });
    test('find all elements', () {
      final titles = document
          .findAllElements('title')
          .map((element) => element.innerText);
      check(titles).deepEquals(['Growing a Language', 'Learning XML']);
    });
    test('nested find elements', () {
      final total = document
          .findAllElements('book')
          .map(
            (element) =>
                double.parse(element.findElements('price').single.innerText),
          )
          .reduce((a, b) => a + b);
      check(total).isCloseTo(69.94, 0.1);
    });
    test('find all the books in the bookshelf', () {
      check(document.xpath('/bookshelf/book')).length.equals(2);
    });
    test('find the second book in the bookshelf', () {
      check(document.xpath('/bookshelf/book[2]')).length.equals(1);
    });
    test('find all the english titles anywhere', () {
      check(document.xpath('//title[@lang="en"]')).length.equals(2);
    });
    test('find all the books with an english title', () {
      check(document.xpath('//book[title/@lang="en"]')).length.equals(2);
    });
    test('sum up the prices of all the books', () {
      final total = document
          .xpath('//book/price/text()')
          .map((node) => double.parse(node.value!))
          .reduce((a, b) => a + b);
      check(total).isCloseTo(69.94, 0.1);
    });
    test('evaluate xpath expression', () {
      final result = document.xpathEvaluate('sum(//book/price)').single;
      check(result.toValue() as num).isCloseTo(69.94, 0.01);
    });
    test('generate xpath expression', () {
      final title = document.findAllElements('title').first;
      check(title.xpathGenerate()).equals('/bookshelf/book[1]/title');
    });
  });
  group('building', () {
    test('a document', () {
      final builder = XmlBuilder();
      builder.processing('xml', 'version="1.0"');
      builder.element(
        'bookshelf',
        nest: () {
          builder.element(
            'book',
            nest: () {
              builder.element(
                'title',
                nest: () {
                  builder.attribute('lang', 'en');
                  builder.text('Growing a Language');
                },
              );
              builder.element('price', nest: 29.99);
            },
          );
          builder.element(
            'book',
            nest: () {
              builder.element(
                'title',
                nest: () {
                  builder.attribute('lang', 'en');
                  builder.text('Learning XML');
                },
              );
              builder.element('price', nest: 39.95);
            },
          );
          builder.element('price', nest: '132.00');
        },
      );
      final builtDocument = builder.buildDocument();
      check(document.toXmlString(pretty: true))
          .equals(builtDocument.toXmlString(pretty: true));
    });
    test('a fragment', () {
      void buildBook(
        XmlBuilder builder,
        String title,
        String language,
        num price,
      ) {
        builder.element(
          'book',
          nest: () {
            builder.element(
              'title',
              nest: () {
                builder.attribute('lang', language);
                builder.text(title);
              },
            );
            builder.element('price', nest: price);
          },
        );
      }

      final builder = XmlBuilder();
      buildBook(builder, 'The War of the Worlds', 'en', 12.50);
      buildBook(builder, 'Voyages extraordinaries', 'fr', 18.20);
      final builtDocument = document.copy();
      builtDocument.rootElement.children.add(builder.buildFragment());
      final titles = builtDocument
          .findAllElements('title')
          .map((node) => node.innerText);
      check(titles).deepEquals([
        'Growing a Language',
        'Learning XML',
        'The War of the Worlds',
        'Voyages extraordinaries',
      ]);
    });
  });
  group('event-driven', () {
    test('iterable', () {
      final result = parseEvents(bookshelfXml)
          .whereType<XmlTextEvent>()
          .map((event) => event.value.trim())
          .where((text) => text.isNotEmpty)
          .join('\n');
      check(result).equals(
        'Growing a Language\n'
        '29.99\n'
        'Learning XML\n'
        '39.95\n'
        '132.00',
      );
    });
    test('stream', () async {
      final stream = Stream.fromIterable([bookshelfXml]);
      final result = await stream
          .toXmlEvents()
          .normalizeEvents()
          .expand(
            (events) => events
                .whereType<XmlTextEvent>()
                .map((event) => event.value.trim())
                .where((text) => text.isNotEmpty),
          )
          .join('\n');
      check(result).equals(
        'Growing a Language\n'
        '29.99\n'
        'Learning XML\n'
        '39.95\n'
        '132.00',
      );
    });
    test('stream select subtree', () async {
      final stream = Stream.fromIterable([bookshelfXml]);
      final result = await stream
          .toXmlEvents()
          .normalizeEvents()
          .selectSubtreeEvents((event) => event.name == 'title')
          .toXmlNodes()
          .expand((nodes) => nodes)
          .map((node) => node.innerText)
          .join('\n');
      check(result).equals(
        'Growing a Language\n'
        'Learning XML',
      );
    });
    test('stream select subtree with parents and namespaces', () async {
      const shiporderXsd = '''<?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="shiporder">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="orderperson" type="xs:string"/>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:schema>''';

      final list = <String>[];
      await Stream.fromIterable([shiporderXsd])
          .toXmlEvents(withNamespace: true, withParent: true)
          .normalizeEvents()
          .selectSubtreeEvents(
            (event) =>
                event.localName == 'element' &&
                event.namespaceUri == 'http://www.w3.org/2001/XMLSchema',
          )
          .toXmlNodes()
          .expand((nodes) => nodes)
          .forEach((node) => list.add(node.toXmlString(pretty: true)));

      check(list).isNotEmpty();
      check(list.first).contains('orderperson');
    });
  });
}
