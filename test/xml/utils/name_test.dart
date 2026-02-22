import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

const namespaceUri = 'http://example.com';

void main() {
  test('XmlName.qualified without prefix', () {
    expect(
      const XmlName.qualified('bar', namespaceUri: namespaceUri),
      isXmlName(
        qualified: 'bar',
        prefix: isNull,
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.qualified with prefix', () {
    expect(
      const XmlName.qualified('foo:bar', namespaceUri: namespaceUri),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parts without prefix', () {
    expect(
      const XmlName.parts('bar', namespaceUri: namespaceUri),
      isXmlName(
        qualified: 'bar',
        prefix: isNull,
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parts with prefix', () {
    expect(
      const XmlName.parts('bar', prefix: 'foo', namespaceUri: namespaceUri),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parse in extended form with prefix', () {
    expect(
      XmlName.parse('Q{$namespaceUri}foo:bar'),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parse in extended form without prefix', () {
    expect(
      XmlName.parse('Q{$namespaceUri}bar'),
      isXmlName(
        qualified: 'bar',
        prefix: isNull,
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parse with empty extended form', () {
    expect(
      XmlName.parse('Q{}bar'),
      isXmlName(
        qualified: 'bar',
        prefix: isNull,
        local: 'bar',
        namespaceUri: isNull,
        extendedQualified: 'bar',
      ),
    );
  });
  test('XmlName.parse with invalid extended form', () {
    expect(() => XmlName.parse('Q{bar'), throwsA(isA<XmlParserException>()));
  });
  test('XmlName.parse with prefix and namespace map', () {
    expect(
      XmlName.parse('foo:bar', namespaceUris: const {'foo': namespaceUri}),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.parse with prefix and default namespace', () {
    expect(
      XmlName.parse('foo:bar', namespaceUri: namespaceUri),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: namespaceUri,
        extendedQualified: 'Q{$namespaceUri}bar',
      ),
    );
  });
  test('XmlName.namespace with name', () {
    expect(
      const XmlName.namespace(name: 'bar'),
      isXmlName(
        qualified: 'xmlns:bar',
        prefix: 'xmlns',
        local: 'bar',
        namespaceUri: 'http://www.w3.org/2000/xmlns/',
        extendedQualified: 'Q{http://www.w3.org/2000/xmlns/}bar',
      ),
    );
  });
  test('XmlName.namespace without name', () {
    expect(
      const XmlName.namespace(),
      isXmlName(
        qualified: 'xmlns',
        prefix: isNull,
        local: 'xmlns',
        namespaceUri: 'http://www.w3.org/2000/xmlns/',
        extendedQualified: 'Q{http://www.w3.org/2000/xmlns/}xmlns',
      ),
    );
  });
  test('XmlName (deprecated)', () {
    // ignore: deprecated_member_use_from_same_package
    expect(
      const XmlName('foo'),
      isXmlName(
        qualified: 'foo',
        prefix: isNull,
        local: 'foo',
        namespaceUri: isNull,
        extendedQualified: 'foo',
      ),
    );
  });
  test('XmlName with prefix (deprecated)', () {
    // ignore: deprecated_member_use_from_same_package
    expect(
      const XmlName('bar', 'foo'),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: isNull,
        extendedQualified: 'foo:bar',
      ),
    );
  });
  test('XmlName.fromString (deprecated)', () {
    // ignore: deprecated_member_use_from_same_package
    expect(
      const XmlName.fromString('foo'),
      isXmlName(
        qualified: 'foo',
        prefix: isNull,
        local: 'foo',
        namespaceUri: isNull,
        extendedQualified: 'foo',
      ),
    );
  });
  test('XmlName.fromString with prefix (deprecated)', () {
    // ignore: deprecated_member_use_from_same_package
    expect(
      const XmlName.fromString('foo:bar'),
      isXmlName(
        qualified: 'foo:bar',
        prefix: 'foo',
        local: 'bar',
        namespaceUri: isNull,
        extendedQualified: 'foo:bar',
      ),
    );
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
      expect(original == original, isTrue);
      expect(differentPrefix == differentPrefix, isTrue);
      expect(noNamespace == noNamespace, isTrue);
      expect(differentNamespace == differentNamespace, isTrue);
    });
    test('different prefix', () {
      expect(original == differentPrefix, isTrue);
      expect(differentPrefix == original, isTrue);
      expect(original.hashCode == differentPrefix.hashCode, isTrue);
    });
    test('no namespace', () {
      expect(original == noNamespace, isFalse);
      expect(noNamespace == original, isFalse);
      expect(original.hashCode == noNamespace.hashCode, isFalse);
    });
    test('different namespace', () {
      expect(original == differentNamespace, isFalse);
      expect(differentNamespace == original, isFalse);
      expect(original.hashCode == differentNamespace.hashCode, isFalse);
    });
  });
}
