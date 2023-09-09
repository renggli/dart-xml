import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/parser.dart';
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

void expectEvaluate(XmlNode? node, String expression, dynamic matcher) =>
    expect(node!.xpathEvaluate(expression), matcher);

Matcher isNodes(dynamic value) =>
    isA<NodesValue>().having((value) => value.nodes, 'nodes', value);

Matcher isString(dynamic value) =>
    isA<StringValue>().having((value) => value.string, 'string', value);

Matcher isNumber(dynamic value) =>
    isA<NumberValue>().having((value) => value.number, 'number', value);

Matcher isBoolean(dynamic value) =>
    isA<BooleanValue>().having((value) => value.boolean, 'boolean', value);

void main() {
  group('literals', () {
    final xml = XmlDocument();
    test('number', () {
      expectEvaluate(xml, '0', isNumber(0));
      expectEvaluate(xml, '1', isNumber(1));
      expectEvaluate(xml, '-1', isNumber(-1));
      expectEvaluate(xml, '1.2', isNumber(1.2));
      expectEvaluate(xml, '-1.2', isNumber(-1.2));
    });
    test('string', () {
      expectEvaluate(xml, '""', isString(''));
      expectEvaluate(xml, '"Bar"', isString('Bar'));
      expectEvaluate(xml, "''", isString(''));
      expectEvaluate(xml, "'Foo'", isString('Foo'));
    });
  });
  group('functions', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    group('nodes', () {
      // TODO
    });
    group('string', () {
      test('string(nodes)', () {
        expectEvaluate(xml, 'string(.)', isString('123'));
        expectEvaluate(xml, 'string(/r/*)', isString('1'));
      });
      test('string(string)', () {
        expectEvaluate(xml, 'string("")', isString(''));
        expectEvaluate(xml, 'string("hello")', isString('hello'));
      });
      test('string(number)', () {
        expectEvaluate(xml, 'string(0 div 0)', isString('NaN'));
        expectEvaluate(xml, 'string(0)', isString('0'));
        expectEvaluate(xml, 'string(+0)', isString('0'));
        expectEvaluate(xml, 'string(-0)', isString('0'));
        expectEvaluate(xml, 'string(1 div 0)', isString('Infinity'));
        expectEvaluate(xml, 'string(-1 div 0)', isString('-Infinity'));
        expectEvaluate(xml, 'string(42)', isString('42'));
        expectEvaluate(xml, 'string(-42)', isString('-42'));
        expectEvaluate(xml, 'string(3.1415)', isString('3.1415'));
        expectEvaluate(xml, 'string(-3.1415)', isString('-3.1415'));
      });
      test('string(boolean)', () {
        expectEvaluate(xml, 'string(false())', isString('false'));
        expectEvaluate(xml, 'string(true())', isString('true'));
      });
      test('concat', () {
        expect(() => expectEvaluate(xml, 'concat()', isString('')),
            throwsA(isXPathFunctionException(name: 'concat')));
        expect(() => expectEvaluate(xml, 'concat("a")', isString('a')),
            throwsA(isXPathFunctionException(name: 'concat')));
        expectEvaluate(xml, 'concat("a", "b")', isString('ab'));
        expectEvaluate(xml, 'concat("a", "b", "c")', isString('abc'));
      });
      test('starts-with', () {
        expectEvaluate(xml, 'starts-with("abc", "")', isBoolean(true));
        expectEvaluate(xml, 'starts-with("abc", "a")', isBoolean(true));
        expectEvaluate(xml, 'starts-with("abc", "ab")', isBoolean(true));
        expectEvaluate(xml, 'starts-with("abc", "abc")', isBoolean(true));
        expectEvaluate(xml, 'starts-with("abc", "abcd")', isBoolean(false));
        expectEvaluate(xml, 'starts-with("abc", "bc")', isBoolean(false));
      });
      test('contains', () {
        expectEvaluate(xml, 'contains("abc", "")', isBoolean(true));
        expectEvaluate(xml, 'contains("abc", "a")', isBoolean(true));
        expectEvaluate(xml, 'contains("abc", "b")', isBoolean(true));
        expectEvaluate(xml, 'contains("abc", "c")', isBoolean(true));
        expectEvaluate(xml, 'contains("abc", "d")', isBoolean(false));
        expectEvaluate(xml, 'contains("abc", "ac")', isBoolean(false));
      });
      test('substring-before', () {
        expectEvaluate(xml, 'substring-before("abcde", "c")', isString('ab'));
        expectEvaluate(xml, 'substring-before("abcde", "x")', isString(''));
      });
      test('substring-after', () {
        expectEvaluate(xml, 'substring-after("abcde", "c")', isString('de'));
        expectEvaluate(xml, 'substring-after("abcde", "x")', isString(''));
      });
      test('substring', () {
        expectEvaluate(xml, 'substring("12345", 3)', isString('345'));
        expectEvaluate(xml, 'substring("12345", 2, 3)', isString('234'));
        expectEvaluate(xml, 'substring("12345", 0, 3)', isString('12'));
        expectEvaluate(xml, 'substring("12345", 4, 9)', isString('45'));
        expectEvaluate(xml, 'substring("12345", 1.5, 2.6)', isString('234'));
        expectEvaluate(xml, 'substring("12345", 0 div 0, 3)', isString(''));
        expectEvaluate(xml, 'substring("12345", 1, 0 div 0)', isString(''));
        expectEvaluate(
            xml, 'substring("12345", -42, 1 div 0)', isString('12345'));
        expectEvaluate(
            xml, 'substring("12345", -1 div 0, 1 div 0)', isString(''));
      });
      test('string-length', () {
        expectEvaluate(xml, 'string-length("")', isNumber(0));
        expectEvaluate(xml, 'string-length("1")', isNumber(1));
        expectEvaluate(xml, 'string-length("12")', isNumber(2));
        expectEvaluate(xml, 'string-length("123")', isNumber(3));
      });
      test('normalize-space', () {
        expectEvaluate(xml, 'normalize-space("")', isString(''));
        expectEvaluate(xml, 'normalize-space(" 1 ")', isString('1'));
        expectEvaluate(xml, 'normalize-space(" 1  2 ")', isString('1 2'));
        expectEvaluate(xml, 'normalize-space("1 \n2")', isString('1 2'));
      });
      test('translate', () {
        expectEvaluate(xml, 'translate("bar", "abc", "ABC")', isString('BAr'));
        expectEvaluate(xml, 'translate("-aaa-", "a-", "A")', isString('AAA'));
      });
    });
    group('number', () {
      test('number(nodes)', () {
        // TODO
      });
      test('number(string)', () {
        expectEvaluate(xml, 'number("")', isNumber(isNaN));
        expectEvaluate(xml, 'number("x")', isNumber(isNaN));
        expectEvaluate(xml, 'number("1")', isNumber(1));
        expectEvaluate(xml, 'number("1.2")', isNumber(1.2));
        expectEvaluate(xml, 'number("-1")', isNumber(-1));
        expectEvaluate(xml, 'number("-1.2")', isNumber(-1.2));
      });
      test('number(number)', () {
        expectEvaluate(xml, 'number(0)', isNumber(0));
        expectEvaluate(xml, 'number(-1)', isNumber(-1));
        expectEvaluate(xml, 'number(-1.2)', isNumber(-1.2));
      });
      test('number(boolean)', () {
        expectEvaluate(xml, 'number(true())', isNumber(1));
        expectEvaluate(xml, 'number(false())', isNumber(0));
      });
      test('sum', () {
        expectEvaluate(xml, 'sum(//text())', isNumber(6));
      });
      test('floor', () {
        expectEvaluate(xml, 'floor(-1.5)', isNumber(-2));
        expectEvaluate(xml, 'floor(1.5)', isNumber(1));
      });
      test('ceiling', () {
        expectEvaluate(xml, 'ceiling(-1.5)', isNumber(-1));
        expectEvaluate(xml, 'ceiling(1.5)', isNumber(2));
      });
      test('round', () {
        expectEvaluate(xml, 'round(-1.2)', isNumber(-1));
        expectEvaluate(xml, 'round(1.2)', isNumber(1));
      });
      test('math', () {
        expectEvaluate(xml, '-(1)', isNumber(-1));
        expectEvaluate(xml, '1 + 2', isNumber(3));
        expectEvaluate(xml, '1 - 2', isNumber(-1));
        expectEvaluate(xml, '2 * 3', isNumber(6));
        expectEvaluate(xml, '5 div 2', isNumber(2.5));
        expectEvaluate(xml, '5 idiv 2', isNumber(2));
        expectEvaluate(xml, '5 mod 2', isNumber(1));
        expectEvaluate(xml, '2 + 3 * 4', isNumber(14));
        expectEvaluate(xml, '2 * 3 + 4', isNumber(10));
      });
    });
    group('boolean', () {
      test('boolean(nodes)', () {
        expectEvaluate(xml, 'boolean(//a)', isBoolean(true));
        expectEvaluate(xml, 'boolean(//absent)', isBoolean(false));
      });
      test('boolean(string)', () {
        expectEvaluate(xml, 'boolean("")', isBoolean(false));
        expectEvaluate(xml, 'boolean("a")', isBoolean(true));
        expectEvaluate(xml, 'boolean("ab")', isBoolean(true));
      });
      test('boolean(number)', () {
        expectEvaluate(xml, 'boolean(0)', isBoolean(true));
        expectEvaluate(xml, 'boolean(1)', isBoolean(false));
        expectEvaluate(xml, 'boolean(-1)', isBoolean(false));
        expectEvaluate(xml, 'boolean(0 div 0)', isBoolean(false));
        expectEvaluate(xml, 'boolean(1 div 0)', isBoolean(false));
      });
      test('boolean(boolean)', () {
        expectEvaluate(xml, 'boolean(true())', isBoolean(true));
        expectEvaluate(xml, 'boolean(false())', isBoolean(false));
      });
      test('not(boolean)', () {
        expectEvaluate(xml, 'not(true())', isBoolean(false));
        expectEvaluate(xml, 'not(false())', isBoolean(true));
      });
      test('true()', () {
        expectEvaluate(xml, 'true()', isBoolean(true));
      });
      test('false()', () {
        expectEvaluate(xml, 'false()', isBoolean(false));
      });
    });
  });
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
  group('parser', () {
    test('linter', () {
      final parser = const XPathParser().build();
      expect(linter(parser), isEmpty);
    });
  });
}
