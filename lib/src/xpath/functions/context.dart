import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-position
const fnPosition = XPathFunctionItem.fn0(
  XmlName.qualified('fn:position'),
  _fnPosition,
);

XPathSequence _fnPosition(XPathContext context) =>
    XPathSequence.single(XPathInteger.fromInt(context.position));

/// https://www.w3.org/TR/xpath-functions-31/#func-last
const fnLast = XPathFunctionItem.fn0(XmlName.qualified('fn:last'), _fnLast);

XPathSequence _fnLast(XPathContext context) =>
    XPathSequence.single(XPathInteger.fromInt(context.last));

/// https://www.w3.org/TR/xpath-functions-31/#func-current-dateTime
const fnCurrentDateTime = XPathFunctionItem.fn0(
  XmlName.qualified('fn:current-dateTime'),
  _fnCurrentDateTime,
);

XPathSequence _fnCurrentDateTime(XPathContext context) {
  final now = context.currentDateTime;
  return XPathSequence.single(
    XPathDateTime.fromDateTime(now, now.timeZoneOffset.inMinutes),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-date
const fnCurrentDate = XPathFunctionItem.fn0(
  XmlName.qualified('fn:current-date'),
  _fnCurrentDate,
);

XPathSequence _fnCurrentDate(XPathContext context) {
  final now = context.currentDateTime;
  return XPathSequence.single(
    XPathDateTime.date(
      now.year,
      now.month,
      now.day,
      now.timeZoneOffset.inMinutes,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-time
const fnCurrentTime = XPathFunctionItem.fn0(
  XmlName.qualified('fn:current-time'),
  _fnCurrentTime,
);

XPathSequence _fnCurrentTime(XPathContext context) {
  final now = context.currentDateTime;
  return XPathSequence.single(
    XPathDateTime.time(
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
const fnImplicitTimezone = XPathFunctionItem.fn0(
  XmlName.qualified('fn:implicit-timezone'),
  _fnImplicitTimezone,
);

XPathSequence _fnImplicitTimezone(XPathContext context) => XPathSequence.single(
  XPathDuration.dayTime(context.currentDateTime.timeZoneOffset.inMicroseconds),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-default-collation
const fnDefaultCollation = XPathFunctionItem.fn0(
  XmlName.qualified('fn:default-collation'),
  _fnDefaultCollation,
);

XPathSequence _fnDefaultCollation(XPathContext context) =>
    const XPathSequence.single(
      XPathString('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-default-language
const fnDefaultLanguage = XPathFunctionItem.fn0(
  XmlName.qualified('fn:default-language'),
  _fnDefaultLanguage,
);

XPathSequence _fnDefaultLanguage(XPathContext context) =>
    const XPathSequence.single(XPathString('en', xsLanguage));

/// https://www.w3.org/TR/xpath-functions-31/#func-static-base-uri
const fnStaticBaseUri = XPathFunctionItem.fn0(
  XmlName.qualified('fn:static-base-uri'),
  _fnStaticBaseUri,
);

XPathSequence _fnStaticBaseUri(XPathContext context) {
  final base = context.configuration.baseUri;
  if (base == null) return XPathSequence.empty;
  return XPathSequence.single(XPathAnyUri(base));
}
