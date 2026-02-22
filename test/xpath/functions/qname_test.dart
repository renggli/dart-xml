import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/qname.dart';

import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r xmlns:p="uri"><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  test('fn:namespace-uri-for-prefix', () {
    expect(
      () => fnNamespaceUriForPrefix(context, [
        XPathSequence.empty,
        XPathSequence.single(document),
      ]),
      throwsA(
        isXPathEvaluationException(
          message:
              'Unsupported cast from <r xmlns:p="uri"><a>1</a><b>2</b></r> to element',
        ),
      ),
    );
  });
  test('fn:resolve-QName', () {
    expect(
      fnResolveQName(context, [
        const XPathSequence.single('p:local'),
        XPathSequence.single(document.rootElement),
      ]),
      isXPathSequence([isA<XmlName>()]),
    );
  });
  test('fn:QName', () {
    expect(
      fnQName(context, [
        const XPathSequence.single('uri'),
        const XPathSequence.single('p:local'),
      ]),
      isXPathSequence([isA<XmlName>()]),
    );
  });
  test('fn:prefix-from-QName', () {
    const qname = XmlName.qualified('p:local');
    expect(
      fnPrefixFromQName(context, [const XPathSequence.single(qname)]),
      isXPathSequence(['p']),
    );
  });
  test('fn:local-name-from-qname', () {
    const qname = XmlName.qualified('p:local');
    expect(
      fnLocalNameFromQName(context, [const XPathSequence.single(qname)]),
      isXPathSequence(['local']),
    );
  });
  test('fn:namespace-uri-from-QName', () {
    const qname = XmlName.qualified('p:local');
    expect(
      fnNamespaceUriFromQName(context, [const XPathSequence.single(qname)]),
      isXPathSequence(isEmpty),
    );
  });
  test('fn:in-scope-prefixes', () {
    expect(
      () => fnInScopePrefixes(context, [XPathSequence.single(document)]),
      throwsA(
        isXPathEvaluationException(
          message:
              'Unsupported cast from <r xmlns:p="uri"><a>1</a><b>2</b></r> to element',
        ),
      ),
    );
  });
}
