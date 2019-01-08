library xml.iterator;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/nodes/node.dart';
import 'package:xml/xml/parser.dart';
import 'package:xml/xml/utils/exceptions.dart';
import 'package:xml/xml/utils/token.dart';

/// Grammar definition to read XML data event based.
class XmlEventDefinition extends XmlParserDefinition {
  @override
  Parser start() => ref(characterData)
      .or(ref(elementStart))
      .or(ref(elementEnd))
      .or(ref(comment))
      .or(ref(cdata))
      .or(ref(processing))
      .or(ref(doctype));

  Parser elementStart() => char(XmlToken.openElement)
      .seq(ref(qualified))
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeElement).or(string(XmlToken.closeEndElement)))
      .map((each) => XmlStartElement(
          each[1],
          List.castFrom<dynamic, XmlAttribute>(each[2]),
          each[4] == XmlToken.closeEndElement));

  Parser elementEnd() => string(XmlToken.openEndElement)
      .seq(ref(qualified))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeElement))
      .map((each) => XmlEndElement(each[1]));
}

/// Parser to read XML data event based.
final _eventParser = XmlEventDefinition().build();

/// Lazily iterates over and input [String] and produces [XmlNode] events.
class XmlParseIterator extends Iterator<XmlNode> {
  XmlParseIterator(String input) : context = Success(input, 0, null);

  Result context;

  XmlStartElement outer;

  @override
  XmlNode current;

  @override
  bool moveNext() {
    context = _eventParser.parseOn(context);
    if (context.isSuccess) {
      current = context.value;
      if (current is XmlEndElement) {
        final XmlEndElement endElement = current;
        XmlTagMismatchError.checkTags(outer?.name, endElement.name);
        outer = outer.parent;
      }
      current.attachParent(outer);
      if (current is XmlStartElement) {
        final XmlStartElement startElement = current;
        if (!startElement.isSelfClosing) {
          outer = current;
        }
      }
      return true;
    } else {
      if (context.position < context.buffer.length) {
        final message = context.message;
        final position =
            Token.lineAndColumnOf(context.buffer, context.position);
        context = context.failure(context.message, context.position + 1);
        throw XmlParserException(message, position[0], position[1]);
      } else {
        context = null;
        outer = null;
        return false;
      }
    }
  }
}
