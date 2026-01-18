import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/binary.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-equal
const opHexBinaryEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'hexBinary-equal',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathHexBinary),
    XPathArgumentDefinition(name: 'value2', type: XPathHexBinary),
  ],
  function: _opHexBinaryEqual,
);

XPathSequence _opHexBinaryEqual(
  XPathContext context,
  XPathHexBinary value1,
  XPathHexBinary value2,
) => XPathSequence.single(_compareBinary(value1, value2) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-less-than
const opHexBinaryLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'hexBinary-less-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathHexBinary),
    XPathArgumentDefinition(name: 'value2', type: XPathHexBinary),
  ],
  function: _opHexBinaryLessThan,
);

XPathSequence _opHexBinaryLessThan(
  XPathContext context,
  XPathHexBinary value1,
  XPathHexBinary value2,
) => XPathSequence.single(_compareBinary(value1, value2) < 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary-greater-than
const opHexBinaryGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'hexBinary-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathHexBinary),
    XPathArgumentDefinition(name: 'value2', type: XPathHexBinary),
  ],
  function: _opHexBinaryGreaterThan,
);

XPathSequence _opHexBinaryGreaterThan(
  XPathContext context,
  XPathHexBinary value1,
  XPathHexBinary value2,
) => XPathSequence.single(_compareBinary(value1, value2) > 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-equal
const opBase64BinaryEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'base64Binary-equal',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathBase64Binary),
    XPathArgumentDefinition(name: 'value2', type: XPathBase64Binary),
  ],
  function: _opBase64BinaryEqual,
);

XPathSequence _opBase64BinaryEqual(
  XPathContext context,
  XPathBase64Binary value1,
  XPathBase64Binary value2,
) => XPathSequence.single(_compareBinary(value1, value2) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-less-than
const opBase64BinaryLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'base64Binary-less-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathBase64Binary),
    XPathArgumentDefinition(name: 'value2', type: XPathBase64Binary),
  ],
  function: _opBase64BinaryLessThan,
);

XPathSequence _opBase64BinaryLessThan(
  XPathContext context,
  XPathBase64Binary value1,
  XPathBase64Binary value2,
) => XPathSequence.single(_compareBinary(value1, value2) < 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary-greater-than
const opBase64BinaryGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'base64Binary-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'value1', type: XPathBase64Binary),
    XPathArgumentDefinition(name: 'value2', type: XPathBase64Binary),
  ],
  function: _opBase64BinaryGreaterThan,
);

XPathSequence _opBase64BinaryGreaterThan(
  XPathContext context,
  XPathBase64Binary value1,
  XPathBase64Binary value2,
) => XPathSequence.single(_compareBinary(value1, value2) > 0);

int _compareBinary(List<int> a, List<int> b) {
  final len = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final diff = a[i].compareTo(b[i]);
    if (diff != 0) return diff;
  }
  return a.length.compareTo(b.length);
}
