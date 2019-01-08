library xml.iterator;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/nodes/node.dart';
import 'package:xml/xml/parser.dart';
import 'package:xml/xml/utils/exceptions.dart';
import 'package:xml/xml/utils/token.dart';

class XmlIterator extends Iterator<XmlNode> {
  XmlIterator(String input) : context = Success(input, 0, null);

  Result context;

  XmlStartElement parent;

  @override
  XmlNode current;

  @override
  bool moveNext() {
    context = _eventParser.parseOn(context);
    if (context.isSuccess) {
      current = context.value;
      current.attachParent(parent);
      if (current is XmlStartElement) {
        final XmlStartElement startElement = current;
        if (!startElement.isSelfClosing) {
          parent = current;
        }
      } else if (current is XmlEndElement) {
        final XmlEndElement endElement = current;
        XmlTagMismatchError.checkTags(parent?.name, endElement.name);
        parent = parent.parent;
      }
      return true;
    } else {
      context = null;
      parent = null;
      return false;
    }
  }
}

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
      .seq(string(XmlToken.closeEndElement).or(char(XmlToken.closeElement)))
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

final _eventParser = XmlEventDefinition().build();
