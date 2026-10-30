import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/utils/name_parser.dart';

void main() {
  group('nonColonizedStartChar', () {
    test('matches valid start chars', () {
      check(nonColonizedStartChar.accept('a')).isTrue();
      check(nonColonizedStartChar.accept('_')).isTrue();
      check(nonColonizedStartChar.accept('Z')).isTrue();
    });
    test('rejects colon and digits', () {
      check(nonColonizedStartChar.accept(':')).isFalse();
      check(nonColonizedStartChar.accept('0')).isFalse();
      check(nonColonizedStartChar.accept('-')).isFalse();
    });
  });

  group('nonColonizedChar', () {
    test('matches valid name chars', () {
      check(nonColonizedChar.accept('a')).isTrue();
      check(nonColonizedChar.accept('1')).isTrue();
      check(nonColonizedChar.accept('-')).isTrue();
      check(nonColonizedChar.accept('.')).isTrue();
    });
    test('rejects colon', () {
      check(nonColonizedChar.accept(':')).isFalse();
    });
  });

  group('nonColonizedNameToken', () {
    final parser = nonColonizedNameToken.end();
    test('parses simple NCName', () {
      check(parser.parse('hello').value).equals('hello');
      check(parser.parse('_valid-name.1').value).equals('_valid-name.1');
    });
    test('fails on name with colon', () {
      check(parser.parse('prefix:local') is Failure).isTrue();
    });
    test('fails on invalid start char', () {
      check(parser.parse('1name') is Failure).isTrue();
      check(parser.parse('-name') is Failure).isTrue();
    });
  });

  group('qualifiedNameToken', () {
    final parser = qualifiedNameToken.end();
    test('parses unprefixed QName', () {
      check(parser.parse('element').value).equals('element');
    });
    test('parses prefixed QName', () {
      check(parser.parse('p:element').value).equals('p:element');
      check(parser.parse('ns:item-1').value).equals('ns:item-1');
    });
    test('fails on multiple colons', () {
      check(parser.parse('a:b:c') is Failure).isTrue();
    });
  });

  group('validation helpers', () {
    test('isValidNCName', () {
      check(isValidNCName('foo')).isTrue();
      check(isValidNCName('_foo123')).isTrue();
      check(isValidNCName('foo:bar')).isFalse();
      check(isValidNCName('123foo')).isFalse();
      check(isValidNCName('')).isFalse();
    });

    test('isValidQName', () {
      check(isValidQName('foo')).isTrue();
      check(isValidQName('p:foo')).isTrue();
      check(isValidQName('p:foo:bar')).isFalse();
      check(isValidQName(':foo')).isFalse();
      check(isValidQName('foo:')).isFalse();
      check(isValidQName('123:foo')).isFalse();
    });

    test('splitQualifiedName', () {
      check(splitQualifiedName('foo')).equals((null, 'foo'));
      check(splitQualifiedName('prefix:local')).equals(('prefix', 'local'));
      check(splitQualifiedName(':local')).equals((null, ':local'));
    });

    test('parseEQNameParts', () {
      check(parseEQNameParts('foo')).equals((null, null, 'foo'));
      check(parseEQNameParts('p:foo')).equals((null, 'p', 'foo'));
      check(parseEQNameParts('Q{http://example.com}foo'))
          .equals(('http://example.com', null, 'foo'));
      check(parseEQNameParts('Q{http://example.com}p:foo'))
          .equals(('http://example.com', 'p', 'foo'));
      check(parseEQNameParts('Q{}foo')).equals((null, null, 'foo'));
      check(() => parseEQNameParts('Q{unclosed')).throws<Exception>();
    });
  });
}
