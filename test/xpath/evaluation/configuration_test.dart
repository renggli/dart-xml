import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/src/xpath/types/function.dart';
import 'package:xml/src/xpath/types/sequence.dart';

import '../../utils/matchers.dart';

final standard = XPathConfiguration.standard();

final document = XmlDocument.parse('<root/>');

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

final XPathFunction fun1 =
    ((XPathContext context, List<XPathSequence> args) => XPathSequence.empty)
        .toXPathFunction(arity: 0);
final XPathFunction fun2 =
    ((XPathContext context, List<XPathSequence> args) => XPathSequence.empty)
        .toXPathFunction(arity: 0);

void trace1(XPathSequence value, String? label) {}
void trace2(XPathSequence value, String? label) {}

String? textLoader1(String uri, String? encoding) => 'text1';
String? textLoader2(String uri, String? encoding) => 'text2';

void main() {
  group('constructor', () {
    test('default', () {
      final context = XPathConfiguration();
      expect(context.variables, standard.variables);
      expect(context.functions, standard.functions);
      expect(context.namespaceUri, standard.namespaceUri);
      expect(context.namespaceUris, standard.namespaceUris);
      expect(context.documents, standard.documents);
      expect(context.environment, standard.environment);
      expect(context.baseUri, standard.baseUri);
      expect(context.unparsedTextLoader, standard.unparsedTextLoader);
      expect(context.onTraceCallback, standard.onTraceCallback);
    });
    test('custom', () {
      final context = XPathConfiguration(
        variables: const {'var': 42},
        functions: {name1: fun1},
        namespaceUri: 'namespaceUri',
        namespaceUris: {'ns': 'uri'},
        documents: {'doc': document},
        environment: {'env': 'value'},
        baseUri: 'baseUri',
        unparsedTextLoader: textLoader1,
        onTraceCallback: trace1,
      );
      expect(context.variables, {...standard.variables, 'var': 42});
      expect(context.functions, {...standard.functions, name1: fun1});
      expect(context.namespaceUri, 'namespaceUri');
      expect(context.namespaceUris, {...standard.namespaceUris, 'ns': 'uri'});
      expect(context.documents, {...standard.documents, 'doc': document});
      expect(context.environment, {...standard.environment, 'env': 'value'});
      expect(context.baseUri, 'baseUri');
      expect(context.unparsedTextLoader, textLoader1);
      expect(context.onTraceCallback, trace1);
    });
    test('standard', () {
      final context = XPathConfiguration.standard();
      expect(context, same(standard));
      expect(context.variables, isEmpty);
      expect(context.functions, isNotEmpty);
      expect(context.namespaceUri, xpathFnNamespace);
      expect(context.namespaceUris, xpathNamespaceUris);
      expect(context.documents, isEmpty);
      expect(context.environment, isEmpty);
      expect(context.baseUri, isNull);
      expect(context.unparsedTextLoader, isNull);
      expect(context.onTraceCallback, isNull);
    });
    test('raw', () {
      final context = XPathConfiguration.raw(
        variables: {'var': 42},
        functions: {name1: fun1},
        namespaceUri: 'namespaceUri',
        namespaceUris: {'ns': 'uri'},
        documents: {'doc': document},
        environment: {'env': 'value'},
        baseUri: 'baseUri',
        unparsedTextLoader: textLoader1,
        onTraceCallback: trace1,
      );
      expect(context.variables, {'var': 42});
      expect(context.functions, {name1: fun1});
      expect(context.namespaceUri, 'namespaceUri');
      expect(context.namespaceUris, {'ns': 'uri'});
      expect(context.documents, {'doc': document});
      expect(context.environment, {'env': 'value'});
      expect(context.baseUri, 'baseUri');
      expect(context.unparsedTextLoader, textLoader1);
      expect(context.onTraceCallback, trace1);
    });
  });
  test('getFunction', () {
    final staticContext = XPathConfiguration(
      functions: {name1: fun1, name2: fun2},
    );
    expect(staticContext.getFunction(name1), fun1);
    expect(staticContext.getFunction(name2), fun2);
    expect(
      () => staticContext.getFunction(const XmlName.qualified('other')),
      throwsA(isXPathEvaluationException(message: 'Unknown function: other')),
    );
  });
  test('getFunctionByString', () {
    final staticContext = XPathConfiguration(
      functions: {name1: fun1, name2: fun2},
    );
    expect(staticContext.getFunctionByString('fun1'), fun1);
    expect(staticContext.getFunctionByString('fn:fun1'), fun1);
    expect(staticContext.getFunctionByString('array:fun2'), fun2);
    expect(
      () => staticContext.getFunctionByString('fun2'),
      throwsA(isXPathEvaluationException(message: 'Unknown function: fun2')),
    );
  });
  group('context', () {
    test('default', () {
      final context = standard.context();
      expect(context.item, isXPathSequence(isEmpty));
      expect(context.configuration, same(standard));
    });
    test('context', () {
      final context = standard.context(document);
      expect(context.item, same(document));
      expect(context.configuration, same(standard));
    });
    test('evaluate', () {
      final result = standard.context().evaluate('1 + 2');
      expect(result, isXPathSequence([3]));
    });
  });
  group('copy', () {
    final base = XPathConfiguration.raw(
      variables: {'var1': 41},
      functions: {name1: fun1},
      namespaceUri: 'namespaceUri1',
      namespaceUris: {'ns1': 'uri1'},
      documents: {'doc1': document},
      environment: {'env1': 'value1'},
      baseUri: 'baseUri1',
      unparsedTextLoader: textLoader1,
      onTraceCallback: trace1,
    );
    test('without overrides', () {
      final copy = base.copy();
      expect(copy.variables, {'var1': 41});
      expect(copy.functions, {name1: fun1});
      expect(copy.namespaceUri, 'namespaceUri1');
      expect(copy.namespaceUris, {'ns1': 'uri1'});
      expect(copy.documents, {'doc1': document});
      expect(copy.environment, {'env1': 'value1'});
      expect(copy.baseUri, 'baseUri1');
      expect(copy.unparsedTextLoader, textLoader1);
      expect(copy.onTraceCallback, trace1);
    });
    test('with overrides', () {
      final copy = base.copy(
        variables: {'var2': 42},
        functions: {name2: fun2},
        namespaceUri: 'namespaceUri2',
        namespaceUris: {'ns2': 'uri2'},
        documents: {'doc2': document},
        environment: {'env2': 'value2'},
        baseUri: 'baseUri2',
        unparsedTextLoader: textLoader2,
        onTraceCallback: trace2,
      );
      expect(copy.variables, {'var1': 41, 'var2': 42});
      expect(copy.functions, {name1: fun1, name2: fun2});
      expect(copy.namespaceUri, 'namespaceUri2');
      expect(copy.namespaceUris, {'ns1': 'uri1', 'ns2': 'uri2'});
      expect(copy.documents, {'doc1': document, 'doc2': document});
      expect(copy.environment, {'env1': 'value1', 'env2': 'value2'});
      expect(copy.baseUri, 'baseUri2');
      expect(copy.unparsedTextLoader, textLoader2);
      expect(copy.onTraceCallback, trace2);
    });
  });
}
