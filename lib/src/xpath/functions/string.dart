import 'dart:math' as math;

import 'package:petitparser/parser.dart' show unbounded;

import '../exceptions/function_exception.dart';
import '../values.dart';

// string string(object?)
Value string(List<Value> args) {
  XPathFunctionException.checkArgumentCount('string', args, 1);
  return StringValue(args[0].string);
}

// string concat(string, string, string*)
Value concat(List<Value> args) {
  XPathFunctionException.checkArgumentCount('concat', args, 2, unbounded);
  return StringValue(args.map((each) => each.string).join());
}

// boolean starts-with(string, string)
Value startsWith(List<Value> args) {
  XPathFunctionException.checkArgumentCount('starts-with', args, 2);
  return BooleanValue(args[0].string.startsWith(args[1].string));
}

// boolean contains(string, string)
Value contains(List<Value> args) {
  XPathFunctionException.checkArgumentCount('contains', args, 2);
  return BooleanValue(args[0].string.contains(args[1].string));
}

// string substring-before(string, string)
Value substringBefore(List<Value> args) {
  XPathFunctionException.checkArgumentCount('substring-before', args, 2);
  final string = args[0].string;
  final index = string.indexOf(args[1].string);
  return StringValue(index >= 0 ? string.substring(0, index) : '');
}

// string substring-after(string, string)
Value substringAfter(List<Value> args) {
  XPathFunctionException.checkArgumentCount('substring-after', args, 2);
  final string = args[0].string;
  final index = string.indexOf(args[1].string);
  return StringValue(index >= 0 ? string.substring(index + 1) : '');
}

// string substring(string, number, number?)
Value substring(List<Value> args) {
  XPathFunctionException.checkArgumentCount('substring', args, 2, 3);
  final string = args[0].string, start_ = args[1].number;
  if (!start_.isFinite) return const StringValue('');
  final start = start_.round() - 1;
  final end_ = args.length > 2 ? args[2].number : double.infinity;
  if (end_.isNaN || end_ <= 0) return const StringValue('');
  final end = end_.isFinite ? start + end_.round() : string.length;
  return StringValue(string.substring(
    math.min(math.max(0, start), string.length),
    math.min(math.max(start, end), string.length),
  ));
}

// number string-length(string?)
Value stringLength(List<Value> args) {
  XPathFunctionException.checkArgumentCount('string-length', args, 1);
  return NumberValue(args[0].string.length);
}

// string normalize-space(string?)
Value normalizeSpace(List<Value> args) {
  XPathFunctionException.checkArgumentCount('normalize-space', args, 1);
  final whitespace = RegExp(r'\s+', multiLine: true);
  return StringValue(args[0].string.trim().replaceAll(whitespace, ' '));
}

// string translate(string, string, string)
Value translate(List<Value> args) {
  XPathFunctionException.checkArgumentCount('translate', args, 3);
  final input = args[0].string;
  final sourceChars = args[1].string;
  final targetChars = args[2].string;
  final mapping = {
    for (var i = 0; i < sourceChars.length; i++)
      sourceChars[i]: i < targetChars.length ? targetChars[i] : ''
  };
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    buffer.write(mapping[input[i]] ?? input[i]);
  }
  return StringValue(buffer.toString());
}
