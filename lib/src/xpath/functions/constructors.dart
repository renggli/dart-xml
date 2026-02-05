import '../evaluation/context.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

XPathSequence xsString(XPathContext context, List<XPathSequence> arguments) =>
    XPathSequence.single(arguments.firstOrNull?.toXPathString() ?? '');

XPathSequence xsBoolean(XPathContext context, List<XPathSequence> arguments) =>
    XPathSequence.single(arguments.firstOrNull?.toXPathBoolean() ?? false);

XPathSequence xsNumber(XPathContext context, List<XPathSequence> arguments) {
  final arg = arguments.firstOrNull;
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  final item = arg.singleOrNull;
  if (item is String) {
    if (item == 'INF') return const XPathSequence.single(double.infinity);
    if (item == '-INF') {
      return const XPathSequence.single(double.negativeInfinity);
    }
  }
  return XPathSequence.single(arg.toXPathNumber());
}

XPathSequence xsDateTime(XPathContext context, List<XPathSequence> arguments) {
  final arg = arguments.firstOrNull;
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(arg.toXPathDateTime());
}

XPathSequence xsDuration(XPathContext context, List<XPathSequence> arguments) {
  final arg = arguments.firstOrNull;
  if (arg == null || arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(arg.toXPathDuration());
}
