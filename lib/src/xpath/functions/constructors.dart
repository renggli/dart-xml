import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/boolean.dart';
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
