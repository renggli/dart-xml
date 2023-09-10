import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

Matcher isXmlNode({XmlNode? node, XmlNodeType? nodeType, String? outerXml}) {
  var matcher = isA<XmlNode>();
  if (node != null) {
    return anyOf(
        same(node),
        matcher.having(
          (node) => node.outerXml,
          'outerXml',
          node.outerXml,
        ));
  }
  if (nodeType != null) {
    matcher = matcher.having(
      (node) => node.nodeType,
      'nodeType',
      nodeType,
    );
  }
  if (outerXml != null) {
    matcher = matcher.having(
      (node) => node.outerXml,
      'outerXml',
      startsWith(outerXml),
    );
  }
  return matcher;
}

Matcher isXmlParentException({
  dynamic message = isNotEmpty,
  dynamic node = anything,
  dynamic parent = anything,
}) =>
    isA<XmlParentException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.node, 'node', node)
        .having((value) => value.parent, 'parent', parent)
        .having((value) => value.toString(), 'toString', isNotEmpty);

Matcher isXmlParserException({
  dynamic message = isNotEmpty,
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic line = anything,
  dynamic column = anything,
}) =>
    isA<XmlParserException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.buffer, 'buffer', buffer)
        .having((value) => value.source, 'source', buffer)
        .having((value) => value.position, 'position', position)
        .having((value) => value.offset, 'offset', position)
        .having((value) => value.line, 'line', line)
        .having((value) => value.column, 'column', column)
        .having((value) => value.toString(), 'toString', isNotEmpty);

Matcher isXmlNodeTypeException({
  dynamic message = isNotEmpty,
  dynamic node = anything,
  dynamic types = anything,
}) =>
    isA<XmlNodeTypeException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.node, 'node', node)
        .having((value) => value.types, 'types', types)
        .having((value) => value.toString(), 'toString', isNotEmpty);

Matcher isXmlTagException({
  dynamic message = isNotEmpty,
  dynamic expectedName = anything,
  dynamic actualName = anything,
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic line = anything,
  dynamic column = anything,
}) =>
    isA<XmlTagException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.expectedName, 'expectedName', expectedName)
        .having((value) => value.actualName, 'actualName', actualName)
        .having((value) => value.buffer, 'buffer', buffer)
        .having((value) => value.position, 'position', position)
        .having((value) => value.line, 'line', line)
        .having((value) => value.column, 'column', column)
        .having((value) => value.toString(), 'toString', isNotEmpty);

Matcher isXPathParserException({
  dynamic message = isNotEmpty,
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic line = anything,
  dynamic column = anything,
}) =>
    isA<XPathParserException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.buffer, 'buffer', buffer)
        .having((value) => value.source, 'source', buffer)
        .having((value) => value.position, 'position', position)
        .having((value) => value.offset, 'offset', position)
        .having((value) => value.line, 'line', line)
        .having((value) => value.column, 'column', column)
        .having((value) => value.toString(), 'toString', isNotEmpty);

Matcher isXPathEvaluationException({
  dynamic message = isNotEmpty,
  dynamic name = anything,
  dynamic args = anything,
}) =>
    isA<XPathEvaluationException>()
        .having((value) => value.message, 'message', message)
        .having((value) => value.toString(), 'toString', isNotEmpty);
