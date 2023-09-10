import 'dart:math' as math;

import 'package:petitparser/parser.dart' show unbounded;

import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';
import '../exceptions/evaluation_exception.dart';

// string string(object?)
XPathValue string(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('string', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return XPathString(value.string);
}

// string concat(string, string, string*)
XPathValue concat(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount(
      'concat', arguments, 2, unbounded);
  final result = arguments.map((each) => each(context).string);
  return XPathString(result.join());
}

// boolean starts-with(string, string)
XPathValue startsWith(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('starts-with', arguments, 2);
  final string = arguments[0](context).string;
  final pattern = arguments[1](context).string;
  return XPathBoolean(string.startsWith(pattern));
}

// boolean contains(string, string)
XPathValue contains(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('contains', arguments, 2);
  final string = arguments[0](context).string;
  final pattern = arguments[1](context).string;
  return XPathBoolean(string.contains(pattern));
}

// string substring-before(string, string)
XPathValue substringBefore(
    XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('substring-before', arguments, 2);
  final string = arguments[0](context).string;
  final index = string.indexOf(arguments[1](context).string);
  return XPathString(index >= 0 ? string.substring(0, index) : '');
}

// string substring-after(string, string)
XPathValue substringAfter(
    XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('substring-after', arguments, 2);
  final string = arguments[0](context).string;
  final index = string.indexOf(arguments[1](context).string);
  return XPathString(index >= 0 ? string.substring(index + 1) : '');
}

// string substring(string, number, number?)
XPathValue substring(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('substring', arguments, 2, 3);
  final string = arguments[0](context).string;
  final start_ = arguments[1](context).number;
  if (!start_.isFinite) return XPathString.empty;
  final start = start_.round() - 1;
  final end_ =
      arguments.length > 2 ? arguments[2](context).number : double.infinity;
  if (end_.isNaN || end_ <= 0) return XPathString.empty;
  final end = end_.isFinite ? start + end_.round() : string.length;
  return XPathString(string.substring(
    math.min(math.max(0, start), string.length),
    math.min(math.max(start, end), string.length),
  ));
}

// number string-length(string?)
XPathValue stringLength(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('string-length', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return XPathNumber(value.string.length);
}

// string normalize-space(string?)
XPathValue normalizeSpace(
    XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount(
      'normalize-space', arguments, 0, 1);
  final value = arguments.isEmpty ? context.value : arguments[0](context);
  return XPathString(value.string.trim().replaceAll(_whitespace, ' '));
}

final _whitespace = RegExp(r'\s+', multiLine: true);

// string translate(string, string, string)
XPathValue translate(XPathContext context, List<XPathExpression> arguments) {
  XPathEvaluationException.checkArgumentCount('translate', arguments, 3);
  final input = arguments[0](context).string;
  final sourceChars = arguments[1](context).string;
  final targetChars = arguments[2](context).string;
  final mapping = {
    for (var i = 0; i < sourceChars.length; i++)
      sourceChars[i]: i < targetChars.length ? targetChars[i] : ''
  };
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    buffer.write(mapping[input[i]] ?? input[i]);
  }
  return XPathString(buffer.toString());
}
