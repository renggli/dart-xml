import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/expression.dart';
import 'package:xml/src/xpath/parser.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';
import 'helpers.dart';

void main() {
  final parser = const XPathParser().build();
  final xml = XmlDocument.parse('<?xml version="1.0"?><r><a/></r>');
  test('linter', () {
    final issues = linter(parser);
    expect(issues, isEmpty);
  });
  group('whitespace', () {
    test('space', () {
      expectXPath(xml, '//a', ['<a/>']);
      expectXPath(xml, ' //a', ['<a/>']);
      expectXPath(xml, '// a', ['<a/>']);
      expectXPath(xml, '//a ', ['<a/>']);
    });
    test('other', () {
      expectXPath(xml, '//\na', ['<a/>']);
      expectXPath(xml, '//\ra', ['<a/>']);
      expectXPath(xml, '//\ta', ['<a/>']);
    });
    test('comments', () {
      expectXPath(xml, '(: comment :)//a', ['<a/>']);
      expectXPath(xml, '//(: comment :)a', ['<a/>']);
      expectXPath(xml, '//a(: comment :)', ['<a/>']);
    });
    test('nested comments', () {
      expectXPath(xml, '//(: comment (: nested :) :)a', ['<a/>']);
      expectXPath(xml, '//(: (: nested :) (: nested :) :)a', ['<a/>']);
    });
    test('combined space and comment', () {
      expectXPath(xml, '//(: comment :) a', ['<a/>']);
      expectXPath(xml, '// (: comment :)a', ['<a/>']);
      expectXPath(xml, '// (: comment :) a', ['<a/>']);
    });
  });
  group('productions', () {
    final cases = {
      'literals': ['1', '1.2', '"string"', "'string'"],
      'variables': ['\$foo', '\$foo:bar'],
      'function calls': ['foo()', 'foo(1)', 'foo(1, 2)'],
      'paths': [
        '/',
        'child::foo',
        'foo',
        'foo/bar',
        '//foo',
        'foo//bar',
        'foo/(foo | bar)',
        '.',
        '..',
        '@foo',
      ],
      'operators': [
        '1 + 2',
        '1 - 2',
        '1 * 2',
        '1 div 2',
        '1 mod 2',
        '1 = 2',
        '1 != 2',
        '1 < 2',
        '1 <= 2',
        '1 > 2',
        '1 >= 2',
      ],
      'logical': ['1 and 2', '1 or 2'],
      'conditionals': ['if (1) then 2 else 3'],
      'for expression': ['for \$i in (1, 2) return \$i'],
      'quantified expression': [
        'some \$i in (1, 2) satisfies \$i > 0',
        'every \$i in (1, 2) satisfies \$i > 0',
      ],
      'sequence': ['1, 2, 3', '()'],
      'predicate': ['foo[1]', 'foo[1][2]'],
      'axis': [
        'ancestor::foo',
        'ancestor-or-self::foo',
        'attribute::foo',
        'child::foo',
        'descendant::foo',
        'descendant-or-self::foo',
        'following::foo',
        'following-sibling::foo',
        'parent::foo',
        'preceding::foo',
        'preceding-sibling::foo',
        'self::foo',
      ],
      'kind tests': [
        'node()',
        'text()',
        'comment()',
        'processing-instruction()',
        'processing-instruction("foo")',
        'element()',
        'attribute()',
        'document-node()',
      ],
      'map': ['map { "a": 1, "b": 2 }'],
      'array': ['[1, 2, 3]', 'array { 1, 2, 3 }'],
      'union/intersect/except': [
        'a union b',
        'a | b',
        'a intersect b',
        'a except b',
      ],
    };
    for (final MapEntry(key: name, value: expressions) in cases.entries) {
      group(name, () {
        for (final expression in expressions) {
          test(expression, () {
            final result = parser.parse(expression);
            expect(result.value, isA<XPathExpression>());
          });
        }
      });
    }
  });
  group('errors', () {
    // The exact error message and position might change as the grammar evolves.
    // These tests are supposed to verify that invalid input is rejected, not
    // necessarily their message and position.
    final cases = {
      '': ('qualified name expected', 0),
      ':': ('qualified name expected', 0),
      '//': ('end of input expected', 1),
      '*[': ('end of input expected', 1),
      '*]': ('end of input expected', 1),
      '*:': ('end of input expected', 1),
      ':false()': ('qualified name expected', 0),
      'false:()': ('end of input expected', 5),
      'false(:)': ('success not expected', 5),
      'false():': ('end of input expected', 7),
      ':a/b': ('qualified name expected', 0),
      'a:/b': ('end of input expected', 1),
      'a/:b': ('end of input expected', 1),
      'a/b:': ('end of input expected', 3),
      '/:a/b': ('end of input expected', 1),
      '/a:/b': ('end of input expected', 2),
      '/a/:b': ('end of input expected', 2),
      '/a/b:': ('end of input expected', 4),
      '//:a/b': ('end of input expected', 1),
      '//a:/b': ('end of input expected', 3),
      '//a/:b': ('end of input expected', 3),
      '//a/b:': ('end of input expected', 5),
    };
    for (final MapEntry(key: path, value: (message, position))
        in cases.entries) {
      test(
        path,
        () => expect(
          () => xml.xpathEvaluate(path),
          throwsA(
            isXPathParserException(
              message: message,
              buffer: path,
              position: position,
            ),
          ),
        ),
      );
    }
  });
  group('unimplemented', () {
    // These tests are supposed that otherwise valid expressions are not yet
    // implemented. These tests are supposed to throw an `UnimplementedError`,
    // and not succeed or give a parse failure.
    final cases = {
      '1 => upper-case()': 'ArrowExpr',
      '1 is 2': 'NodeComp (is)',
      '1 << 2': 'NodeComp (<<)',
      '1 >> 2': 'NodeComp (>>)',
      '\$docs ! (//employee)': 'SimpleMapExpr',
      'namespace::foo': 'NamespaceAxis',
      '[4, 5, 6]?2': 'Lookup',
      'foo(1, ?)': 'ArgumentPlaceholder',
      '\$map[?name="Mike"]': 'UnaryLookup',
      'foo#1': 'NamedFunctionRef',
      'function() as xs:integer { 2 }': 'InlineFunctionExpr',
      'namespace-node()': 'NamespaceNodeTest',
      'attribute(*)': 'AttributeTest',
      'schema-attribute(foo)': 'SchemaAttributeTest',
      'element(*)': 'ElementTest',
      'schema-element(foo)': 'SchemaElementTest',
    };
    for (final MapEntry(key: expression, value: name) in cases.entries) {
      test(expression, () {
        expect(
          () => xml.xpathEvaluate(expression),
          throwsA(
            isA<UnimplementedError>().having(
              (e) => e.message,
              'message',
              '$name not yet implemented',
            ),
          ),
        );
      });
    }
  });
}
