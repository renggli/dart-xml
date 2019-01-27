library xml.nodes.processing;

import 'package:xml/src/xml/nodes/data.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// XML processing instruction.
class XmlProcessing extends XmlData {
  /// Return the processing target.
  final String target;

  /// Create a processing node with `target` and `text`.
  XmlProcessing(this.target, String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitProcessing(this);
}
