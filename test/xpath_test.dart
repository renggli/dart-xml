import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/parser.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import 'utils/examples.dart';
import 'utils/matchers.dart';

void expectXPath(
  XmlNode? node,
  String expression,
  dynamic matcher, {
  Map<String, XPathValue> variables = const {},
  Map<String, XPathFunction> functions = const {},
}) =>
    expect(
        node!.xpath(expression, variables: variables, functions: functions),
        matcher is Iterable
            ? orderedEquals(matcher.map((each) => each is String
                ? isA<XmlNode>()
                    .having((node) => node.outerXml, 'outerXml', each)
                : each))
            : matcher,
        reason: expression);

void expectEvaluate(
  XmlNode? node,
  String expression,
  dynamic matcher, {
  Map<String, XPathValue> variables = const {},
  Map<String, XPathFunction> functions = const {},
}) =>
    expect(
        node!.xpathEvaluate(expression,
            variables: variables, functions: functions),
        matcher,
        reason: expression);

Matcher isNodeSet(dynamic value) =>
    isA<XPathNodeSet>().having((value) => value.nodes, 'nodes', value);

Matcher isString(dynamic value) =>
    isA<XPathString>().having((value) => value.string, 'string', value);

Matcher isNumber(dynamic value) =>
    isA<XPathNumber>().having((value) => value.number, 'number', value);

Matcher isBoolean(dynamic value) =>
    isA<XPathBoolean>().having((value) => value.boolean, 'boolean', value);

