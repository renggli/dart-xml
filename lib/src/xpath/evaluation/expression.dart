import 'package:meta/meta.dart';

import '../types31/sequence.dart';
import 'context.dart';

/// Abstract superclass of an XPath expression.
@immutable
abstract class XPathExpression {
  /// Evaluates the given XPath expression.
  XPathSequence call(XPathContext context);
}
