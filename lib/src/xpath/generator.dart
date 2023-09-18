import '../xml/extensions/sibling.dart';
import '../xml/nodes/attribute.dart';
import '../xml/nodes/cdata.dart';
import '../xml/nodes/comment.dart';
import '../xml/nodes/document.dart';
import '../xml/nodes/element.dart';
import '../xml/nodes/node.dart';
import '../xml/nodes/processing.dart';
import '../xml/nodes/text.dart';

extension XPathGenerator on XmlNode {
  /// Returns an XPath string that can be used to query for this [XmlNode].
  ///
  /// If [byId] is giving a fully qualified attribute name, the presence of
  /// the attribute causes the generation of a shorter lookup expression.
  String xpathGenerate({String? byId}) {
    final result = <String>[];
    for (XmlNode? current = this; current != null; current = current.parent) {
      switch (current) {
        case XmlAttribute(qualifiedName: final name):
          result.add(_createSegment(current,
              where: (each) =>
                  each is XmlAttribute && each.qualifiedName == name,
              filter: '@$name'));
        case XmlElement(qualifiedName: final name):
          if (byId != null) {
            final attribute = current.getAttributeNode(byId);
            if (attribute != null) {
              result.add('//*[@${attribute.toXmlString()}]');
              return result.reversed.join('/');
            }
          }
          result.add(_createSegment(current,
              where: (each) => each is XmlElement && each.qualifiedName == name,
              filter: name));
        case XmlText():
        case XmlCDATA():
          result.add(_createSegment(current,
              where: (each) => each is XmlText || each is XmlCDATA,
              filter: 'text()'));
        case XmlComment():
          result.add(_createSegment(current,
              where: (each) => each is XmlComment, filter: 'comment()'));
        case XmlProcessing():
          result.add(_createSegment(current,
              where: (each) => each is XmlProcessing,
              filter: 'processing-instruction()'));
        case XmlDocument():
          result.add(this == current ? '/' : '');
        default:
          result.add(
              _createSegment(current, where: (each) => true, filter: 'node()'));
      }
    }
    return result.reversed.join('/');
  }
}

String _createSegment(XmlNode node,
    {required bool Function(XmlNode) where, required String filter}) {
  final buffer = StringBuffer(filter);
  final siblings =
      node.hasParent ? node.siblings.where(where).toList() : [node];
  if (siblings.length > 1) {
    buffer.write('[${1 + siblings.indexOf(node)}]');
  }
  return buffer.toString();
}
