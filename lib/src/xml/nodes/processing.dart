import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML processing instruction.
class XmlProcessing extends XmlData {
  /// Create a processing node with `target` and `value`.
  XmlProcessing(this.target, super.value);

  /// Return the processing target.
  final String target;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  XmlProcessing copy() => XmlProcessing(target, value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitProcessing(this);
}
