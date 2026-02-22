import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<root/>');
final element = document.rootElement;

const name1 = XmlName.parts(
  'fun1',
  prefix: 'fn',
  namespaceUri: xpathFnNamespace,
);
const name2 = XmlName.parts(
  'fun2',
  prefix: 'array',
  namespaceUri: xpathArrayNamespace,
);

XPathSequence fun1(XPathContext context, List<XPathSequence> args) =>
    XPathSequence.empty;
XPathSequence fun2(XPathContext context, List<XPathSequence> args) =>
    XPathSequence.empty;

void trace1(XPathSequence value, String? label) {}
void trace2(XPathSequence value, String? label) {}

void main() {
  test('empty', () {
    final context = XPathContext.empty(element);
    expect(context.item, same(element));
    expect(context.position, 1);
    expect(context.last, 1);
    expect(context.variables, isEmpty);
    expect(context.functions, isEmpty);
    expect(context.namespaceUri, isNull);
    expect(context.namespaceUris, isEmpty);
    expect(context.documents, isEmpty);
    expect(context.onTraceCallback, isNull);
  });
  test('canonical', () {
    final context = XPathContext.canonical(element);
    expect(context.item, same(element));
    expect(context.position, 1);
    expect(context.last, 1);
    expect(context.variables, isEmpty);
    expect(context.functions, standardFunctions);
    expect(context.namespaceUri, xpathFnNamespace);
    expect(context.namespaceUris, xpathNamespaceUris);
    expect(context.documents, isEmpty);
    expect(context.onTraceCallback, isNull);
  });
  test('getVariable', () {
    final context = XPathContext.empty(element, variables: {'var': 42});
    expect(context.getVariable('var'), same(42));
    expect(
      () => context.getVariable('other'),
      throwsA(isXPathEvaluationException(message: 'Unknown variable: other')),
    );
  });
  test('getFunction', () {
    final context = XPathContext.empty(
      element,
      functions: {name1: fun1, name2: fun2},
    );
    expect(context.getFunction(name1), fun1);
    expect(context.getFunction(name2), fun2);
    expect(
      () => context.getFunction(const XmlName.qualified('other')),
      throwsA(isXPathEvaluationException(message: 'Unknown function: other')),
    );
  });
  test('getFunctionByString', () {
    final context = XPathContext.empty(
      element,
      namespaceUri: xpathFnNamespace,
      namespaceUris: xpathNamespaceUris,
      functions: {name1: fun1, name2: fun2},
    );
    expect(context.getFunctionByString('fun1'), fun1);
    expect(context.getFunctionByString('fn:fun1'), fun1);
    expect(context.getFunctionByString('array:fun2'), fun2);
    expect(
      () => context.getFunctionByString('fun2'),
      throwsA(isXPathEvaluationException(message: 'Unknown function: fun2')),
    );
  });
  group('copy', () {
    final context = XPathContext.empty(
      element,
      variables: {'var1': 42},
      functions: {name1: fun1},
      namespaceUri: 'namespaceUri1',
      namespaceUris: {'ns1': 'uri1'},
      documents: {'doc1': document},
      onTraceCallback: trace1,
    );
    test('without overrides', () {
      final copy = context.copy();
      expect(copy, isNot(same(context)));
      expect(copy.item, same(context.item));
      expect(copy.position, same(context.position));
      expect(copy.last, same(context.last));
      expect(copy.variables, same(context.variables));
      expect(copy.functions, same(context.functions));
      expect(copy.documents, same(context.documents));
      expect(copy.namespaceUri, same(context.namespaceUri));
      expect(copy.namespaceUris, same(context.namespaceUris));
      expect(copy.onTraceCallback, same(context.onTraceCallback));
    });
    test('with overrides', () {
      final copy = context.copy(
        variables: {'var2': 43},
        functions: {name2: fun2},
        namespaceUri: 'namespaceUri2',
        namespaceUris: {'ns2': 'uri2'},
        documents: {'doc2': document},
        onTraceCallback: trace2,
      );
      expect(copy, isNot(same(context)));
      expect(copy.item, context.item);
      expect(copy.position, context.position);
      expect(copy.last, context.last);
      expect(copy.variables, {'var1': 42, 'var2': 43});
      expect(copy.functions, {name1: fun1, name2: fun2});
      expect(copy.documents, {'doc1': document, 'doc2': document});
      expect(copy.namespaceUri, 'namespaceUri2');
      expect(copy.namespaceUris, {'ns1': 'uri1', 'ns2': 'uri2'});
      expect(copy.onTraceCallback, same(trace2));
    });
  });
}
