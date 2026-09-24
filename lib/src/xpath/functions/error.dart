import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/qname.dart';
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

XPathErrorCode _resolveErrorCode(XPathSequence code) {
  final items = code.atomize();
  if (items.isEmpty) {
    return XPathErrorCode.FOER0000;
  }
  if (items.length > 1) {
    throw XPathEvaluationException(XPathErrorCode.XPTY0004);
  }
  final item = items.single;
  if (item is! XPathQName) {
    throw XPathEvaluationException(XPathErrorCode.XPTY0004);
  }
  final local = item.value.local;
  final uri = item.value.namespaceUri ?? XPathErrorCode.standardNamespaceUri;
  final known = XPathErrorCode.tryFromCode(local);
  if (known != null &&
      (known.namespaceUri == uri || item.value.namespaceUri == null)) {
    return known;
  }
  return XPathErrorCode(local, 'Error', uri);
}

XPathSequence _fnError1(XPathContext context, XPathSequence code) {
  final errorCode = _resolveErrorCode(code);
  throw XPathEvaluationException(errorCode);
}

XPathSequence _fnError2(
  XPathContext context,
  XPathSequence code,
  XPathSequence description,
) {
  final errorCode = _resolveErrorCode(code);
  final d = description.atomize();
  if (d.length > 1) {
    throw XPathEvaluationException(XPathErrorCode.XPTY0004);
  }
  final descStr = d.firstOrNull?.stringValue;
  throw XPathEvaluationException(errorCode, descStr);
}

XPathSequence _fnError3(
  XPathContext context,
  XPathSequence code,
  XPathSequence description,
  XPathSequence errorObject,
) {
  final errorCode = _resolveErrorCode(code);
  final d = description.atomize();
  if (d.length > 1) {
    throw XPathEvaluationException(XPathErrorCode.XPTY0004);
  }
  final descStr = d.firstOrNull?.stringValue;
  var details = descStr;
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
