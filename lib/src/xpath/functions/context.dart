import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/date_time.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-position
XPathSequence fnPosition(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:position', arguments, 0);
  return XPathSequence.single(context.position);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-last
XPathSequence fnLast(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:last', arguments, 0);
  return XPathSequence.single(context.last);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-dateTime
XPathSequence fnCurrentDateTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:current-dateTime',
    arguments,
    0,
  );
  return XPathSequence.single(XPathDateTime(DateTime.now()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-date
XPathSequence fnCurrentDate(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:current-date', arguments, 0);
  final dateTime = DateTime.now();
  return XPathSequence.single(
    XPathDateTime(DateTime(dateTime.year, dateTime.month, dateTime.day)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-time
XPathSequence fnCurrentTime(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:current-time', arguments, 0);
  final dateTime = DateTime.now();
  return XPathSequence.single(
    XPathDateTime(
      DateTime(
        0,
        0,
        0,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
        dateTime.millisecond,
        dateTime.microsecond,
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-implicit-timezone
XPathSequence fnImplicitTimezone(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:implicit-timezone',
    arguments,
    0,
  );
  return const XPathSequence.single(Duration(seconds: 0));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-default-collation
XPathSequence fnDefaultCollation(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:default-collation',
    arguments,
    0,
  );
  return const XPathSequence.single(
    XPathString('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-default-language
XPathSequence fnDefaultLanguage(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:default-language',
    arguments,
    0,
  );
  return const XPathSequence.single(XPathString('en'));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-static-base-uri
XPathSequence fnStaticBaseUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:static-base-uri',
    arguments,
    0,
  );
  return XPathSequence.empty;
}
