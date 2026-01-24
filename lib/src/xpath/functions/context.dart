import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-position
const fnPosition = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'position',
  function: _fnPosition,
);

XPathSequence _fnPosition(XPathContext context) =>
    XPathSequence.single(context.position);

/// https://www.w3.org/TR/xpath-functions-31/#func-last
const fnLast = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'last',
  function: _fnLast,
);

XPathSequence _fnLast(XPathContext context) =>
    XPathSequence.single(context.last);

/// https://www.w3.org/TR/xpath-functions-31/#func-current-dateTime
const fnCurrentDateTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'current-dateTime',
  function: _fnCurrentDateTime,
);

XPathSequence _fnCurrentDateTime(XPathContext context) =>
    XPathSequence.single(DateTime.now());

/// https://www.w3.org/TR/xpath-functions-31/#func-current-date
const fnCurrentDate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'current-date',
  function: _fnCurrentDate,
);

XPathSequence _fnCurrentDate(XPathContext context) {
  final dateTime = DateTime.now();
  return XPathSequence.single(
    DateTime(dateTime.year, dateTime.month, dateTime.day),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-current-time
const fnCurrentTime = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'current-time',
  function: _fnCurrentTime,
);

XPathSequence _fnCurrentTime(XPathContext context) {
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
const fnImplicitTimezone = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'implicit-timezone',
  function: _fnImplicitTimezone,
);

XPathSequence _fnImplicitTimezone(XPathContext context) =>
    const XPathSequence.single(Duration(seconds: 0));

/// https://www.w3.org/TR/xpath-functions-31/#func-default-collation
const fnDefaultCollation = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'default-collation',
  function: _fnDefaultCollation,
);

XPathSequence _fnDefaultCollation(XPathContext context) =>
    const XPathSequence.single(
      'http://www.w3.org/2005/xpath-functions/collation/codepoint',
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-default-language
const fnDefaultLanguage = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'default-language',
  function: _fnDefaultLanguage,
);

XPathSequence _fnDefaultLanguage(XPathContext context) =>
    const XPathSequence.single('en');

/// https://www.w3.org/TR/xpath-functions-31/#func-static-base-uri
const fnStaticBaseUri = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'static-base-uri',
  function: _fnStaticBaseUri,
);

XPathSequence _fnStaticBaseUri(XPathContext context) => XPathSequence.empty;
