import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-error
const fnError = XPathFunctionItem.overloaded(XmlName.qualified('fn:error'), {
  0: XPathFunctionItem.fn0(XmlName.qualified('fn:error'), _fnError0),
  1: XPathFunctionItem.fn1(XmlName.qualified('fn:error'), _fnError1),
  2: XPathFunctionItem.fn2(XmlName.qualified('fn:error'), _fnError2),
  3: XPathFunctionItem.fn3(XmlName.qualified('fn:error'), _fnError3),
});

XPathSequence _fnError0(XPathContext context) {
  throw XPathEvaluationException('');
}

XPathSequence _fnError1(XPathContext context, XPathSequence code) {
  final c = code.firstOrNull;
  final codeStr = c != null
      ? (c is XPathString ? c.value : c.stringValue)
      : null;
  final buffer = StringBuffer();
  if (codeStr != null) buffer.write(codeStr);
  throw XPathEvaluationException(buffer.toString());
}

XPathSequence _fnError2(
  XPathContext context,
  XPathSequence code,
  XPathSequence description,
) {
  final c = code.firstOrNull;
  final d = description.firstOrNull;
  final codeStr = c != null
      ? (c is XPathString ? c.value : c.stringValue)
      : null;
  final descStr = d != null
      ? (d is XPathString ? d.value : d.stringValue)
      : null;
  final buffer = StringBuffer();
  if (codeStr != null) buffer.write(codeStr);
  if (descStr != null) {
    if (buffer.isNotEmpty) buffer.write(': ');
    buffer.write(descStr);
  }
  throw XPathEvaluationException(buffer.toString());
}

XPathSequence _fnError3(
  XPathContext context,
  XPathSequence code,
  XPathSequence description,
  XPathSequence errorObject,
) {
  final c = code.firstOrNull;
  final d = description.firstOrNull;
  final codeStr = c != null
      ? (c is XPathString ? c.value : c.stringValue)
      : null;
  final descStr = d != null
      ? (d is XPathString ? d.value : d.stringValue)
      : null;
  final buffer = StringBuffer();
  if (codeStr != null) buffer.write(codeStr);
  if (descStr != null) {
    if (buffer.isNotEmpty) buffer.write(': ');
    buffer.write(descStr);
  }
  if (errorObject.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(errorObject);
  }
  throw XPathEvaluationException(buffer.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-trace
const fnTrace = XPathFunctionItem.overloaded(XmlName.qualified('fn:trace'), {
  1: XPathFunctionItem.fn1(XmlName.qualified('fn:trace'), _fnTrace1),
  2: XPathFunctionItem.fn2(XmlName.qualified('fn:trace'), _fnTrace2),
});

XPathSequence _fnTrace1(XPathContext context, XPathSequence value) {
  final trace = context.configuration.onTraceCallback;
  if (trace != null) trace(value, null);
  return value;
}

XPathSequence _fnTrace2(
  XPathContext context,
  XPathSequence value,
  XPathSequence label,
) {
  final trace = context.configuration.onTraceCallback;
  final lbl = label.firstOrNull;
  final labelStr = lbl != null
      ? (lbl is XPathString ? lbl.value : lbl.stringValue)
      : null;
  if (trace != null) trace(value, labelStr);
  return value;
}
