import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

class TrimText extends XmlTransformer {
  @override
  XmlText visitText(XmlText node) => XmlText(node.text.trim());
}

void main() {
  test('https://github.com/renggli/dart-xml/issues/38', () {
    const input = '<?xml?><InstantaneousDemand><DeviceMacId>'
        '0xd8d5b9000000b3e8</DeviceMacId><MeterMacId>0x00135003007c27b4'
        '</MeterMacId><TimeStamp>0x2244aeb3</TimeStamp><Demand>0x0006c1'
        '</Demand><Multiplier>0x00000001</Multiplier><Divisor>0x000003e8'
        '</Divisor><DigitsRight>0x03</DigitsRight><DigitsLeft>0x0f'
        '</DigitsLeft><SuppressLeadingZero>Y</SuppressLeadingZero>'
        '</InstantaneousDemand>';
    assertDocumentParseInvariants(input);
  });
  test('https://github.com/renggli/dart-xml/issues/95', () {
    const input = '''
        <link type="text/html" title="View on Feedbooks" rel="alternate" href="https://www.feedbooks.com/book/2936"/>
        <link type="application/epub+zip" rel="http://opds-spec.org/acquisition" href="https://www.feedbooks.com/book/2936.epub"/>
        <link type="image/jpeg" rel="http://opds-spec.org/image" href="https://covers.feedbooks.net/book/2936.jpg?size=large&amp;t=1549045871"/>
        <link type="image/jpeg" rel="http://opds-spec.org/image/thumbnail" href="https://covers.feedbooks.net/book/2936.jpg?size=large&amp;t=1549045871"/>
    ''';
    assertFragmentParseInvariants(input);
    final fragment = XmlDocumentFragment.parse(input);
    final href = fragment
        .findElements('link')
        .where((element) =>
            element.getAttribute('rel') ==
            'http://opds-spec.org/image/thumbnail')
        .map((element) => element.getAttribute('href'))
        .single;
    expect(href,
        'https://covers.feedbooks.net/book/2936.jpg?size=large&t=1549045871');
  });
  group('https://github.com/renggli/dart-xml/issues/99', () {
    const input = '''
        <root>
          <left> left</left>
          <both> both </both>
          <right>right </right>
        </root>''';
    test('transformation class', () {
      final document = TrimText().visit<XmlDocument>(XmlDocument.parse(input));
      expect(document.rootElement.children[1].text, 'left');
      expect(document.rootElement.children[3].text, 'both');
      expect(document.rootElement.children[5].text, 'right');
    });
    test('transformation function', () {
      final document = XmlDocument.parse(input);
      for (final node in document.descendants.whereType<XmlText>()) {
        node.replace(XmlText(node.text.trim()));
      }
      expect(document.rootElement.children[1].text, 'left');
      expect(document.rootElement.children[3].text, 'both');
      expect(document.rootElement.children[5].text, 'right');
    });
  });
  test('https://github.com/renggli/dart-xml/issues/100', () {
    final document = XmlDocument.parse('''
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns="http://www.w3.org/2005/Atom">
          <os:totalResults>0</os:totalResults>
          <os:itemsPerPage>50</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
        </feed>''');
    expect(document.rootElement.getElement('os:totalResults')?.text, '0');
    expect(document.rootElement.getElement('os:itemsPerPage')?.text, '50');
    expect(document.rootElement.getElement('os:startIndex')?.text, '1');
  });
}
