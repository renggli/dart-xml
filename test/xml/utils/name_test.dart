import 'package:test/test.dart';
import 'package:xml/xml.dart';

const namespaceUri = 'http://example.com';

void main() {
  group('XmlName', () {
    test('qualified', () {
      const name = XmlName.qualified('foo', namespaceUri: namespaceUri);
      expect(name.qualified, 'foo');
      expect(name.prefix, isNull);
      expect(name.local, 'foo');
      expect(name.namespaceUri, namespaceUri);
      expect(name.toString(), 'foo');
    });
    test('qualified with prefix', () {
      const name = XmlName.qualified('foo:bar', namespaceUri: namespaceUri);
      expect(name.qualified, 'foo:bar');
      expect(name.prefix, 'foo');
      expect(name.local, 'bar');
      expect(name.namespaceUri, namespaceUri);
      expect(name.toString(), 'foo:bar');
    });
    test('parts without prefix', () {
      const name = XmlName.parts('foo', namespaceUri: namespaceUri);
      expect(name.qualified, 'foo');
      expect(name.prefix, isNull);
      expect(name.local, 'foo');
      expect(name.namespaceUri, namespaceUri);
      expect(name.toString(), 'foo');
    });
    test('parts with prefix', () {
      const name = XmlName.parts(
        'bar',
        namespacePrefix: 'foo',
        namespaceUri: namespaceUri,
      );
      expect(name.qualified, 'foo:bar');
      expect(name.prefix, 'foo');
      expect(name.local, 'bar');
      expect(name.namespaceUri, namespaceUri);
      expect(name.toString(), 'foo:bar');
    });
    test('default namespace', () {
      const name = XmlName.namespace();
      expect(name.qualified, 'xmlns');
      expect(name.prefix, isNull);
      expect(name.local, 'xmlns');
      expect(name.namespaceUri, 'http://www.w3.org/2000/xmlns/');
      expect(name.toString(), 'xmlns');
    });
    test('namespace', () {
      const name = XmlName.namespace(name: 'foo');
      expect(name.qualified, 'xmlns:foo');
      expect(name.prefix, 'xmlns');
      expect(name.local, 'foo');
      expect(name.namespaceUri, 'http://www.w3.org/2000/xmlns/');
      expect(name.toString(), 'xmlns:foo');
    });
    test('standard constructor (deprecated)', () {
      // ignore: deprecated_member_use_from_same_package
      const name = XmlName('foo');
      expect(name.qualified, 'foo');
      expect(name.prefix, isNull);
      expect(name.local, 'foo');
      expect(name.namespaceUri, isNull);
      expect(name.toString(), 'foo');
    });
    test('standard constructor with prefix (deprecated)', () {
      // ignore: deprecated_member_use_from_same_package
      const name = XmlName('bar', 'foo');
      expect(name.qualified, 'foo:bar');
      expect(name.prefix, 'foo');
      expect(name.local, 'bar');
      expect(name.namespaceUri, isNull);
      expect(name.toString(), 'foo:bar');
    });
    test('XmlName.fromString', () {
      // ignore: deprecated_member_use_from_same_package
      const name = XmlName.fromString('foo');
      expect(name.qualified, 'foo');
      expect(name.prefix, isNull);
      expect(name.local, 'foo');
      expect(name.namespaceUri, isNull);
      expect(name.toString(), 'foo');
    });
    test('XmlName.fromString with prefix', () {
      // ignore: deprecated_member_use_from_same_package
      const name = XmlName.fromString('foo:bar');
      expect(name.qualified, 'foo:bar');
      expect(name.prefix, 'foo');
      expect(name.local, 'bar');
      expect(name.namespaceUri, isNull);
      expect(name.toString(), 'foo:bar');
    });
  });
}
