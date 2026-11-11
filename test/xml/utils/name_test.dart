import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../../utils/checks.dart';

const namespaceUri = 'http://example.com';

void main() {
  group('XmlName', () {
    test('without prefix', () {
      check(XmlName('bar', namespaceUri: namespaceUri))
        ..qualified.equals('bar')
        ..prefix.isNull()
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('bar');
    });
    test('with prefix', () {
      check(XmlName('foo:bar', namespaceUri: namespaceUri))
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
  });
  group('XmlName.parse', () {
    test('in extended form with prefix', () {
      check(XmlName.parse('Q{$namespaceUri}foo:bar'))
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
    test('in extended form without prefix', () {
      check(XmlName.parse('Q{$namespaceUri}bar'))
        ..qualified.equals('bar')
        ..prefix.isNull()
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('bar');
    });
    test('with empty extended form', () {
      check(XmlName.parse('Q{}bar'))
        ..qualified.equals('bar')
        ..prefix.isNull()
        ..local.equals('bar')
        ..namespaceUri.isNull()
        ..extendedQualified.equals('bar')
        ..asString.equals('bar');
    });
    test('with invalid extended form', () {
      check(() => XmlName.parse('Q{bar')).throws<XmlParserException>();
    });
    test('with prefix and namespace map', () {
      check(
          XmlName.parse('foo:bar', namespaceUris: const {'foo': namespaceUri}),
        )
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
    test('with prefix and default namespace', () {
      check(XmlName.parse('foo:bar', namespaceUri: namespaceUri))
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
  });
  group('XmlName.parts', () {
    test('without prefix', () {
      check(const XmlName.parts('bar', namespaceUri: namespaceUri))
        ..qualified.equals('bar')
        ..prefix.isNull()
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('bar');
    });
    test('with prefix', () {
      check(
          const XmlName.parts('bar', prefix: 'foo', namespaceUri: namespaceUri),
        )
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
  });
  group('XmlName.namespace', () {
    test('XmlName.namespace with name', () {
      check(const XmlName.namespace(name: 'bar'))
        ..qualified.equals('xmlns:bar')
        ..prefix.equals('xmlns')
        ..local.equals('bar')
        ..namespaceUri.equals('http://www.w3.org/2000/xmlns/')
        ..extendedQualified.equals('Q{http://www.w3.org/2000/xmlns/}bar')
        ..asString.equals('xmlns:bar');
    });
    test('XmlName.namespace without name', () {
      check(const XmlName.namespace())
        ..qualified.equals('xmlns')
        ..prefix.isNull()
        ..local.equals('xmlns')
        ..namespaceUri.equals('http://www.w3.org/2000/xmlns/')
        ..extendedQualified.equals('Q{http://www.w3.org/2000/xmlns/}xmlns')
        ..asString.equals('xmlns');
    });
  });
  group('XmlName.qualified', () {
    test('XmlName.qualified without prefix', () {
      check(const XmlName.qualified('bar', namespaceUri: namespaceUri))
        ..qualified.equals('bar')
        ..prefix.isNull()
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('bar');
    });
    test('XmlName.qualified with prefix', () {
      check(const XmlName.qualified('foo:bar', namespaceUri: namespaceUri))
        ..qualified.equals('foo:bar')
        ..prefix.equals('foo')
        ..local.equals('bar')
        ..namespaceUri.equals(namespaceUri)
        ..extendedQualified.equals('Q{$namespaceUri}bar')
        ..asString.equals('foo:bar');
    });
  });
  group('comparison', () {
    const original = XmlName.qualified('foo:bar', namespaceUri: namespaceUri);
    const differentPrefix = XmlName.qualified(
      'zork:bar',
      namespaceUri: namespaceUri,
    );
    const noNamespace = XmlName.qualified('foo:bar');
    const differentNamespace = XmlName.qualified(
      'foo:bar',
      namespaceUri: 'something',
    );
    test('self comparison', () {
      check(original == original).isTrue();
      check(differentPrefix == differentPrefix).isTrue();
      check(noNamespace == noNamespace).isTrue();
      check(differentNamespace == differentNamespace).isTrue();
    });
    test('different prefix', () {
      check(original == differentPrefix).isTrue();
      check(differentPrefix == original).isTrue();
      check(original.hashCode == differentPrefix.hashCode).isTrue();
    });
    test('no namespace', () {
      check(original == noNamespace).isFalse();
      check(noNamespace == original).isFalse();
      check(original.hashCode == noNamespace.hashCode).isFalse();
    });
    test('different namespace', () {
      check(original == differentNamespace).isFalse();
      check(differentNamespace == original).isFalse();
      check(original.hashCode == differentNamespace.hashCode).isFalse();
    });
  });
}
