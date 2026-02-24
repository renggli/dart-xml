import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/data.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../expressions/node.dart';
import 'sequence.dart';

/// The XPath node type.
const xsNode = _XPathNodeType<XmlNode>('node');

class _XPathNodeType<T extends XmlNode> extends XPathType<T> {
  const _XPathNodeType(this.name);

  @override
  final String name;

  @override
  bool matches(Object value) => value is T;

  @override
  T cast(Object value) {
    if (matches(value)) {
      return value as T;
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}

/// The XPath attribute node type.
const xsAttribute = _XPathNodeType<XmlAttribute>('attribute');

/// The XPath comment node type.
const xsComment = _XPathNodeType<XmlComment>('comment');

/// The XPath document node type.
const xsDocument = _XPathNodeType<XmlDocument>('document');

/// The XPath processing-instruction node type.
const xsProcessingInstruction = XPathProcessingInstructionType();

class XPathProcessingInstructionType extends _XPathNodeType<XmlProcessing> {
  const XPathProcessingInstructionType([this.target])
    : super('processing-instruction');

  final String? target;

  @override
  bool matches(Object value) {
    if (value is! XmlProcessing) return false;
    if (target != null && value.target != target) return false;
    return true;
  }
}

/// The XPath element node type.
const xsElement = _XPathNodeType<XmlElement>('element');

/// The XPath namespace node type.
const xsNamespace = _XPathNodeType<XmlNamespace>('namespace');

/// The XPath text node type.
const xsText = _XPathTextType();

class _XPathTextType extends _XPathNodeType<XmlData> {
  const _XPathTextType() : super('text');

  @override
  bool matches(Object value) => value is XmlText || value is XmlCDATA;
}

/// Dynamic type wrapper for the `NodeTest` expressions.
class NodeTestType extends _XPathNodeType<XmlNode> {
  const NodeTestType(this.nodeTest, [String name = 'node-test']) : super(name);

  final NodeTest nodeTest;

  @override
  bool matches(Object value) => value is XmlNode && nodeTest.matches(value);
}
