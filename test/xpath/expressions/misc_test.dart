import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  group('more', () {
    test('//*/*', () {
      final xml = XmlDocument.parse('<a><b><c/></b><d><e/></d></a>');
      expectXPath(xml, '//*/*', ['<b><c/></b>', '<c/>', '<d><e/></d>', '<e/>']);
    });
    test('//@id', () {
      final xml = XmlDocument.parse(
        '<a id="a"><b id="b"><c id="c"/></b><d id="d"><e id="e"/></d></a>',
      );
      expectXPath(xml, '//@id', [
        'id="a"',
        'id="b"',
        'id="c"',
        'id="d"',
        'id="e"',
      ]);
    });
    test('//self::*', () {
      final xml = XmlDocument.parse('<a><b/></a>');
      expectXPath(xml, '//self::*', ['<a><b/></a>', '<b/>']);
    });
    test('//*[2]', () {
      final xml = XmlDocument.parse('<r><a/><b/></r>');
      expectXPath(xml, '//*[2]', ['<b/>']);
    });
  });
}
