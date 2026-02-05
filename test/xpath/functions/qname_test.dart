import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/qname.dart';

import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:namespace-uri-for-prefix', () {
    expect(
      () => fnNamespaceUriForPrefix(context, [
        XPathSequence.empty,
        XPathSequence.single(document),
      ]),
      throwsA(isA<UnimplementedError>()),
    );
  });
  test('fn:resolve-QName', () {
    expect(
      fnResolveQName(context, [
        const XPathSequence.single('p:local'),
        const XPathSequence.single('element'),
      ]).first,
      isA<XmlName>(),
    );
  });
  test('fn:QName', () {
    expect(
      fnQName(context, [
        const XPathSequence.single('uri'),
        const XPathSequence.single('p:local'),
      ]).first,
      isA<XmlName>(),
    );
  });
  test('fn:prefix-from-QName', () {
    final qname = XmlName.fromString('p:local');
    expect(fnPrefixFromQName(context, [XPathSequence.single(qname)]), ['p']);
  });
  test('fn:local-name-from-qname', () {
    final qname = XmlName.fromString('p:local');
    expect(fnLocalNameFromQName(context, [XPathSequence.single(qname)]), [
      'local',
    ]);
  });
  test('fn:namespace-uri-from-QName', () {
    final qname = XmlName.fromString('p:local');
    expect(
      fnNamespaceUriFromQName(context, [XPathSequence.single(qname)]),
      isEmpty,
    );
  });
  test('fn:in-scope-prefixes', () {
    expect(
      () => fnInScopePrefixes(context, [XPathSequence.single(document)]),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
