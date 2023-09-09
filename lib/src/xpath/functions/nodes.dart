import '../../xml/mixins/has_name.dart';
import '../exceptions/function_exception.dart';
import '../values.dart';

// number last()
Value last(List<Value> args) {
  XPathFunctionException.checkArgumentCount('last', args, 0);
  throw UnimplementedError();
}

// number position()
Value position(List<Value> args) {
  XPathFunctionException.checkArgumentCount('position', args, 0);
  throw UnimplementedError();
}

// number count(node-set)
Value count(List<Value> args) {
  XPathFunctionException.checkArgumentCount('count', args, 1);
  return NumberValue(args[0].nodes.length);
}

// node-set id(object)
Value id(List<Value> args) {
  XPathFunctionException.checkArgumentCount('id', args, 1);
  throw UnimplementedError();
}

// string local-name(node-set?)
Value localName(List<Value> args) {
  XPathFunctionException.checkArgumentCount('local-name', args, 1);
  final node = args[0].nodes.firstOrNull;
  return StringValue(node is XmlHasName ? (node as XmlHasName).localName : '');
}

// string namespace-uri(node-set?)
Value namespaceUri(List<Value> args) {
  XPathFunctionException.checkArgumentCount('namespace-uri', args, 1);
  final node = args[0].nodes.firstOrNull;
  return StringValue(
      node is XmlHasName ? (node as XmlHasName).namespaceUri ?? '' : '');
}

// string name(node-set?)
Value name(List<Value> args) {
  XPathFunctionException.checkArgumentCount('name', args, 1);
  final node = args[0].nodes.firstOrNull;
  return StringValue(
      node is XmlHasName ? (node as XmlHasName).qualifiedName : '');
}

// node-set intersect(node-set, node-set)
Value intersect(List<Value> args) {
  XPathFunctionException.checkArgumentCount('intersect', args, 2);
  throw UnimplementedError();
}

// node-set union(node-set, node-set)
Value union(List<Value> args) {
  XPathFunctionException.checkArgumentCount('union', args, 2);
  throw UnimplementedError();
}
