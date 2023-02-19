import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import 'utils/examples.dart';
import 'utils/matchers.dart';

void expectXPath(XmlNode? node, String expression,
        [Iterable<Object?>? expected]) =>
    expect(
        node!.xpath(expression),
        expected == null
            ? isEmpty
            : orderedEquals(expected.map((each) => each is String
                ? isA<XmlNode>()
                    .having((node) => node.outerXml, 'outerXml', each)
                : each)));

void main() {
  group('axis', () {
    const input = '<?xml version="1.0"?>'
        '<r><a1><b1/></a1><a2 b1="1" b2="2"><c1/><c2>'
        '<d1></d1></c2></a2><a3><b2/></a3></r>';
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
    test('/*', () {
      expectXPath(current, '/*', [document.rootElement]);
    });
    test('//*', () {
      expectXPath(current, '//*', [
        document.rootElement,
        '<a1><b1/></a1>',
        '<b1/>',
        '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
        '<c1/>',
        '<c2><d1></d1></c2>',
        '<d1></d1>',
        '<a3><b2/></a3>',
        '<b2/>',
      ]);
    });
    test('@*', () {
      expectXPath(current, '@*', ['b1="1"', 'b2="2"']);
    });
    test('ancestor::*', () {
      expectXPath(current, 'ancestor::*', [document.rootElement]);
    });
    test('ancestor-or-self::*', () {
      expectXPath(current, 'ancestor-or-self::*', [
        document.rootElement,
        current,
      ]);
    });
    test('attribute::*', () {
      expectXPath(current, 'attribute::*', ['b1="1"', 'b2="2"']);
    });
    test('child::*', () {
      expectXPath(current, 'child::*', ['<c1/>', '<c2><d1></d1></c2>']);
    });
    test('descendant::*', () {
      expectXPath(current, 'descendant::*', [
        '<c1/>',
        '<c2><d1></d1></c2>',
        '<d1></d1>',
      ]);
    });
    test('descendant-or-self::*', () {
      expectXPath(current, 'descendant-or-self::*', [
        '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
        '<c1/>',
        '<c2><d1></d1></c2>',
        '<d1></d1>',
      ]);
    });
    test('following::*', () {
      expectXPath(current, 'following::*', ['<a3><b2/></a3>', '<b2/>']);
    });
    test('following-sibling::*', () {
      expectXPath(current, 'following-sibling::*', ['<a3><b2/></a3>']);
    });
    test('parent::*', () {
      expectXPath(current, 'parent::*', [document.rootElement]);
    });
    test('preceding::*', () {
      expectXPath(current, 'preceding::*', ['<a1><b1/></a1>', '<b1/>']);
    });
    test('preceding-sibling::*', () {
      expectXPath(current, 'preceding-sibling::*', ['<a1><b1/></a1>']);
    });
    test('self::*', () {
      expectXPath(current, 'self::*', [
        '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
      ]);
    });
  });
  group('node test', () {
    const input = '<?xml version="1.0"?>'
        '<r><!--comment--><e1/><e2/><?p1?><?p2?>text<![CDATA[data]]></r>';
    final document = XmlDocument.parse(input);
    final current = document.rootElement;
    test('*', () {
      expectXPath(current, '*', ['<e1/>', '<e2/>']);
    });
    test('e1', () {
      expectXPath(current, 'e1', ['<e1/>']);
      expectXPath(current, 'e2', ['<e2/>']);
    });
    test('comment()', () {
      expectXPath(current, 'comment()', ['<!--comment-->']);
    });
    test('node()', () {
      expectXPath(current, 'node()', current.children);
    });
    test('processing-instruction()', () {
      expectXPath(current, 'processing-instruction()', ['<?p1?>', '<?p2?>']);
    });
    test('processing-instruction("p2")', () {
      expectXPath(current, 'processing-instruction("p2")', ['<?p2?>']);
    });
    test('text()', () {
      expectXPath(current, 'text()', ['text', '<![CDATA[data]]>']);
    });
  });
  group('predicate', () {
    const input = '<?xml version="1.0"?>'
        '<r><e1 a="1"/><e2 a="2" b="3"/><e3 b="4"/></r>';
    final document = XmlDocument.parse(input);
    final current = document.rootElement;
    test('[n]', () {
      expectXPath(current, '*[1]', ['<e1 a="1"/>']);
      expectXPath(current, '*[2]', ['<e2 a="2" b="3"/>']);
      expectXPath(current, '*[3]', ['<e3 b="4"/>']);
      expectXPath(current, '*[4]');
    });
    test('[-n]', () {
      expectXPath(current, '*[-1]', ['<e3 b="4"/>']);
      expectXPath(current, '*[-2]', ['<e2 a="2" b="3"/>']);
      expectXPath(current, '*[-3]', ['<e1 a="1"/>']);
      expectXPath(current, '*[-4]');
    });
    test('[@attr]', () {
      expectXPath(current, '*[@a]', ['<e1 a="1"/>', '<e2 a="2" b="3"/>']);
      expectXPath(current, '*[@b]', ['<e2 a="2" b="3"/>', '<e3 b="4"/>']);
    });
    test('[@attr="literal"]', () {
      expectXPath(current, '*[@a="2"]', ['<e2 a="2" b="3"/>']);
      expectXPath(current, '*[@b="3"]', ['<e2 a="2" b="3"/>']);
    });
  });
  group('errors', () {
    final document = XmlDocument.parse('<?xml version="1.0"?><root/>');
    test('empty', () {
      expect(
          () => document.xpath(''),
          throwsA(isXPathParserException(
              message: '"." expected', buffer: '', position: 0)));
    });
    test('predicate', () {
      expect(
          () => document.xpath('*[1'),
          throwsA(isXPathParserException(
              message: 'end of input expected', buffer: '*[1', position: 1)));
    });
  });
  group('examples', () {
    group('https://en.wikipedia.org/wiki/XPath#Examples', () {
      final document = XmlDocument.parse(wikimediaXml);
      test('select name attributes for all projects', () {
        expectXPath(document, '/Wikimedia/projects/project/@name', [
          'name="Wikipedia"',
          'name="Wiktionary"',
        ]);
      });
      test('select all editions of all projects', () {
        expectXPath(document, '/Wikimedia//editions',
            document.findAllElements('editions'));
      });
      test('selects addresses of all English Wikimedia projects', () {
        expectXPath(
            document,
            '/Wikimedia/projects/project/editions/edition[@language=\'English\']/text()',
            [
              'en.wikipedia.org',
              'en.wiktionary.org',
            ]);
      });
      test('selects addresses of all Wikipedias', () {
        expectXPath(
            document,
            '/Wikimedia/projects/project[@name=\'Wikipedia\']/editions/edition/text()',
            [
              'en.wikipedia.org',
              'de.wikipedia.org',
              'fr.wikipedia.org',
              'pl.wikipedia.org',
              'es.wikipedia.org',
            ]);
      });
    });
    group('https://www.w3.org/TR/1999/REC-xpath-19991116/#path-abbrev', () {
      final document = XmlDocument.parse(shiporderXsd);
      final namedNode = {
        for (final node in document.descendantElements)
          for (final attribute in node.attributes)
            if (attribute.qualifiedName == 'name') attribute.value: node
      };

      // Selects the para element children of the context node.
      test('para', () {
        expectXPath(document, 'xsd:schema', document.childElements);
        expectXPath(document.firstElementChild, 'xsd:element', [
          '<xsd:element name="purchaseOrder" type="PurchaseOrderType"/>',
          '<xsd:element name="comment" type="xsd:string"/>'
        ]);
        expectXPath(document, 'unknown');
      });
      // Selects all element children of the context node.
      test('*', () {
        expectXPath(namedNode['PurchaseOrderType'], '*',
            namedNode['PurchaseOrderType']?.childElements);
        expectXPath(namedNode['purchaseOrder'], '*');
      });
      // Selects all text node children of the context node.
      test('text()', () {
        final documentation =
            document.findAllElements('xsd:documentation').single;
        expectXPath(documentation, 'text()', [documentation.innerText]);
        expectXPath(namedNode['shipTo'], 'text()');
      });
      // Selects the name attribute of the context node.
      test('@name', () {
        expectXPath(
            namedNode['purchaseOrder'], '@name', ['name="purchaseOrder"']);
        expectXPath(
            namedNode['purchaseOrder'], '@type', ['type="PurchaseOrderType"']);
        expectXPath(namedNode['purchaseOrder'], '@unknown');
      });
      // Selects all the attributes of the context node.
      test('@*', () {
        expectXPath(namedNode['purchaseOrder'], '@*',
            ['name="purchaseOrder"', 'type="PurchaseOrderType"']);
      });
      // Selects the first para child of the context node.
      test('para[1]', () {
        expectXPath(namedNode['USAddress'], 'xsd:sequence[1]',
            [namedNode['USAddress']?.firstElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:attribute[1]',
            [namedNode['USAddress']?.lastElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:sequence[2]');
      });
      // Selects the last para child of the context node.
      test('para[last()]', () {
        expectXPath(namedNode['USAddress'], 'xsd:sequence[-1]',
            [namedNode['USAddress']?.firstElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:attribute[-1]',
            [namedNode['USAddress']?.lastElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:sequence[-2]');
      });
      // // Selects all para grandchildren of the context node.
      test('*/para', () {
        expectXPath(document, '*/xsd:element', [
          '<xsd:element name="purchaseOrder" type="PurchaseOrderType"/>',
          '<xsd:element name="comment" type="xsd:string"/>'
        ]);
        expectXPath(document, '*/xsd:attribute');
      });
      // Selects the second section of the fifth chapter of the doc.
      test('/doc/chapter[5]/section[2]', () {
        expectXPath(document, '/xsd:schema/xsd:complexType[2]/xsd:attribute[1]',
            ['<xsd:attribute name="country" type="xsd:NMTOKEN" fixed="US"/>']);
        expectXPath(
            document, '/xsd:schema/xsd:complexType[3]/xsd:attribute[1]');
      });
      // Selects the para element descendants of the chapter element children of
      // the context node.
      test('chapter//para', () {
        expectXPath(document, 'xsd:schema//xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, 'unknown//xsd:attribute');
        expectXPath(document, 'xsd:schema//unknown');
      });
      // Selects all the para descendants of the document root and thus selects
      // all para elements in the same document as the context node.
      test('//para', () {
        expectXPath(document, '//xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, '//unknown');
      });
      // Selects all the item elements in the same document as the context node
      // that have an olist parent.
      test('//olist/item', () {
        expectXPath(document, '//xsd:complexType/xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, '//unknown/xsd:attribute');
        expectXPath(document, '//xsd:complexType/unknown');
      });
      // Selects the context node.
      test('.', () {
        expectXPath(document, '.', [document]);
        expectXPath(namedNode['country'], '.', [namedNode['country']]);
      });
      // Selects the para element descendants of the context node.
      test('.//para', () {
        expectXPath(document, './/xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(
            namedNode['item'], './/xsd:attribute', [namedNode['partNum']]);
        expectXPath(document, './/unknown');
      });
      // Selects the parent of the context node.
      test('..', () {
        expectXPath(document, '..');
        expectXPath(document.firstElementChild, '..', [document]);
      });
      // Selects the lang attribute of the parent of the context node.
      test('../@lang', () {
        expectXPath(namedNode['country'], '../@name', ['name="USAddress"']);
        expectXPath(namedNode['country'], '../@unknown');
      });
      // Selects all para children of the context node that have a type attribute
      // with value warning.
      test('para[@type="warning"]', () {
        expectXPath(namedNode['USAddress'], 'xsd:attribute[@name="country"]',
            [namedNode['country']]);
        expectXPath(namedNode['USAddress'], 'unknown[@name="country"]');
        expectXPath(namedNode['USAddress'], 'xsd:attribute[@name="unknown"]');
      });
      // Selects the fifth para child of the context node that has a type
      // attribute with value warning.
      test('para[@type="warning"][5]', () {
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][1]', [namedNode['name']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][4]', [namedNode['state']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][5]');
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:decimal"][1]', [namedNode['zip']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="unknown"][1]');
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@unknown="xsd:decimal"][1]');
      });
      // Selects the fifth para child of the context node if that child has a type
      // attribute with value warning.
      test('para[5][@type="warning"]', () {
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[4][@name="state"]', [namedNode['state']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[4][@name="unknown"]');
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[6][@name="state"]');
      });
      // Selects the chapter children of the context node that have one or more
      // title children with string-value equal to Introduction.
      test('chapter[title="Introduction"]', () {
        expectXPath(
            document.firstElementChild,
            'xsd:complexType[xsd:attribute]',
            [namedNode['PurchaseOrderType'], namedNode['USAddress']]);
        expectXPath(document.firstElementChild, 'unknown[xsd:attribute]');
        expectXPath(document.firstElementChild, 'xsd:complexType[unknown]');
        expectXPath(document.firstElementChild,
            'xsd:complexType[xsd:attribute="unknown"]');
      });
      // Selects the chapter children of the context node that have one or more
      // title children.
      test('chapter[title]', () {
        expectXPath(
            document.firstElementChild,
            'xsd:complexType[xsd:attribute]',
            [namedNode['PurchaseOrderType'], namedNode['USAddress']]);
        expectXPath(document.firstElementChild, 'unknown[xsd:attribute]');
        expectXPath(document.firstElementChild, 'xsd:complexType[unknown]');
      });
      // Selects all the employee children of the context node that have both a
      // secretary attribute and an assistant attribute.
      test('employee[@secretary and @assistant]', () {
        expectXPath(
            namedNode['PurchaseOrderType']?.firstElementChild,
            'xsd:element[@name][@type]',
            [namedNode['shipTo'], namedNode['billTo'], namedNode['items']]);
        expectXPath(
            namedNode['PurchaseOrderType']?.firstElementChild,
            'xsd:element[@ref][@minOccurs]',
            ['<xsd:element ref="comment" minOccurs="0"/>']);
        expectXPath(namedNode['PurchaseOrderType']?.firstElementChild,
            'xsd:element[@unknown][@type]');
        expectXPath(namedNode['PurchaseOrderType']?.firstElementChild,
            'xsd:element[@name][@unknown]');
      });
    });
  });
}
