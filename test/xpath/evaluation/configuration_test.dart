import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xpath/evaluation/namespaces.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

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

final XPathFunction fun1 = ((
  XPathContext context,
  List<XPathSequence> args,
) => XPathSequence.empty).toXPathFunction(arity: 0);
final XPathFunction fun2 = ((
  XPathContext context,
  List<XPathSequence> args,
) => XPathSequence.empty).toXPathFunction(arity: 0);

void trace1(XPathSequence value, String? label) {}
void trace2(XPathSequence value, String? label) {}

String? textLoader1(String uri, String? encoding) => 'text1';
String? textLoader2(String uri, String? encoding) => 'text2';

void main() {
  group('constructor', () {
    test('default', () {
      final context = XPathConfiguration();
      check(context.variables).equals(standard.variables);
      check(context.functions).equals(standard.functions);
      check(context.namespaceUri).equals(standard.namespaceUri);
      check(context.namespaceUris).equals(standard.namespaceUris);
      check(context.documents).equals(standard.documents);
      check(context.environment).equals(standard.environment);
      check(context.baseUri).equals(standard.baseUri);
      check(context.unparsedTextLoader).equals(standard.unparsedTextLoader);
      check(context.onTraceCallback).equals(standard.onTraceCallback);
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
      check(context.variables).deepEquals({
        ...standard.variables,
        'var': XPathSequence.fromObject(42),
      });
      check(context.functions).deepEquals({...standard.functions, name1: fun1});
      check(context.namespaceUri).equals('namespaceUri');
      check(context.namespaceUris)
          .deepEquals({...standard.namespaceUris, 'ns': 'uri'});
      check(context.documents)
          .deepEquals({...standard.documents, 'doc': document});
      check(context.environment)
          .deepEquals({...standard.environment, 'env': 'value'});
      check(context.baseUri).equals('baseUri');
      check(context.unparsedTextLoader).equals(textLoader1);
      check(context.onTraceCallback).equals(trace1);
    });
    test('standard', () {
      final context = XPathConfiguration.standard();
      check(context).identicalTo(standard);
      check(context.variables).isEmpty();
      check(context.functions).isNotEmpty();
      check(context.namespaceUri).equals(xpathFnNamespace);
      check(context.namespaceUris).equals(xpathNamespaceUris);
      check(context.documents).isEmpty();
      check(context.environment).isEmpty();
      check(context.baseUri).isNull();
      check(context.unparsedTextLoader).isNull();
      check(context.onTraceCallback).isNull();
    });
    test('raw', () {
      final context = XPathConfiguration.raw(
        variables: {'var': XPathSequence.fromObject(42)},
        functions: {name1: fun1},
        namespaceUri: 'namespaceUri',
        namespaceUris: {'ns': 'uri'},
        documents: {'doc': document},
        environment: {'env': 'value'},
        baseUri: 'baseUri',
        unparsedTextLoader: textLoader1,
        onTraceCallback: trace1,
      );
      check(context.variables)
          .deepEquals({'var': XPathSequence.fromObject(42)});
      check(context.functions).deepEquals({name1: fun1});
      check(context.namespaceUri).equals('namespaceUri');
      check(context.namespaceUris).deepEquals({'ns': 'uri'});
      check(context.documents).deepEquals({'doc': document});
      check(context.environment).deepEquals({'env': 'value'});
      check(context.baseUri).equals('baseUri');
      check(context.unparsedTextLoader).equals(textLoader1);
      check(context.onTraceCallback).equals(trace1);
    });
  });
  test('getFunction', () {
    final staticContext = XPathConfiguration(
      functions: {name1: fun1, name2: fun2},
    );
    check(staticContext.getFunction(name1)).equals(fun1);
    check(staticContext.getFunction(name2)).equals(fun2);
    check(() => staticContext.getFunction(const XmlName.qualified('other')))
        .throws<XPathEvaluationException>()
        .which(isXPathEvaluationException(message: 'Unknown function: other'));
    check(() => standard.getFunctionByString('round', 5))
        .throws<XPathEvaluationException>()
        .which(
          isXPathEvaluationException(
            message: 'Function "round" does not support arity 5 [err:XPST0017]',
          ),
        );
  });
  test('getFunctionByString', () {
    final staticContext = XPathConfiguration(
      functions: {name1: fun1, name2: fun2},
    );
    check(staticContext.getFunctionByString('fun1')).equals(fun1);
    check(staticContext.getFunctionByString('fn:fun1')).equals(fun1);
    check(staticContext.getFunctionByString('array:fun2')).equals(fun2);
    check(() => staticContext.getFunctionByString('fun2'))
        .throws<XPathEvaluationException>()
        .which(isXPathEvaluationException(message: 'Unknown function: fun2'));
  });
  group('context', () {
    test('default', () {
      final context = standard.context();
      check(context.item).isA<XPathSequence>().isEmpty();
      check(context.configuration).identicalTo(standard);
    });
    test('context', () {
      final context = standard.context(document);
      check(context.item).equals(XPathNode(document));
      check(context.configuration).identicalTo(standard);
    });
    test('evaluate', () {
      final result = standard.context().evaluate('1 + 2');
      check(result).isXPathSequence([3]);
    });
  });
  group('copy', () {
    final base = XPathConfiguration.raw(
      variables: {'var1': XPathSequence.fromObject(41)},
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
      check(copy.variables).deepEquals({'var1': XPathSequence.fromObject(41)});
      check(copy.functions).deepEquals({name1: fun1});
      check(copy.namespaceUri).equals('namespaceUri1');
      check(copy.namespaceUris).deepEquals({'ns1': 'uri1'});
      check(copy.documents).deepEquals({'doc1': document});
      check(copy.environment).deepEquals({'env1': 'value1'});
      check(copy.baseUri).equals('baseUri1');
      check(copy.unparsedTextLoader).equals(textLoader1);
      check(copy.onTraceCallback).equals(trace1);
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
      check(copy.variables).deepEquals({
        'var1': XPathSequence.fromObject(41),
        'var2': XPathSequence.fromObject(42),
      });
      check(copy.functions).deepEquals({name1: fun1, name2: fun2});
      check(copy.namespaceUri).equals('namespaceUri2');
      check(copy.namespaceUris).deepEquals({'ns1': 'uri1', 'ns2': 'uri2'});
      check(copy.documents).deepEquals({'doc1': document, 'doc2': document});
      check(copy.environment).deepEquals({'env1': 'value1', 'env2': 'value2'});
      check(copy.baseUri).equals('baseUri2');
      check(copy.unparsedTextLoader).equals(textLoader2);
      check(copy.onTraceCallback).equals(trace2);
    });
  });
}
