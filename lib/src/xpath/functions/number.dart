import '../evaluation/context.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// number number(object?)
XPathValue number(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('number', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0];
  return XPathNumber(value.number);
}

// number sum(node-set)
XPathValue sum(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('sum', arguments, 1);
  return XPathNumber(
    arguments[0].nodes
        .map((node) => num.tryParse(XPathNodeSet.single(node).string) ?? 0)
        .fold(0, (a, b) => a + b),
  );
}

// number abs(number)
XPathValue abs(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('abs', arguments, 1);
  return XPathNumber(arguments[0].number.abs());
}

// number floor(number)
XPathValue floor(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('floor', arguments, 1);
  return XPathNumber(arguments[0].number.floor());
}

// number ceiling(number)
XPathValue ceiling(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('ceiling', arguments, 1);
  return XPathNumber(arguments[0].number.ceil());
}

// number round(number)
XPathValue round(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('round', arguments, 1);
  final value = arguments[0].number;
  return XPathNumber(value.isFinite ? value.round() : value);
}

// number -(number)
XPathValue neg(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('-', arguments, 1);
  return XPathNumber(-arguments[0].number);
}

// number +(number, number)
XPathValue add(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('+', arguments, 2);
  return XPathNumber(arguments[0].number + arguments[1].number);
}

// number -(number, number)
XPathValue sub(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('-', arguments, 2);
  return XPathNumber(arguments[0].number - arguments[1].number);
}

// number *(number, number)
XPathValue mul(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('*', arguments, 2);
  return XPathNumber(arguments[0].number * arguments[1].number);
}

// number div(number, number)
XPathValue div(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('div', arguments, 2);
  return XPathNumber(arguments[0].number / arguments[1].number);
}

// number div(number, number)
XPathValue idiv(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('idiv', arguments, 2);
  return XPathNumber(arguments[0].number ~/ arguments[1].number);
}

// number mod(number, number)
XPathValue mod(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('mod', arguments, 2);
  return XPathNumber(arguments[0].number % arguments[1].number);
}
