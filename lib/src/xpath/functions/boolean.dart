import 'package:petitparser/petitparser.dart' show unbounded;

import '../../xml/extensions/ancestors.dart';
import '../evaluation/context.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// boolean boolean(object?)
XPathValue boolean(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('boolean', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0];
  return XPathBoolean(value.boolean);
}

// boolean not(boolean)
XPathValue not(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('not', arguments, 1);
  return XPathBoolean(!arguments[0].boolean);
}

// boolean true()
XPathValue trueValue(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('true', arguments, 0);
  return const XPathBoolean(true);
}

// boolean false()
XPathValue falseValue(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('false', arguments, 0);
  return const XPathBoolean(false);
}

// boolean lang(string)
XPathValue lang(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('lang', arguments, 1);
  final lang = [context.node, ...context.node.ancestors]
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return const XPathBoolean(false);
  final argument = arguments[0].string.toLowerCase();
  return XPathBoolean(lang.toLowerCase().startsWith(argument));
}

// boolean <(number, number)
XPathValue lessThan(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('<', arguments, 2);
  return XPathBoolean(arguments[0].number < arguments[1].number);
}

// boolean <=(number, number)
XPathValue lessThanOrEqual(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('<=', arguments, 2);
  return XPathBoolean(arguments[0].number <= arguments[1].number);
}

// boolean >(number, number)
XPathValue greaterThan(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('>', arguments, 2);
  return XPathBoolean(arguments[0].number > arguments[1].number);
}

// boolean >=(number, number)
XPathValue greaterThanOrEqual(
  XPathContext context,
  List<XPathValue> arguments,
) {
  XPathEvaluationException.checkArgumentCount('>=', arguments, 2);
  return XPathBoolean(arguments[0].number >= arguments[1].number);
}

// boolean =(object, object)
XPathValue equal(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('=', arguments, 2);
  return XPathBoolean(arguments[0].string == arguments[1].string);
}

// boolean !=(object, object)
XPathValue notEqual(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('!=', arguments, 2);
  return XPathBoolean(arguments[0].string != arguments[1].string);
}

// boolean and(boolean, boolean, boolean*)
XPathValue and(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('and', arguments, 2, unbounded);
  return XPathBoolean(arguments.every((arg) => arg.boolean));
}

// boolean or(boolean, boolean, boolean*)
XPathValue or(XPathContext context, List<XPathValue> arguments) {
  XPathEvaluationException.checkArgumentCount('or', arguments, 2, unbounded);
  return XPathBoolean(arguments.any((arg) => arg.boolean));
}
