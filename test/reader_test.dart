library xml.test.reader_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'examples.dart';

void main() {
  test('no handlers', () {
    final reader = XmlReader();
    reader.parse(complicatedXml);
  });
  test('event order', () {
    final events = <String>[];
    final reader = XmlReader(
        onStartDocument: () => events.add('+'),
        onEndDocument: () => events.add('-'),
        onStartElement: (name, attributes) => events.add('<${name.qualified}>'),
        onEndElement: (name) => events.add('</${name.qualified}>'),
        onCharacterData: events.add,
        onProcessingInstruction: (target, text) =>
            events.add('<?$target $text?>'),
        onDoctype: (text) => events.add('<!DOCTYPE $text>'),
        onComment: (text) => events.add('<!--$text-->'));
    reader.parse(complicatedXml);
    expect(events, [
      '+',
      '<?xml foo?>',
      '\n',
      '<!DOCTYPE name [ something ]>',
      '\n',
      '<ns:foo>',
      '\n  ',
      '<element>',
      '</element>',
      '\n  ',
      '<ns:element>',
      '</ns:element>',
      '\n  ',
      '<!-- comment -->',
      '\n  ',
      'cdata',
      '\n  ',
      '<?processing instruction?>',
      '\n',
      '</ns:foo>',
      '-',
    ]);
  });
  test('parse error', () {
    final events = <String>[];
    final reader = XmlReader(
      onStartDocument: () => events.add('+'),
      onEndDocument: () => events.add('-'),
      onStartElement: (name, attributes) => events.add('<${name.qualified}>'),
      onParseError: (pos) => events.add('!$pos'),
    );
    reader.parse('<<xml/>');
    expect(events, ['+', '!0', '<xml>', '-']);
  });

  test('push reader test - ignore whitespace', () {
    final events = <String>[];
    final reader = XmlPushReader(complicatedXml);

    while (reader.read()) {
      switch (reader.nodeType) {
        case XmlPushReaderNodeType.ELEMENT:
          events.add('${reader.depth}: <${reader.name.qualified}>');
          if (reader.isEmptyElement) {
            events.add('${reader.depth}: </${reader.name.qualified}>');
          }
          break;
        case XmlPushReaderNodeType.END_ELEMENT:
          events.add('${reader.depth}: </${reader.name.qualified}>');
          break;
        case XmlPushReaderNodeType.CDATA:
        case XmlPushReaderNodeType.TEXT:
          events.add('${reader.depth}: ${reader.value}');
          break;
        case XmlPushReaderNodeType.PROCESSING:
          events.add('${reader.depth}: '
              '<?${reader.processingInstructionTarget} ${reader.value}?>');
          break;
        case XmlPushReaderNodeType.DOCUMENT_TYPE:
          events.add('${reader.depth}: <!DOCTYPE ${reader.value}>');
          break;
        case XmlPushReaderNodeType.COMMENT:
          events.add('${reader.depth}: <!--${reader.value}-->');
          break;
        default:
          throw StateError('unreachable');
      }
    }
    expect(reader.depth, 0);
    expect(reader.eof, isTrue);
    expect(events, [
      '0: <?xml foo?>',
      '0: <!DOCTYPE name [ something ]>',
      '1: <ns:foo>',
      '2: <element>',
      '2: </element>',
      '2: <ns:element>',
      '2: </ns:element>',
      '1: <!-- comment -->',
      '1: cdata',
      '1: <?processing instruction?>',
      '0: </ns:foo>',
    ]);
  });
}
