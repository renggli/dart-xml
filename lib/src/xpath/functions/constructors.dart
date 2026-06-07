import '../../xml/utils/name.dart';
import '../../xml/utils/token.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/binary.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/qname.dart';
import '../types/string.dart';
import '../values/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-string
const xsStringConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:string'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsStringConstructor,
);

XPathSequence _xsStringConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.emptyString;
  return XPathSequence.single(xsString.cast(value));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
const xsBooleanConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:boolean'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsBooleanConstructor,
);

XPathSequence _xsBooleanConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(xsBoolean.cast(value));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsIntegerConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:integer'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

XPathSequence _xsIntegerConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsInteger.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-decimal
const xsDecimalConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:decimal'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDecimalConstructor,
);

XPathSequence _xsDecimalConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsDecimal.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-double
const xsDoubleConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:double'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDoubleConstructor,
);

XPathSequence _xsDoubleConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsDouble.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-float
const xsFloatConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:float'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsFloatConstructor,
);

XPathSequence _xsFloatConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsDouble.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric
const xsNumericConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:numeric'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsNumericConstructor,
);

XPathSequence _xsNumericConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsNumeric.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsByteConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:byte'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsByteConstructor,
);

XPathSequence _xsByteConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsByte.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsIntConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:int'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntConstructor,
);

XPathSequence _xsIntConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsInt.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsLongConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:long'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsLongConstructor,
);

XPathSequence _xsLongConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsLong.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNegativeIntegerConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:negativeInteger'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsNegativeIntegerConstructor,
);

XPathSequence _xsNegativeIntegerConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsNegativeInteger.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNonNegativeIntegerConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:nonNegativeInteger'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsNonNegativeIntegerConstructor,
);

XPathSequence _xsNonNegativeIntegerConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsNonNegativeInteger.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNonPositiveIntegerConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:nonPositiveInteger'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsNonPositiveIntegerConstructor,
);

XPathSequence _xsNonPositiveIntegerConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsNonPositiveInteger.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsPositiveIntegerConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:positiveInteger'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsPositiveIntegerConstructor,
);

XPathSequence _xsPositiveIntegerConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsPositiveInteger.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsShortConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:short'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsShortConstructor,
);

XPathSequence _xsShortConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsShort.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedByteConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:unsignedByte'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsUnsignedByteConstructor,
);

XPathSequence _xsUnsignedByteConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsUnsignedByte.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedIntConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:unsignedInt'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsUnsignedIntConstructor,
);

XPathSequence _xsUnsignedIntConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsUnsignedInt.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedLongConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:unsignedLong'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsUnsignedLongConstructor,
);

XPathSequence _xsUnsignedLongConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsUnsignedLong.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedShortConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:unsignedShort'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsUnsignedShortConstructor,
);

XPathSequence _xsUnsignedShortConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsUnsignedShort.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-date
const xsDateConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:date'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDate,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
const xsDateTimeConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:dateTime'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDateTime,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTimeStamp
const xsDateTimeStampConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:dateTimeStamp'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsDateTimeStamp,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay
const xsGDayConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:gDay'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsGDay,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth
const xsGMonthConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:gMonth'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsGMonth,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay
const xsGMonthDayConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:gMonthDay'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsGMonthDay,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear
const xsGYearConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:gYear'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsGYear,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth
const xsGYearMonthConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:gYearMonth'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsGYearMonth,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time
const xsTimeConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:time'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsTime,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsSingleValueConstructor,
);

XPathSequence _xsSingleValueConstructor(XPathContext context, Object value) =>
    XPathSequence.single(value);

/// https://www.w3.org/TR/xpath-functions-31/#func-duration
const xsDurationConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDurationConstructor,
);

XPathSequence _xsDurationConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsDuration.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration
const xsYearMonthDurationConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:yearMonthDuration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsYearMonthDurationConstructor,
);

XPathSequence _xsYearMonthDurationConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsYearMonthDuration.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration
const xsDayTimeDurationConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:dayTimeDuration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDayTimeDurationConstructor,
);

