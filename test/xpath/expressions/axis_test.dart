import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  const input =
      '<?xml version="1.0"?>'
      '<r><a0/><a1><b1/></a1><a2 b1="1" b2="2"><c1/><c2>'
      '<d1></d1></c2></a2><a3><b2/></a3><a4/></r>';
  final document = XmlDocument.parse(input);
  final current = document.findAllElements('a2').single;
  test('..', () {
    expectXPath(current, '..', [document.rootElement]);
  });
  test('.', () {
    expectXPath(current, '.', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
    ]);
  });
  test('/', () {
    final document = XmlDocument.parse('<r/>');
    expectXPath(document, '/', [document]);
  });
  test('/*', () {
    expectXPath(current, '/*', [document.rootElement]);
  });
  test('//*', () {
    expectXPath(current, '//*', [
      document.rootElement,
      '<a0/>',
      '<a1><b1/></a1>',
      '<b1/>',
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
      '<a3><b2/></a3>',
      '<b2/>',
      '<a4/>',
    ]);
  });
  test('@*', () {
    expectXPath(current, '@*', ['b1="1"', 'b2="2"']);
  });
  test('ancestor::*', () {
    expectXPath(current, 'ancestor::*', [document.rootElement]);
    expectXPath(current.firstElementChild, 'ancestor::*', [
      document.rootElement,
      current,
    ], axisDirection: AxisDirection.reverse);
  });
  test('ancestor-or-self::*', () {
    expectXPath(current, 'ancestor-or-self::*', [
      document.rootElement,
      current,
    ], axisDirection: AxisDirection.reverse);
  });
  test('attribute::*', () {
    expectXPath(current, 'attribute::*', [
      'b1="1"',
      'b2="2"',
    ], axisDirection: AxisDirection.forward);
  });
  test('child::*', () {
    expectXPath(current, 'child::*', [
      '<c1/>',
      '<c2><d1></d1></c2>',
    ], axisDirection: AxisDirection.forward);
  });
  test('descendant::*', () {
    expectXPath(current, 'descendant::*', [
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
    ], axisDirection: AxisDirection.forward);
  });
  test('descendant-or-self::*', () {
    expectXPath(current, 'descendant-or-self::*', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
    ], axisDirection: AxisDirection.forward);
  });
  test('following::*', () {
    expectXPath(current, 'following::*', [
      '<a3><b2/></a3>',
      '<b2/>',
      '<a4/>',
    ], axisDirection: AxisDirection.forward);
  });
  test('following-sibling::*', () {
    expectXPath(current, 'following-sibling::*', [
      '<a3><b2/></a3>',
      '<a4/>',
    ], axisDirection: AxisDirection.forward);
  });
  test('parent::*', () {
    expectXPath(current, 'parent::*', [
      document.rootElement,
    ], axisDirection: AxisDirection.forward);
  });
  test('namespace::*', () {
    expectXPath(current, 'namespace::*', [
      'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
    ], axisDirection: AxisDirection.forward);
  });
  test('preceding::*', () {
    expectXPath(current, 'preceding::*', [
      '<a0/>',
      '<a1><b1/></a1>',
      '<b1/>',
    ], axisDirection: AxisDirection.reverse);
  });
  test('preceding-sibling::*', () {
    expectXPath(current, 'preceding-sibling::*', [
      '<a0/>',
      '<a1><b1/></a1>',
    ], axisDirection: AxisDirection.reverse);
  });
  test('self::*', () {
    expectXPath(current, 'self::*', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
    ], axisDirection: AxisDirection.forward);
  });

  group('document-level filtering', () {
    const inputWithProlog = '''<?xml version="1.0"?>
<!DOCTYPE root>
<root>
  <child/>
</root>''';
    final doc = XmlDocument.parse(inputWithProlog);

    test('child axis on document excludes declaration and doctype', () {
      expectXPath(doc, 'child::node()', ['<root>\n  <child/>\n</root>']);
      expectXPath(doc, '/child::*', ['<root>\n  <child/>\n</root>']);
    });

    test('descendant axis from document excludes declaration and doctype', () {
      final nodes = doc.xpath('//node()');
      expect(nodes.any((n) => n is XmlDeclaration || n is XmlDoctype), isFalse);
    });

    test('preceding-sibling and following-sibling on root element ignore non-xpath nodes', () {
      final root = doc.rootElement;
      expectXPath(root, 'preceding-sibling::node()', const []);
      expectXPath(root, 'following-sibling::node()', const []);
    });
  });

  group('namespace axis edge cases', () {
    const nsXml = '''<root xmlns="http://default.com" xmlns:ns="http://ns.com">
  <child xmlns:c="http://child.com"/>
</root>''';
    final doc = XmlDocument.parse(nsXml);
    final root = doc.rootElement;
    final child = root.findAllElements('child').single;

    test('parent of namespace node is the element itself', () {
      final parentOfNs = root.xpath('namespace::*[local-name()="ns"]/..');
      expect(parentOfNs.single, root);
    });

    test('parent of inherited namespace node is the inheriting element', () {
      final parentOfInheritedNs = child.xpath(
        'namespace::*[local-name()="ns"]/..',
      );
      expect(parentOfInheritedNs.single, child);
    });

    test('node comparison "is" on namespace nodes', () {
      expect(
        doc.xpathEvaluate('/*[1]/namespace::ns is /*[1]/namespace::ns'),
        isXPathSequence([true]),
      );
      expect(
        doc.xpathEvaluate(
          '/*[1]/namespace::ns is /*[1]/child[1]/namespace::ns',
        ),
        isXPathSequence([false]),
      );
    });
  });
}
