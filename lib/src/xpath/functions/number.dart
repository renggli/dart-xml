import '../exceptions/function_exception.dart';
import '../values.dart';

// number number(object?)
Value number(List<Value> args) {
  XPathFunctionException.checkArgumentCount('number', args, 1);
  return NumberValue(args[0].number);
}

// number sum(node-set)
Value sum(List<Value> args) {
  XPathFunctionException.checkArgumentCount('sum', args, 1);
  return NumberValue(args[0]
      .nodes
      .map((node) => num.tryParse(node.toXmlString()) ?? 0)
      .fold(0, (a, b) => a + b));
}

// number floor(number)
Value floor(List<Value> args) {
  XPathFunctionException.checkArgumentCount('floor', args, 1);
  return NumberValue(args[0].number.floor());
}

// number ceiling(number)
Value ceiling(List<Value> args) {
  XPathFunctionException.checkArgumentCount('ceiling', args, 1);
  return NumberValue(args[0].number.ceil());
}

// number round(number)
Value round(List<Value> args) {
  XPathFunctionException.checkArgumentCount('round', args, 1);
  final value = args[0].number;
  return NumberValue(value.isFinite ? value.round() : value);
}

// number -(number)
Value neg(List<Value> args) {
  XPathFunctionException.checkArgumentCount('-', args, 1);
  return NumberValue(-args[0].number);
}

// number +(number, number)
Value add(List<Value> args) {
  XPathFunctionException.checkArgumentCount('+', args, 2);
  return NumberValue(args[0].number + args[1].number);
}

// number -(number, number)
Value sub(List<Value> args) {
  XPathFunctionException.checkArgumentCount('-', args, 2);
  return NumberValue(args[0].number - args[1].number);
}

// number *(number, number)
Value mul(List<Value> args) {
  XPathFunctionException.checkArgumentCount('*', args, 2);
  return NumberValue(args[0].number * args[1].number);
}

// number div(number, number)
Value div(List<Value> args) {
  XPathFunctionException.checkArgumentCount('div', args, 2);
  return NumberValue(args[0].number / args[1].number);
}

// number div(number, number)
Value idiv(List<Value> args) {
  XPathFunctionException.checkArgumentCount('idiv', args, 2);
  return NumberValue(args[0].number ~/ args[1].number);
}

// number mod(number, number)
Value mod(List<Value> args) {
  XPathFunctionException.checkArgumentCount('mod', args, 2);
  return NumberValue(args[0].number % args[1].number);
}