XPathSequence _xsDayTimeDurationConstructor(
  XPathContext context,
  Object value,
) => XPathSequence.single(xsDayTimeDuration.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary
const xsHexBinaryConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:hexBinary'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsHexBinaryConstructor,
);

XPathSequence _xsHexBinaryConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsHexBinary.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary
const xsBase64BinaryConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:base64Binary'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsBase64BinaryConstructor,
);

XPathSequence _xsBase64BinaryConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsBase64Binary.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-anyURI
const xsAnyURIConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:anyURI'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsStringConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
const xsQNameConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:QName'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsQNameConstructor,
);

XPathSequence _xsQNameConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsQName.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION
const xsNOTATIONConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:NOTATION'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsStringConstructor, // NOTATION is implemented as string?
);

/// https://www.w3.org/TR/xpath-functions-31/#func-untypedAtomic
const xsUntypedAtomicConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:untypedAtomic'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsStringConstructor, // untypedAtomic is likely string compatible
);

/// https://www.w3.org/TR/xpath-functions-31/#func-normalizedString
const xsNormalizedStringConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:normalizedString'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsNormalizedStringConstructor,
);

XPathSequence _xsNormalizedStringConstructor(
  XPathContext context, [
  Object? value,
]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = xsString.cast(value);
  return XPathSequence.single(_normalizeString(stringValue));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-token
const xsTokenConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:token'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsTokenConstructor,
);

XPathSequence _xsTokenConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = xsString.cast(value);
  return XPathSequence.single(_collapseWhitespace(stringValue));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-language
const xsLanguageConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:language'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsLanguageConstructor,
);

XPathSequence _xsLanguageConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_languageRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:language: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-NMTOKEN
const xsNMTOKENConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:NMTOKEN'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsNMTOKENConstructor,
);

XPathSequence _xsNMTOKENConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_nmTokenRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:NMTOKEN: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-Name
const xsNameConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:Name'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsNameConstructor,
);

XPathSequence _xsNameConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_nameRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:Name: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-NCName
const xsNCNameConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:NCName'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsNCNameConstructor,
);

XPathSequence _xsNCNameConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_ncNameRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:NCName: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ID
const xsIDConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:ID'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsIDConstructor,
);

XPathSequence _xsIDConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_ncNameRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:ID: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-IDREF
const xsIDREFConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:IDREF'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsIDREFConstructor,
);

XPathSequence _xsIDREFConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_ncNameRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:IDREF: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ENTITY
const xsENTITYConstructor = XPathFunctionDefinition(
  name: XmlName.qualified('xs:ENTITY'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _xsENTITYConstructor,
);

XPathSequence _xsENTITYConstructor(XPathContext context, [Object? value]) {
  if (value == null) return XPathSequence.empty;
  final stringValue = _collapseWhitespace(xsString.cast(value));
  if (!_ncNameRegExp.hasMatch(stringValue)) {
    throw XPathEvaluationException(
      'Invalid lexical value for xs:ENTITY: "$stringValue"',
    );
  }
  return XPathSequence.single(stringValue);
}

/// Helpers and patterns for string-derived XML Schema constructor validation.

final _normalizeStringRegexp = RegExp(r'\s');
String _normalizeString(String value) =>
    value.replaceAll(_normalizeStringRegexp, ' ');

final _collapseWhitespaceRegExp = RegExp(r'\s+');
String _collapseWhitespace(String value) =>
    value.trim().replaceAll(_collapseWhitespaceRegExp, ' ');

final _ncNameStartCharPattern = XmlToken.nameStartChars.replaceFirst(':', '');
final _ncNameCharPattern = XmlToken.nameChars.replaceFirst(':', '');

final _languageRegExp = RegExp(r'^[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*$');
final _nmTokenRegExp = RegExp('^[${XmlToken.nameChars}]+\$', unicode: true);
final _nameRegExp = RegExp(
  '^[${XmlToken.nameStartChars}][${XmlToken.nameChars}]*\$',
  unicode: true,
);
final _ncNameRegExp = RegExp(
  '^[$_ncNameStartCharPattern][$_ncNameCharPattern]*\$',
  unicode: true,
);
