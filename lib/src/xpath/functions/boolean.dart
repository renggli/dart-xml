import '../../../xml.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// boolean boolean(object?)
XPathValue boolean(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('boolean', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return XPathBoolean(value.boolean);
}

// boolean not(boolean)
XPathValue not(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('not', arguments, 1);
  return XPathBoolean(!arguments[0](context).boolean);
}

// boolean true()
XPathValue trueValue(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('true', arguments, 0);
  return const XPathBoolean(true);
}

// boolean false()
XPathValue falseValue(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('false', arguments, 0);
  return const XPathBoolean(false);
}

// boolean lang(string)
XPathValue lang(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('lang', arguments, 1);
  final lang = [context.node, ...context.node.ancestors]
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return const XPathBoolean(false);
  final argument = arguments[0](context).string.toLowerCase();
  return XPathBoolean(lang.toLowerCase().startsWith(argument));
}

// boolean <(number, number)
XPathValue lessThan(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('<', arguments, 2);
  return XPathBoolean(
      arguments[0](context).number < arguments[1](context).number);
}

// boolean <=(number, number)
XPathValue lessThanOrEqual(
    XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('<=', arguments, 2);
  return XPathBoolean(
      arguments[0](context).number <= arguments[1](context).number);
}

// boolean >(number, number)
XPathValue greaterThan(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('>', arguments, 2);
  return XPathBoolean(
      arguments[0](context).number > arguments[1](context).number);
}

// boolean >=(number, number)
XPathValue greaterThanOrEqual(
    XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('>=', arguments, 2);
  return XPathBoolean(
      arguments[0](context).number >= arguments[1](context).number);
}

// boolean =(object, object)
XPathValue equal(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('=', arguments, 2);
  return XPathBoolean(
      arguments[0](context).string == arguments[1](context).string);
}

// boolean !=(object, object)
XPathValue notEqual(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('!=', arguments, 2);
  return XPathBoolean(
      arguments[0](context).string != arguments[1](context).string);
}

// boolean and(boolean, boolean)
XPathValue and(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('and', arguments, 2);
  return XPathBoolean(
      arguments[0](context).boolean && arguments[1](context).boolean);
}

// boolean or(boolean, boolean)
XPathValue or(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('or', arguments, 2);
  return XPathBoolean(
      arguments[0](context).boolean || arguments[1](context).boolean);
}
