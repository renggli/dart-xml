import '../exceptions/function_exception.dart';
import '../resolvers/operators.dart';
import '../values.dart';

// boolean boolean(object)
Value boolean(List<Value> args) {
  XPathFunctionException.checkArgumentCount('boolean', args, 1);
  return BooleanValue(args[0].boolean);
}

// boolean not(boolean)
Value not(List<Value> args) {
  XPathFunctionException.checkArgumentCount('not', args, 1);
  return BooleanValue(!args[0].boolean);
}

// boolean true()
Value trueValue(List<Value> args) {
  XPathFunctionException.checkArgumentCount('true', args, 0);
  return BooleanValue(true);
}

// boolean false()
Value falseValue(List<Value> args) {
  XPathFunctionException.checkArgumentCount('false', args, 0);
  return BooleanValue(false);
}

// boolean lang(string)
Value lang(List<Value> args) {
  XPathFunctionException.checkArgumentCount('lang', args, 1);
  throw UnimplementedError();
}

// boolean <(number, number)
Value lessThan(List<Value> args) {
  XPathFunctionException.checkArgumentCount('<', args, 2);
  return BooleanValue(args[0].number < args[1].number);
}

// boolean <=(number, number)
Value lessThanOrEqual(List<Value> args) {
  XPathFunctionException.checkArgumentCount('<=', args, 2);
  return BooleanValue(args[0].number <= args[1].number);
}

// boolean >(number, number)
Value greaterThan(List<Value> args) {
  XPathFunctionException.checkArgumentCount('>', args, 2);
  return BooleanValue(args[0].number > args[1].number);
}

// boolean >=(number, number)
Value greaterThanOrEqual(List<Value> args) {
  XPathFunctionException.checkArgumentCount('>=', args, 2);
  return BooleanValue(args[0].number >= args[1].number);
}

// boolean =(object, object)
Value equal(List<Value> args) {
  XPathFunctionException.checkArgumentCount('=', args, 2);
  return BooleanValue(args[0].string == args[1].string);
}

// boolean !=(object, object)
Value notEqual(List<Value> args) {
  XPathFunctionException.checkArgumentCount('!=', args, 2);
  return BooleanValue(args[0].string != args[1].string);
}

// boolean and(boolean, boolean)
Value and(List<Lazy<Value>> args) {
  XPathFunctionException.checkArgumentCount('and', args, 2);
  return BooleanValue(args[0]().boolean && args[1]().boolean);
}

// boolean or(boolean, boolean)
Value or(List<Lazy<Value>> args) {
  XPathFunctionException.checkArgumentCount('or', args, 2);
  return BooleanValue(args[0]().boolean || args[1]().boolean);
}
