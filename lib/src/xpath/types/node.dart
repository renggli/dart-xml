import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../definitions/types.dart';
import '../exceptions/evaluation_exception.dart';
import 'sequence.dart';

/// The XPath node type.
const xsNode = _XPathNodeType<XmlNode>('node');

/// The XPath node type.
const xsAttribute = _XPathNodeType<XmlAttribute>('attribute');

/// The XPath node type.
const xsComment = _XPathNodeType<XmlComment>('comment');

/// The XPath node type.
const xsDocument = _XPathNodeType<XmlDocument>('document');

/// The XPath node type.
const xsProcessingInstruction = _XPathNodeType<XmlProcessing>(
  'processing-instruction',
);

/// The XPath node type.
const xsElement = _XPathNodeType<XmlElement>('element');

/// The XPath node type.
const xsText = _XPathNodeType<XmlText>('text');

class _XPathNodeType<T extends XmlNode> extends XPathType<T> {
  const _XPathNodeType(this.name);

  @override
  final String name;

  @override
  bool matches(Object value) => value is T;

  @override
  T cast(Object value) {
    if (value is T) {
      return value;
    } else if (value is XPathSequence) {
      final item = value.singleOrNull;
      if (item != null) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
