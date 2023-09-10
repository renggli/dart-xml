import 'package:meta/meta.dart';

import 'context.dart';
import 'values.dart';

/// Abstract superclass of an XPath expression.
@immutable
abstract class XPathExpression {
  /// Evaluates the given XPath expression.
  XPathValue call(XPathContext context);
}
