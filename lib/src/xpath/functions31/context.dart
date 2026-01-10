import '../evaluation/context.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-position
XPathSequence fnPosition(XPathContext context) =>
    XPathSequence.single(context.position);

/// https://www.w3.org/TR/xpath-functions-31/#func-last
XPathSequence fnLast(XPathContext context) =>
    XPathSequence.single(context.last);

/// https://www.w3.org/TR/xpath-functions-31/#func-current-dateTime
XPathSequence fnCurrentDateTime(XPathContext context) =>
    XPathSequence.single(DateTime.now());

/// https://www.w3.org/TR/xpath-functions-31/#func-current-date
XPathSequence fnCurrentDate(XPathContext context) {
  final dateTime = DateTime.now();
  return XPathSequence.single(
    DateTime(dateTime.year, dateTime.month, dateTime.day),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-time
XPathSequence fnCurrentTime(XPathContext context) {
  final dateTime = DateTime.now();
  return XPathSequence.single(
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
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-implicit-timezone
XPathSequence fnImplicitTimezone(XPathContext context) =>
    XPathSequence.single(const Duration(seconds: 0));

/// https://www.w3.org/TR/xpath-functions-31/#func-default-collation
XPathSequence fnDefaultCollation(XPathContext context) => XPathSequence.single(
  const XPathString(
    'http://www.w3.org/2005/xpath-functions/collation/codepoint',
  ),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-default-language
XPathSequence fnDefaultLanguage(XPathContext context) =>
    XPathSequence.single(const XPathString('en'));

/// https://www.w3.org/TR/xpath-functions-31/#func-static-base-uri
XPathSequence fnStaticBaseUri(XPathContext context) => XPathSequence.empty;
