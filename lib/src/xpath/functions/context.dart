import '../../xml/utils/name.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-position
const fnPosition = XPathFunctionDefinition(
  name: XmlName.qualified('fn:position'),
  function: _fnPosition,
);

XPathSequence _fnPosition(XPathContext context) =>
    XPathSequence.single(context.position);

/// https://www.w3.org/TR/xpath-functions-31/#func-last
const fnLast = XPathFunctionDefinition(
  name: XmlName.qualified('fn:last'),
  function: _fnLast,
);

XPathSequence _fnLast(XPathContext context) =>
    XPathSequence.single(context.last);

/// https://www.w3.org/TR/xpath-functions-31/#func-current-dateTime
const fnCurrentDateTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:current-dateTime'),
  function: _fnCurrentDateTime,
);

XPathSequence _fnCurrentDateTime(XPathContext context) {
  final now = DateTime.now();
  return XPathSequence.single(
    XPathDateTime.fromDateTime(now, now.timeZoneOffset.inMinutes),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-date
const fnCurrentDate = XPathFunctionDefinition(
  name: XmlName.qualified('fn:current-date'),
  function: _fnCurrentDate,
);

XPathSequence _fnCurrentDate(XPathContext context) {
  final now = DateTime.now();
  return XPathSequence.single(
    XPathDate(now.year, now.month, now.day, now.timeZoneOffset.inMinutes),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-time
const fnCurrentTime = XPathFunctionDefinition(
  name: XmlName.qualified('fn:current-time'),
  function: _fnCurrentTime,
);

XPathSequence _fnCurrentTime(XPathContext context) {
  final now = DateTime.now();
  return XPathSequence.single(
    XPathTime(
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
      now.timeZoneOffset.inMinutes,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-implicit-timezone
const fnImplicitTimezone = XPathFunctionDefinition(
  name: XmlName.qualified('fn:implicit-timezone'),
  function: _fnImplicitTimezone,
);

XPathSequence _fnImplicitTimezone(XPathContext context) => XPathSequence.single(
  XPathDayTimeDuration(DateTime.now().timeZoneOffset.inMicroseconds),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-default-collation
const fnDefaultCollation = XPathFunctionDefinition(
  name: XmlName.qualified('fn:default-collation'),
  function: _fnDefaultCollation,
);

XPathSequence _fnDefaultCollation(XPathContext context) =>
    const XPathSequence.single(
      'http://www.w3.org/2005/xpath-functions/collation/codepoint',
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-default-language
const fnDefaultLanguage = XPathFunctionDefinition(
  name: XmlName.qualified('fn:default-language'),
  function: _fnDefaultLanguage,
);

XPathSequence _fnDefaultLanguage(XPathContext context) =>
    const XPathSequence.single('en');

/// https://www.w3.org/TR/xpath-functions-31/#func-static-base-uri
const fnStaticBaseUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:static-base-uri'),
  function: _fnStaticBaseUri,
);

XPathSequence _fnStaticBaseUri(XPathContext context) {
  final base = context.configuration.baseUri;
  if (base == null) return XPathSequence.empty;
  return XPathSequence.single(base);
}
