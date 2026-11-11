import '../../xml/extensions/ancestors.dart';
import '../../xml/nodes/element.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
final fnBoolean = XPathFunctionItem.fn1(XmlName('fn:boolean'), _fnBoolean);

XPathSequence _fnBoolean(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(XPathBoolean.from(arg.ebv));

/// https://www.w3.org/TR/xpath-functions-31/#func-not
final fnNot = XPathFunctionItem.fn1(XmlName('fn:not'), _fnNot);

XPathSequence _fnNot(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(XPathBoolean.from(!arg.ebv));

/// https://www.w3.org/TR/xpath-functions-31/#func-true
final fnTrue = XPathFunctionItem.fn0(XmlName('fn:true'), _fnTrue);

XPathSequence _fnTrue(XPathContext context) => XPathSequence.trueSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-false
final fnFalse = XPathFunctionItem.fn0(XmlName('fn:false'), _fnFalse);

XPathSequence _fnFalse(XPathContext context) => XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-lang
final fnLang = XPathFunctionItem.overloaded(XmlName('fn:lang'), {
  1: XPathFunctionItem.fn1(XmlName('fn:lang'), _fnLang1),
  2: XPathFunctionItem.fn2(XmlName('fn:lang'), _fnLang2),
});

XPathSequence _fnLang1(XPathContext context, XPathSequence testlang) =>
    _evalLang(context, testlang.firstOrNull, null);

XPathSequence _fnLang2(
  XPathContext context,
  XPathSequence testlang,
  XPathSequence node,
) => _evalLang(context, testlang.firstOrNull, node.firstOrNull);

XPathSequence _evalLang(
  XPathContext context,
  XPathItem? testlangItem,
  XPathItem? nodeItem,
) {
  final target = nodeItem is XPathNode
      ? nodeItem
      : (context.item is XPathNode ? context.item as XPathNode : null);
  if (target == null) {
    throw XPathEvaluationException(
      XPathErrorCode.XPDY0002,
      'fn:lang requires a context node',
    );
  }
  final item = target.node;
  final lang = [item, ...item.ancestors]
      .whereType<XmlElement>()
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return XPathSequence.falseSequence;
  if (testlangItem == null) return XPathSequence.falseSequence;
  final testlangStr = testlangItem is XPathString
      ? testlangItem.value
      : testlangItem.stringValue;
  return XPathSequence.single(
    XPathBoolean.from(lang.toLowerCase().startsWith(testlangStr.toLowerCase())),
  );
}
