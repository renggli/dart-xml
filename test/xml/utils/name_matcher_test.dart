import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xml/utils/name_matcher.dart';

void main() {
  group('createNameLookup', () {
    final elem1 = XmlElement(const XmlName.parts('foo'));
    final elem2 = XmlElement(
      const XmlName.parts('foo', prefix: 'p', namespaceUri: 'http://a'),
    );
    final elem3 = XmlElement(
      const XmlName.parts('bar', prefix: 'p', namespaceUri: 'http://a'),
    );

    test('without namespaceUri', () {
      final lookupFoo = createNameLookup('foo');
      check(lookupFoo(elem1)).isTrue();
      check(lookupFoo(elem2)).isFalse();

      final lookupPFoo = createNameLookup('p:foo');
      check(lookupPFoo(elem2)).isTrue();
      check(lookupPFoo(elem1)).isFalse();
    });

    test('with namespaceUri', () {
      final lookup = createNameLookup('foo', namespaceUri: 'http://a');
      check(lookup(elem2)).isTrue();
      check(lookup(elem1)).isFalse();
      check(lookup(elem3)).isFalse();
    });
  });

  group('createNameMatcher', () {
    final elem1 = XmlElement(const XmlName.parts('foo'));
    final elem2 = XmlElement(
      const XmlName.parts('foo', prefix: 'p', namespaceUri: 'http://a'),
    );
    final elem3 = XmlElement(
      const XmlName.parts('bar', prefix: 'q', namespaceUri: 'http://b'),
    );

    test('wildcard name with wildcard or null namespace', () {
      final matchAll1 = createNameMatcher('*');
      final matchAll2 = createNameMatcher('*', namespaceUri: '*');
      check(matchAll1(elem1)).isTrue();
      check(matchAll1(elem2)).isTrue();
      check(matchAll2(elem1)).isTrue();
      check(matchAll2(elem3)).isTrue();
    });

    test('wildcard name with specific namespace', () {
      final matchNsA = createNameMatcher('*', namespaceUri: 'http://a');
      check(matchNsA(elem1)).isFalse();
      check(matchNsA(elem2)).isTrue();
      check(matchNsA(elem3)).isFalse();
    });

    test('specific name with null namespace', () {
      final matchFoo = createNameMatcher('foo');
      check(matchFoo(elem1)).isTrue();
      check(matchFoo(elem2)).isFalse();
    });

    test('specific name with wildcard namespace', () {
      final matchAnyFoo = createNameMatcher('foo', namespaceUri: '*');
      check(matchAnyFoo(elem1)).isTrue();
      check(matchAnyFoo(elem2)).isTrue();
      check(matchAnyFoo(elem3)).isFalse();
    });

    test('specific name with specific namespace', () {
      final matchExact = createNameMatcher('foo', namespaceUri: 'http://a');
      check(matchExact(elem1)).isFalse();
      check(matchExact(elem2)).isTrue();
      check(matchExact(elem3)).isFalse();
    });
  });
}
