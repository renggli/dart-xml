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
}
