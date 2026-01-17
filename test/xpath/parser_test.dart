import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/parser.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';
import 'helpers.dart';

void main() {
  test('linter', () {
    final parser = const XPathParser().build();
    final issues = linter(parser);
    expect(issues, isEmpty);
  });
  group('whitespace', () {
    final document = XmlDocument.parse('<r><a/></r>');
    test('space', () {
      expectXPath(document, '//a', ['<a/>']);
      expectXPath(document, ' //a', ['<a/>']);
      expectXPath(document, '// a', ['<a/>']);
      expectXPath(document, '//a ', ['<a/>']);
    });
    test('other', () {
      expectXPath(document, '//\na', ['<a/>']);
      expectXPath(document, '//\ra', ['<a/>']);
      expectXPath(document, '//\ta', ['<a/>']);
    });
    test('comments', () {
      expectXPath(document, '(: comment :)//a', ['<a/>']);
      expectXPath(document, '//(: comment :)a', ['<a/>']);
      expectXPath(document, '//a(: comment :)', ['<a/>']);
    });
    test('nested comments', () {
      expectXPath(document, '//(: comment (: nested :) :)a', ['<a/>']);
      expectXPath(document, '//(: (: nested :) (: nested :) :)a', ['<a/>']);
    });
    test('combined space and comment', () {
      expectXPath(document, '//(: comment :) a', ['<a/>']);
      expectXPath(document, '// (: comment :)a', ['<a/>']);
      expectXPath(document, '// (: comment :) a', ['<a/>']);
    });
  });
  group('errors', () {
    final xml = XmlDocument.parse('<?xml version="1.0"?><root/>');
    // The exact error message and position might change as the grammar
    // changes. These tests are supposed to verify that invalid input is
    // rejected, not necessarily the messagen and position.
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
          () => xml.xpath(path),
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
