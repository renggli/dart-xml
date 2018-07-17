library xml.test.reader_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'examples.dart';

void main() {
  test('no handler', () {
    var reader = new XmlReader();
    reader.parse(complicatedXml);
  });
  test('event order', () {
    var events = <String>[];
    var reader = new XmlReader(
      onStartDocument: () => events.add('+'),
      onEndDocument: () => events.add('-'),
      onStartElement: (name, attributes) => events.add('<${name.qualified}>'),
      onEndElement: (name) => events.add('</${name.qualified}>'),
      onCharacterData: (text) => events.add(text),
      onProcessingInstruction: (target, text) =>
          events.add('<?$target $text?>'),
    );
    reader.parse(complicatedXml);
    expect(events, [
      '+',
      '<?xml foo?>',
      '\n',
      '\n',
      '<ns:foo>',
      '\n  ',
      '<element>',
      '</element>',
      '\n  ',
      '<ns:element>',
      '</ns:element>',
      '\n  ',
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
    var events = <String>[];
    var reader = new XmlReader(
      onStartDocument: () => events.add('+'),
      onEndDocument: () => events.add('-'),
      onStartElement: (name, attributes) => events.add('<${name.qualified}>'),
      onParseError: (pos) => events.add('!$pos'),
    );
    reader.parse('<<xml/>');
    expect(events, ['+', '!0', '<xml>', '-']);
  });
}
