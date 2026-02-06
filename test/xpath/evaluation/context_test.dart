import 'package:test/test.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/types.dart';

final document = XmlDocument.parse('<root><node/></root>');
final node = document.rootElement;

const variable = XPathSequence.single('value');
XPathSequence function(XPathContext context, List<XPathSequence> args) =>
    XPathSequence.empty;
void trace(XPathSequence value, XPathString? label) {}

void main() {
  final context = XPathContext(node);

  test('defaults', () {
    expect(context.item, same(node));
    expect(context.position, 1);
    expect(context.last, 1);
    expect(context.variables, isEmpty);
    expect(context.functions, isEmpty);
    expect(context.documents, isEmpty);
    expect(context.onTraceCallback, isNull);
  });
  test('getVariable', () {
    final context = XPathContext(node, variables: {'var': variable});
    expect(context.getVariable('var'), same(variable));
    expect(context.getVariable('other'), isNull);
  });
  test('getFunction', () {
    final context = XPathContext(node, functions: {'fun': function});
    expect(context.getFunction('fun'), same(function));
    expect(context.getFunction('other'), isNull);
  });
  test('copy', () {
    final copy = context.copy(
      variables: {'var': variable},
      functions: {'fun': function},
      documents: {'doc': document},
      onTraceCallback: trace,
    );
    expect(copy.item, same(node));
    expect(copy.position, 1);
    expect(copy.last, 1);
    expect(copy.variables, {'var': variable});
    expect(copy.functions, {'fun': function});
    expect(copy.documents, {'doc': document});
    expect(copy.onTraceCallback, same(trace));
  });
  test('copy with defaults', () {
    final copy = context.copy();
    expect(copy.item, same(context.item));
    expect(copy.position, context.position);
    expect(copy.last, context.last);
    expect(copy.variables, same(context.variables));
    expect(copy.functions, same(context.functions));
    expect(copy.documents, same(context.documents));
    expect(copy.onTraceCallback, same(context.onTraceCallback));
  });
}
