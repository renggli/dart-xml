import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
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

XPathSequence _fnError0(XPathContext context) =>
    throw XPathEvaluationException(XPathErrorCode.FOER0000);

XPathSequence _fnError1(XPathContext context, XPathSequence code) {
  final c = code.firstOrNull;
  final codeStr = c != null
      ? (c is XPathString ? c.value : c.stringValue)
      : null;
  final errorCode =
      XPathErrorCode.tryFromCode(codeStr ?? '') ?? XPathErrorCode.FOER0000;
  throw XPathEvaluationException(
    errorCode,
    codeStr != null && codeStr != errorCode.name ? codeStr : null,
  );
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
  final errorCode =
      XPathErrorCode.tryFromCode(codeStr ?? '') ?? XPathErrorCode.FOER0000;
  final details = codeStr != null && codeStr != errorCode.name
      ? (descStr != null ? '$codeStr: $descStr' : codeStr)
      : descStr;
  throw XPathEvaluationException(errorCode, details);
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
  final errorCode =
      XPathErrorCode.tryFromCode(codeStr ?? '') ?? XPathErrorCode.FOER0000;
  var details = codeStr != null && codeStr != errorCode.name
      ? (descStr != null ? '$codeStr: $descStr' : codeStr)
      : descStr;
  if (errorObject.isNotEmpty) {
    final itemsStr = errorObject.join(', ');
    details = details != null ? '$details ($itemsStr)' : '($itemsStr)';
  }
  throw XPathEvaluationException(errorCode, details);
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
