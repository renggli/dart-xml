import '../../xml/mixins/has_name.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// number last()
XPathValue last(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('last', arguments, 0);
  return XPathNumber(context.last);
}

// number position()
XPathValue position(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('position', arguments, 0);
  return XPathNumber(context.position);
}

// number count(node-set)
XPathValue count(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('count', arguments, 1);
  return XPathNumber(arguments[0](context).nodes.length);
}

// node-set id(object)
XPathValue id(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('id', arguments, 1);
  throw UnimplementedError('id');
}

// string local-name(node-set?)
XPathValue localName(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('local-name', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return switch (value.nodes.firstOrNull) {
    XmlHasName(localName: final value) => XPathString(value),
    _ => XPathString.empty,
  };
}

// string namespace-uri(node-set?)
XPathValue namespaceUri(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('namespace-uri', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return switch (value.nodes.firstOrNull) {
    XmlHasName(namespaceUri: final value!) => XPathString(value),
    _ => XPathString.empty,
  };
}

// string name(node-set?)
XPathValue name(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('name', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return switch (value.nodes.firstOrNull) {
    XmlHasName(qualifiedName: final value) => XPathString(value),
    _ => XPathString.empty,
  };
}

// node-set intersect(node-set, node-set)
XPathValue intersect(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('intersect', arguments, 2);
  throw UnimplementedError('intersect');
}

// node-set union(node-set, node-set)
XPathValue union(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('union', arguments, 2);
  throw UnimplementedError('union');
}
