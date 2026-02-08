import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/boolean.dart';
import '../types/date_time.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-string
const xsStringConstructor = XPathFunctionDefinition(
  name: 'xs:string',
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
  name: 'xs:boolean',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsSequence,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _xsBooleanConstructor,
);

XPathSequence _xsBooleanConstructor(
  XPathContext context,
  XPathSequence value,
) => XPathSequence.single(xsBoolean.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsIntegerConstructor = XPathFunctionDefinition(
  name: 'xs:integer',
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
  name: 'xs:decimal',
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
    XPathSequence.single(xsNumeric.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-double
const xsDoubleConstructor = XPathFunctionDefinition(
  name: 'xs:double',
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
  name: 'xs:float',
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
  name: 'xs:numeric',
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
  name: 'xs:byte',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsIntConstructor = XPathFunctionDefinition(
  name: 'xs:int',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsLongConstructor = XPathFunctionDefinition(
  name: 'xs:long',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNegativeIntegerConstructor = XPathFunctionDefinition(
  name: 'xs:negativeInteger',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNonNegativeIntegerConstructor = XPathFunctionDefinition(
  name: 'xs:nonNegativeInteger',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsNonPositiveIntegerConstructor = XPathFunctionDefinition(
  name: 'xs:nonPositiveInteger',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsPositiveIntegerConstructor = XPathFunctionDefinition(
  name: 'xs:positiveInteger',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsShortConstructor = XPathFunctionDefinition(
  name: 'xs:short',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedByteConstructor = XPathFunctionDefinition(
  name: 'xs:unsignedByte',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedIntConstructor = XPathFunctionDefinition(
  name: 'xs:unsignedInt',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedLongConstructor = XPathFunctionDefinition(
  name: 'xs:unsignedLong',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
const xsUnsignedShortConstructor = XPathFunctionDefinition(
  name: 'xs:unsignedShort',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsIntegerConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-date
const xsDateConstructor = XPathFunctionDefinition(
  name: 'xs:date',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

XPathSequence _xsDateTimeConstructor(XPathContext context, Object value) =>
    XPathSequence.single(xsDateTime.cast(value));

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
const xsDateTimeConstructor = XPathFunctionDefinition(
  name: 'xs:dateTime',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTimeStamp
const xsDateTimeStampConstructor = XPathFunctionDefinition(
  name: 'xs:dateTimeStamp',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay
const xsGDayConstructor = XPathFunctionDefinition(
  name: 'xs:gDay',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth
const xsGMonthConstructor = XPathFunctionDefinition(
  name: 'xs:gMonth',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay
const xsGMonthDayConstructor = XPathFunctionDefinition(
  name: 'xs:gMonthDay',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear
const xsGYearConstructor = XPathFunctionDefinition(
  name: 'xs:gYear',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth
const xsGYearMonthConstructor = XPathFunctionDefinition(
  name: 'xs:gYearMonth',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time
const xsTimeConstructor = XPathFunctionDefinition(
  name: 'xs:time',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.exactlyOne,
    ),
  ],
  function: _xsDateTimeConstructor,
);