void main() {
  group('values', () {
    group('nodes', () {
      test('empty', () {
        const value = XPathNodeSet.empty;
        expect(value.nodes, isEmpty);
        expect(value.string, '');
        expect(value.number, isNaN);
        expect(value.boolean, isFalse);
        expect(value.toString(), '[]');
      });
      test('document', () {
        final nodes = [XmlDocument.parse('<r>123</r>')];
        final value = XPathNodeSet(nodes);
        expect(value.nodes, nodes);
        expect(value.string, '123');
        expect(value.number, 123);
        expect(value.boolean, isTrue);
        expect(value.toString(), '[123]');
      });
      test('elements', () {
        final nodes =
            XmlDocument.parse('<r><a>1</a><b>2</b></r>').rootElement.children;
        final value = XPathNodeSet(nodes);
        expect(value.nodes, nodes);
        expect(value.string, '1');
        expect(value.number, 1);
        expect(value.boolean, isTrue);
        expect(value.toString(), '[1, 2]');
      });
      test('attributes', () {
        final nodes =
            XmlDocument.parse('<a b="1" c="2">0</a>').rootElement.attributes;
        final value = XPathNodeSet(nodes);
        expect(value.nodes, nodes);
        expect(value.string, '1');
        expect(value.number, 1);
        expect(value.boolean, isTrue);
        expect(value.toString(), '[1, 2]');
      });
      test('crop long values', () {
        final nodes = [
          XmlDocument.parse('<r>'
                  '<p>The quick brown fox jumps over the lazy dog.</p>'
                  '</r>')
              .rootElement
        ];
        final value = XPathNodeSet(nodes);
        expect(value.nodes, nodes);
        expect(value.string, 'The quick brown fox jumps over the lazy dog.');
        expect(value.number, isNaN);
        expect(value.boolean, isTrue);
        expect(value.toString(), '[The quick brown fox ...]');
      });
      test('crop many values', () {
        final nodes = XmlDocument.parse('<r>'
                '<p>First</p>'
                '<p>Second</p>'
                '<p>Third</p>'
                '<p>Fourth</p>'
                '</r>')
            .rootElement
            .children;
        final value = XPathNodeSet(nodes);
        expect(value.nodes, nodes);
        expect(value.string, 'First');
        expect(value.number, isNaN);
        expect(value.boolean, isTrue);
        expect(value.toString(), '[First, Second, Third, ...]');
      });
      test('sorting', () {
        final nodes =
            XmlDocument.parse('<r><a/><b/><c/></r>').rootElement.children;
        final value = XPathNodeSet([nodes[2], nodes[1], nodes[0]]);
        expect(value.nodes, nodes);
      });
      test('deduplication', () {
        final nodes =
            XmlDocument.parse('<r><a/><b/><c/></r>').rootElement.children;
        final value =
            XPathNodeSet([nodes[2], nodes[2], nodes[0], nodes[0], nodes[1]]);
        expect(value.nodes, nodes);
      });
    });
    group('string', () {
      test('empty', () {
        const value = XPathString('');
        expect(() => value.nodes, throwsStateError);
        expect(value.string, '');
        expect(value.number, isNaN);
        expect(value.boolean, isFalse);
        expect(value.toString(), '""');
      });
      test('full', () {
        const value = XPathString('123');
        expect(() => value.nodes, throwsStateError);
        expect(value.string, '123');
        expect(value.number, 123);
        expect(value.boolean, isTrue);
        expect(value.toString(), '"123"');
      });
    });
    group('number', () {
      test('0', () {
        const value = XPathNumber(0);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, '0');
        expect(value.number, 0);
        expect(value.boolean, isTrue);
        expect(value.toString(), '0');
      });
      test('1.14', () {
        const value = XPathNumber(1.14);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, '1.14');
        expect(value.number, 1.14);
        expect(value.boolean, isFalse);
        expect(value.toString(), '1.14');
      });
      test('nan', () {
        const value = XPathNumber(double.nan);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, 'NaN');
        expect(value.number, isNaN);
        expect(value.boolean, isFalse);
        expect(value.toString(), 'NaN');
      });
      test('+infinity', () {
        const value = XPathNumber(double.infinity);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, 'Infinity');
        expect(value.number, double.infinity);
        expect(value.boolean, isFalse);
        expect(value.toString(), 'Infinity');
      });
      test('-infinity', () {
        const value = XPathNumber(double.negativeInfinity);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, '-Infinity');
        expect(value.number, double.negativeInfinity);
        expect(value.boolean, isFalse);
        expect(value.toString(), '-Infinity');
      });
    });
    group('boolean', () {
      test('true', () {
        const value = XPathBoolean(true);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, 'true');
        expect(value.number, 1);
        expect(value.boolean, isTrue);
        expect(value.toString(), 'true()');
      });
      test('false', () {
        const value = XPathBoolean(false);
        expect(() => value.nodes, throwsStateError);
        expect(value.string, 'false');
        expect(value.number, 0);
        expect(value.boolean, isFalse);
        expect(value.toString(), 'false()');
      });
    });
  });
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
    test('variable', () {
      expectEvaluate(xml, '\$a', isString('hello'),
          variables: const {'a': XPathString('hello')});
      expectEvaluate(xml, '\$a', isNumber(123),
          variables: const {'a': XPathNumber(123)});
      expectEvaluate(xml, '\$a', isBoolean(false),
          variables: const {'a': XPathBoolean(false)});
      expect(() => expectEvaluate(xml, '\$unknown', anything),
          throwsA(isXPathEvaluationException()));
    });
    test('function', () {
      expectEvaluate(xml, 'custom("hello", 42, true())', isString('ok'),
          functions: {
            'custom': (context, arguments) {
              expect(context.node, same(xml));
              expect(context.position, 1);
              expect(context.last, 1);
              expect(arguments, [
                isString('hello'),
                isNumber(42),
                isBoolean(true),
              ]);
              return const XPathString('ok');
            }
          });
      expect(() => expectEvaluate(xml, 'unknown()', anything),
          throwsA(isXPathEvaluationException()));
    });
  });
  group('functions', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    group('nodes', () {
      test('last()', () {
        expectEvaluate(xml, 'last()', isNumber(1));
        expectEvaluate(
            xml, '/r/*[last()]', isNodeSet([xml.rootElement.children.last]));
      });
      test('position()', () {
        expectEvaluate(xml, 'position()', isNumber(1));
        expectEvaluate(
            xml, '/r/*[position()]', isNodeSet(xml.rootElement.children));
      });
      test('count(node-set)', () {
        expectEvaluate(xml, 'count(/*)', isNumber(1));
        expectEvaluate(xml, 'count(/r/*)', isNumber(2));
        expectEvaluate(xml, 'count(/r/b/*)', isNumber(1));
        expectEvaluate(xml, 'count(/r/b/absent)', isNumber(0));
      });
      test('id(object)', () {
        final xml = XmlDocument.parse('<r><a id="a">a</a><b id="b">b</b></r>');
        expectEvaluate(xml, 'id("a b")', isNodeSet(xml.rootElement.children));
        expectEvaluate(
            xml, 'id("b")', isNodeSet([xml.rootElement.children.last]));
        expectEvaluate(xml, 'id(/r/*)', isNodeSet(xml.rootElement.children));
        expectEvaluate(
            xml, 'id(/r/b)', isNodeSet([xml.rootElement.children.last]));
      });
      test('local-name(node-set?)', () {
        expectEvaluate(xml, 'local-name(/r/*)', isString('a'));
        expectEvaluate(
          xml,
          '/r/*[local-name()="a"]',
          isNodeSet(xml.findAllElements('a')),
        );
      });
      test('namespace-uri(node-set?)', () {
        expectEvaluate(xml, 'namespace-uri(/r/*)', isString(''));
        expectEvaluate(
          xml,
          '/r/*[namespace-uri()=""]',
          isNodeSet(xml.rootElement.findElements('*')),
        );
      });
      test('name(node-set?)', () {
        expectEvaluate(xml, 'name(/r/*)', isString('a'));
        expectEvaluate(
          xml,
          '/r/*[name()="a"]',
          isNodeSet(xml.findAllElements('a')),
        );
      });
      test('intersect(node-set, node-set)', () {
        final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
        final children = xml.rootElement.children;
        expectEvaluate(xml, '(r/*) intersect (r/*)', isNodeSet(children));
        expectEvaluate(xml, '(r/*) intersect (r/b)', isNodeSet([children[1]]));
        expectEvaluate(xml, '(r/b) intersect (r/*)', isNodeSet([children[1]]));
        expectEvaluate(xml, '(r/b) intersect (r/b)', isNodeSet([children[1]]));
        expectEvaluate(xml, '(r/a) intersect (r/c)', isNodeSet(isEmpty));
      });
      test('except(node-set, node-set)', () {
        final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
        final children = xml.rootElement.children;
        expectEvaluate(xml, '(r/*) except (r/*)', isNodeSet(isEmpty));
        expectEvaluate(
            xml, '(r/*) except (r/b)', isNodeSet([children[0], children[2]]));
        expectEvaluate(xml, '(r/b) except (r/*)', isNodeSet(isEmpty));
        expectEvaluate(xml, '(r/b) except (r/b)', isNodeSet(isEmpty));
        expectEvaluate(xml, '(r/a) except (r/c)', isNodeSet([children[0]]));
      });
      test('union(node-set, node-set)', () {
        final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
        final children = xml.rootElement.children;
        expectEvaluate(xml, '(r/*) union (r/*)', isNodeSet(children));
        expectEvaluate(xml, '(r/a) union (r/a)', isNodeSet([children[0]]));
        expectEvaluate(
            xml, '(r/a) union (r/c)', isNodeSet([children[0], children[2]]));
        expectEvaluate(
            xml, '(r/c) union (r/a)', isNodeSet([children[0], children[2]]));
      });
      test('|(node-set, node-set)', () {
        final xml = XmlDocument.parse('<r><a/><b/><c/></r>');
        final children = xml.rootElement.children;
        expectEvaluate(xml, '(r/*) | (r/*)', isNodeSet(children));
        expectEvaluate(xml, '(r/a) | (r/a)', isNodeSet([children[0]]));
        expectEvaluate(
            xml, '(r/a) | (r/c)', isNodeSet([children[0], children[2]]));
        expectEvaluate(
            xml, '(r/c) | (r/a)', isNodeSet([children[0], children[2]]));
      });
    });
    group('string', () {
      test('string(nodes)', () {
        expectEvaluate(xml, 'string()', isString('123'));
        expectEvaluate(xml, 'string(/r/b)', isString('23'));
      });
      test('string(string)', () {
        expectEvaluate(xml, 'string("")', isString(''));
        expectEvaluate(xml, 'string("hello")', isString('hello'));
      });
      test('string(number)', () {
        expectEvaluate(xml, 'string(0)', isString('0'));
        expectEvaluate(xml, 'string(0 div 0)', isString('NaN'));
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
        expect(() => expectEvaluate(xml, 'concat()', anything),
            throwsA(isXPathEvaluationException(name: 'concat')));
        expect(() => expectEvaluate(xml, 'concat("a")', anything),
            throwsA(isXPathEvaluationException(name: 'concat')));
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
        expect(() => expectEvaluate(xml, 'substring-after("abcde")', anything),
            throwsA(isXPathEvaluationException(name: 'substring-after')));
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
        expect(() => expectEvaluate(xml, 'substring("abcde")', anything),
            throwsA(isXPathEvaluationException(name: 'substring')));
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
        expectEvaluate(xml, 'number()', isNumber(123));
        expectEvaluate(xml, 'number(/r/b)', isNumber(23));
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
        final attr = XmlDocument.parse('<r><e a="36"/><e a="6"/></r>');
        expectEvaluate(attr, 'sum(/r/e/@a)', isNumber(42));
      });
      test('floor', () {
        expectEvaluate(xml, 'floor(-1.5)', isNumber(-2));
        expectEvaluate(xml, 'floor(1.5)', isNumber(1));
      });
      test('abs', () {
        expectEvaluate(xml, 'abs(-2)', isNumber(2));
        expectEvaluate(xml, 'abs(3)', isNumber(3));
      });
      test('ceiling', () {
        expectEvaluate(xml, 'ceiling(-1.5)', isNumber(-1));
        expectEvaluate(xml, 'ceiling(1.5)', isNumber(2));
      });
      test('round', () {
        expectEvaluate(xml, 'round(-1.2)', isNumber(-1));
        expectEvaluate(xml, 'round(1.2)', isNumber(1));
      });
      test('- (prefix)', () {
        expectEvaluate(xml, '-1', isNumber(-1));
        expectEvaluate(xml, '--1', isNumber(1));
        expectEvaluate(xml, '---1', isNumber(-1));
      });
      test('+ (prefix)', () {
        expectEvaluate(xml, '+1', isNumber(1));
        expectEvaluate(xml, '++1', isNumber(1));
        expectEvaluate(xml, '+++1', isNumber(1));
      });
      test('+', () {
        expectEvaluate(xml, '1 + 2', isNumber(3));
        expectEvaluate(xml, '3 + 4', isNumber(7));
      });
      test('-', () {
        expectEvaluate(xml, '1 - 2', isNumber(-1));
        expectEvaluate(xml, '4 - 3', isNumber(1));
      });
      test('*', () {
        expectEvaluate(xml, '2 * 3', isNumber(6));
        expectEvaluate(xml, '3 * 2', isNumber(6));
      });
      test('div', () {
        expectEvaluate(xml, '6 div 3', isNumber(2));
        expectEvaluate(xml, '5 div 2', isNumber(2.5));
      });
      test('idiv', () {
        expectEvaluate(xml, '5 idiv 2', isNumber(2));
        expectEvaluate(xml, '8 idiv 2', isNumber(4));
      });
      test('neg', () {
        expectEvaluate(xml, '5 mod 2', isNumber(1));
        expectEvaluate(xml, '8 mod 2', isNumber(0));
      });
      test('priority', () {
        expectEvaluate(xml, '2 + 3 * 4', isNumber(14));
        expectEvaluate(xml, '2 * 3 + 4', isNumber(10));
      });
      test('parenthesis', () {
        expectEvaluate(xml, '(2 + 3) * 4', isNumber(20));
        expectEvaluate(xml, '2 * (3 + 4)', isNumber(14));
      });
    });
    group('boolean', () {
      test('boolean(nodes)', () {
        expectEvaluate(xml, 'boolean()', isBoolean(true));
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
      test('lang(string)', () {
        final positives = [
          '<para xml:lang="en"/>',
          '<div xml:lang="en"><para/></div>',
          '<para xml:lang="EN"/>',
          '<para xml:lang="en-us"/>',
        ];
        for (final positive in positives) {
          final xml = XmlDocument.parse(positive);
          final start = xml.findAllElements('para').first;
          expectEvaluate(start, 'lang("en")', isBoolean(true));
        }
        final negatives = [
          '<para/>',
          '<para xml:lang=""/>',
          '<para xml:lang="de"/>',
        ];
        for (final positive in negatives) {
          final xml = XmlDocument.parse(positive);
          final start = xml.findAllElements('para').first;
          expectEvaluate(start, 'lang("en")', isBoolean(false));
        }
      });
      test('<', () {
        expectEvaluate(xml, '1 < 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 < 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 < 1', isBoolean(isFalse));
      });
      test('<=', () {
        expectEvaluate(xml, '1 <= 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 <= 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 <= 1', isBoolean(isFalse));
      });
      test('>', () {
        expectEvaluate(xml, '1 > 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 > 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 > 1', isBoolean(isTrue));
      });
      test('>=', () {
        expectEvaluate(xml, '1 >= 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 >= 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 >= 1', isBoolean(isTrue));
      });
      test('=', () {
        expectEvaluate(xml, '1 = 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 = 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 = 1', isBoolean(isFalse));
      });
      test('!=', () {
        expectEvaluate(xml, '1 != 2', isBoolean(isTrue));
        expectEvaluate(xml, '2 != 2', isBoolean(isFalse));
        expectEvaluate(xml, '2 != 1', isBoolean(isTrue));
      });
      test('and', () {
        expectEvaluate(xml, 'true() and true()', isBoolean(isTrue));
        expectEvaluate(xml, 'true() and false()', isBoolean(isFalse));
        expectEvaluate(xml, 'false() and true()', isBoolean(isFalse));
        expectEvaluate(xml, 'false() and false()', isBoolean(isFalse));
      });
      test('or', () {
        expectEvaluate(xml, 'true() or true()', isBoolean(isTrue));
        expectEvaluate(xml, 'true() or false()', isBoolean(isTrue));
        expectEvaluate(xml, 'false() or true()', isBoolean(isTrue));
        expectEvaluate(xml, 'false() or false()', isBoolean(isFalse));
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
      expectXPath(current, '*[4]', isEmpty);
    });
    test('[last()]', () {
      expectXPath(current, '*[last()]', ['<e3 b="4"/>']);
      expectXPath(current, '*[last()-1]', ['<e2 a="2" b="3"/>']);
      expectXPath(current, '*[last()-2]', ['<e1 a="1"/>']);
      expectXPath(current, '*[last()-3]', isEmpty);
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
    final xml = XmlDocument.parse('<?xml version="1.0"?><root/>');
    test('empty', () {
      expect(
          () => xml.xpath(''),
          throwsA(isXPathParserException(
              message: 'name expected', buffer: '', position: 0)));
    });
    test('predicate', () {
      expect(
          () => xml.xpath('*[1'),
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
        expectXPath(document, 'unknown', isEmpty);
      });
      // Selects all element children of the context node.
      test('*', () {
        expectXPath(namedNode['PurchaseOrderType'], '*',
            namedNode['PurchaseOrderType']?.childElements);
        expectXPath(namedNode['purchaseOrder'], '*', isEmpty);
      });
      // Selects all text node children of the context node.
      test('text()', () {
        final documentation =
            document.findAllElements('xsd:documentation').single;
        expectXPath(documentation, 'text()', [documentation.innerText]);
        expectXPath(namedNode['shipTo'], 'text()', isEmpty);
      });
      // Selects the name attribute of the context node.
      test('@name', () {
        expectXPath(
            namedNode['purchaseOrder'], '@name', ['name="purchaseOrder"']);
        expectXPath(
            namedNode['purchaseOrder'], '@type', ['type="PurchaseOrderType"']);
        expectXPath(namedNode['purchaseOrder'], '@unknown', isEmpty);
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
        expectXPath(namedNode['USAddress'], 'xsd:sequence[2]', isEmpty);
      });
      // Selects the last para child of the context node.
      test('para[last()]', () {
        expectXPath(namedNode['USAddress'], 'xsd:sequence[last()]',
            [namedNode['USAddress']?.firstElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:attribute[last()]',
            [namedNode['USAddress']?.lastElementChild]);
        expectXPath(namedNode['USAddress'], 'xsd:sequence[last()-1]', isEmpty);
      });
      // // Selects all para grandchildren of the context node.
      test('*/para', () {
        expectXPath(document, '*/xsd:element', [
          '<xsd:element name="purchaseOrder" type="PurchaseOrderType"/>',
          '<xsd:element name="comment" type="xsd:string"/>'
        ]);
        expectXPath(document, '*/xsd:attribute', isEmpty);
      });
      // Selects the second section of the fifth chapter of the doc.
      test('/doc/chapter[5]/section[2]', () {
        expectXPath(document, '/xsd:schema/xsd:complexType[2]/xsd:attribute[1]',
            ['<xsd:attribute name="country" type="xsd:NMTOKEN" fixed="US"/>']);
        expectXPath(document, '/xsd:schema/xsd:complexType[3]/xsd:attribute[1]',
            isEmpty);
      });
      // Selects the para element descendants of the chapter element children of
      // the context node.
      test('chapter//para', () {
        expectXPath(document, 'xsd:schema//xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, 'unknown//xsd:attribute', isEmpty);
        expectXPath(document, 'xsd:schema//unknown', isEmpty);
      });
      // Selects all the para descendants of the document root and thus selects
      // all para elements in the same document as the context node.
      test('//para', () {
        expectXPath(document, '//xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, '//unknown', isEmpty);
      });
      // Selects all the item elements in the same document as the context node
      // that have an olist parent.
      test('//olist/item', () {
        expectXPath(document, '//xsd:complexType/xsd:attribute', [
          namedNode['orderDate'],
          namedNode['country'],
          namedNode['partNum']
        ]);
        expectXPath(document, '//unknown/xsd:attribute', isEmpty);
        expectXPath(document, '//xsd:complexType/unknown', isEmpty);
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
        expectXPath(document, './/unknown', isEmpty);
      });
      // Selects the parent of the context node.
      test('..', () {
        expectXPath(document, '..', isEmpty);
        expectXPath(document.firstElementChild, '..', [document]);
      });
      // Selects the lang attribute of the parent of the context node.
      test('../@lang', () {
        expectXPath(namedNode['country'], '../@name', ['name="USAddress"']);
        expectXPath(namedNode['country'], '../@unknown', isEmpty);
      });
      // Selects all para children of the context node that have a type attribute
      // with value warning.
      test('para[@type="warning"]', () {
        expectXPath(namedNode['USAddress'], 'xsd:attribute[@name="country"]',
            [namedNode['country']]);
        expectXPath(
            namedNode['USAddress'], 'unknown[@name="country"]', isEmpty);
        expectXPath(
            namedNode['USAddress'], 'xsd:attribute[@name="unknown"]', isEmpty);
      });
      // Selects the fifth para child of the context node that has a type
      // attribute with value warning.
      test('para[@type="warning"][5]', () {
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][1]', [namedNode['name']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][4]', [namedNode['state']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:string"][5]', isEmpty);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="xsd:decimal"][1]', [namedNode['zip']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@type="unknown"][1]', isEmpty);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[@unknown="xsd:decimal"][1]', isEmpty);
      });
      // Selects the fifth para child of the context node if that child has a type
      // attribute with value warning.
      test('para[5][@type="warning"]', () {
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[4][@name="state"]', [namedNode['state']]);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[4][@name="unknown"]', isEmpty);
        expectXPath(namedNode['USAddress']?.firstElementChild,
            'xsd:element[6][@name="state"]', isEmpty);
      });
      // Selects the chapter children of the context node that have one or more
      // title children with string-value equal to Introduction.
      test('chapter[title="Introduction"]', () {
        expectXPath(
            document.firstElementChild,
            'xsd:complexType[xsd:attribute]',
            [namedNode['PurchaseOrderType'], namedNode['USAddress']]);
        expectXPath(
            document.firstElementChild, 'unknown[xsd:attribute]', isEmpty);
        expectXPath(
            document.firstElementChild, 'xsd:complexType[unknown]', isEmpty);
        expectXPath(document.firstElementChild,
            'xsd:complexType[xsd:attribute="unknown"]', isEmpty);
      });
      // Selects the chapter children of the context node that have one or more
      // title children.
      test('chapter[title]', () {
        expectXPath(
            document.firstElementChild,
            'xsd:complexType[xsd:attribute]',
            [namedNode['PurchaseOrderType'], namedNode['USAddress']]);
        expectXPath(
            document.firstElementChild, 'unknown[xsd:attribute]', isEmpty);
        expectXPath(
            document.firstElementChild, 'xsd:complexType[unknown]', isEmpty);
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
            'xsd:element[@unknown][@type]', isEmpty);
        expectXPath(namedNode['PurchaseOrderType']?.firstElementChild,
            'xsd:element[@name][@unknown]', isEmpty);
      });
    });
  });
  group('generator', () {
    for (final MapEntry(key: key, value: value) in allXml.entries) {
      test(key, () {
        final document = XmlDocument.parse(value);
        for (final node in [document, ...document.descendants]) {
          final expression = node.xpathGenerate(byId: 'id');
          final result = document.xpath(expression);
          expect(result.single, node, reason: expression);
        }
      });
    }
  });
  group('parser', () {
    test('linter', () {
      final parser = const XPathParser().build();
      expect(linter(parser), isEmpty);
    });
  });
}
