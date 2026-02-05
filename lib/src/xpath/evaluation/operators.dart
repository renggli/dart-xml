import '../types/sequence.dart';

/// Function definition for a binary XPath operator.
typedef XPathBinaryOperator =
    XPathSequence Function(XPathSequence left, XPathSequence right);

/// Function definition for a unary XPath operator.
typedef XPathUnaryOperator = XPathSequence Function(XPathSequence arg);
