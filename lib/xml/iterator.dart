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

  List<int> get position =>
      Token.lineAndColumnOf(context.buffer, context.position);

  @override
  bool moveNext() {
    context = _eventParser.parseOn(context);
    if (context.isSuccess) {
      current = context.value;
      current.attachParent(outer);
      if (current is XmlStartElement) {
        // Handle the opening tag.
        final XmlStartElement startElement = current;
        if (!startElement.isSelfClosing) {
          outer = current;
        }
      } else if (current is XmlEndElement) {
        // Handle and validate the closing tag.
        final XmlEndElement endElement = current;
        if (outer == null) {
          throw XmlParserException(
              'Unexpected </${endElement.name}>.', position[0], position[1]);
        } else if (outer.name.qualified != endElement.name.qualified) {
          throw XmlParserException(
              'Expected </${outer.name}>, but found </${endElement.name}>.',
              position[0],
              position[1]);
        }
        outer = outer.parent;
      }
      return true;
    } else {
      if (context.position < context.buffer.length) {
        // Skip to the next character and throw an error.
        current = null;
        context = context.failure(context.message, context.position + 1);
        throw XmlParserException(context.message, position[0], position[1]);
      } else {
        // End of document, validate that all nodes were closed.
        current = null;
        if (outer != null) {
          outer = outer.parent;
          throw XmlParserException(
              'Expected </${outer.name}>, but reached end of document.',
              position[0],
              position[1]);
        }
        return false;
      }
    }
  }
}
