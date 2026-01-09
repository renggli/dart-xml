import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/extensions/string.dart';
import '../../xml/mixins/has_name.dart';
import '../evaluation/context.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// number last()
XPathValue last(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('last', arguments, 0);
  return XPathNumber(context.last);
}

// number position()
XPathValue position(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('position', arguments, 0);
  return XPathNumber(context.position);
}

// number count(node-set)
XPathValue count(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('count', arguments, 1);
  return XPathNumber(arguments[0].nodes.length);
}

// node-set id(object)
XPathValue id(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('id', arguments, 1);
  final object = arguments[0];
  final ids = object is XPathNodeSet
      ? object.nodes.map((node) => node.innerText).toSet()
      : object.string.split(' ').toSet();
  if (ids.isEmpty) return XPathNodeSet.empty;
  // This should likely consult the DTD about the ID attribute ...
  return XPathNodeSet(
    context.node.root.descendantElements
        .where((element) => ids.contains(element.getAttribute('id')))
        .toList(),
  );
}

// string local-name(node-set?)
XPathValue localName(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('local-name', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0];
  return switch (value.nodes.firstOrNull) {
    XmlHasName(localName: final value) => XPathString(value),
    _ => XPathString.empty,
  };
}

// string namespace-uri(node-set?)
XPathValue namespaceUri(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('namespace-uri', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0];
  return switch (value.nodes.firstOrNull) {
    XmlHasName(namespaceUri: final value?) => XPathString(value),
    _ => XPathString.empty,
  };
}

// string name(node-set?)
XPathValue name(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('name', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0];
  return switch (value.nodes.firstOrNull) {
    XmlHasName(qualifiedName: final value) => XPathString(value),
    _ => XPathString.empty,
  };
}

// node-set intersect(node-set, node-set)
XPathValue intersect(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('intersect', arguments, 2);
  final a = arguments[0].nodes, b = arguments[1].nodes;
  return XPathNodeSet(a.toSet().intersection(b.toSet()).toList());
}

// node-set except(node-set, node-set)
XPathValue except(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('except', arguments, 2);
  final a = arguments[0].nodes, b = arguments[1].nodes;
  return XPathNodeSet((a.toSet()..removeAll(b)).toList());
}

// node-set union(node-set, node-set)
XPathValue union(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('union', arguments, 2);
  final a = arguments[0].nodes, b = arguments[1].nodes;
  return XPathNodeSet.fromIterable(a.toSet()..addAll(b), isUnique: true);
}
