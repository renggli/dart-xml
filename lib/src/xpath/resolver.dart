import 'package:meta/meta.dart';

import 'context.dart';
import 'values.dart';

/// Abstract superclass of an XPath expression.
///
/// While this this is nothing more than `typedef Resolver = Value
/// Function(Context context, Value value);`, the object implementation gives
/// much better debug-ability and allows to actually inspect the execution
/// plans.
@immutable
abstract class Resolver {
  /// Within the given execution [context] resolves the [value].
  ///
  /// Implementations can amend, replace, or filter the incoming nodes with
  /// new nodes. Ideally the operations are lazy, and the resulting nodes are
  /// de-duplicated and in document order.
  Value call(Context context, Value value);
}
