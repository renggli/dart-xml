import 'package:meta/meta.dart';

import '../xml/nodes/node.dart';

/// Abstract superclass of an XPath expression.
///
/// While this this is nothing more than `typedef Resolver = Iterable<XmlNode>
/// call(Iterable<XmlNode> nodes);`, the object implementation gives much
/// better debug-ability and allows to actually inspect the execution plans.
@immutable
abstract class Resolver {
  /// Resolves a set of [XmlNode].
  ///
  /// Implementations can amend, replace, or filter the incoming nodes with
  /// new nodes. Ideally the operations are lazy, and the resulting nodes are
  /// de-duplicated and in document order.
  Iterable<XmlNode> call(Iterable<XmlNode> nodes);
}
