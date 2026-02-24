import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/expression.dart';
import 'package:xml/src/xpath/grammars/xpath.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  final parser = const XPathGrammar().build();
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
      'simple map': ['1 ! 2', '1!2'],
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
        'namespace::foo',
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
        'element()',
        'element(*)',
        'attribute()',
        'attribute(*)',
        'namespace-node()',
        'schema-element(foo)',
        'schema-attribute(foo)',
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
      'functions': [
        // function calls
        'foo()',
        'bar(1)',
        'xx:zork(1, 2)',
        'foo(1, ?)',
        'Q{http://www.w3.org/2005/xpath-functions}abs(-1)',
        // inline functions
        'function() as xs:integer+ { 2, 3, 5, 7, 11, 13 }',
        'function(\$a as xs:double, \$b as xs:double) as xs:double { \$a * \$b }',
        'function(\$a) { \$a }',
        // arrow functions
        '\$string => upper-case()',
        '"hello" => upper-case() => normalize-unicode() => tokenize("s+")',
        // function references
        'fn:abs#1',
        'fn:concat#5',
        'local:myfunc#2',
        'Q{http://www.w3.org/2005/xpath-functions}node-name#0',
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
}
