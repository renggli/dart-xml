import 'package:meta/meta.dart';

import '../xml/nodes/node.dart';

/// Resolving function class.
@immutable
abstract class Resolver {
  Iterable<XmlNode> call(Iterable<XmlNode> nodes);
}
