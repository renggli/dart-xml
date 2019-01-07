library xml.iterator;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/production.dart';
import 'package:xml/xml/utils/attribute_type.dart';
import 'package:xml/xml/utils/name.dart';
import 'package:xml/xml/utils/named.dart';
import 'package:xml/xml/utils/token.dart';

class XmlEvent {
  @override
  String toString() => '$runtimeType';
}

class XmlStartElementEvent extends XmlEvent implements XmlNamed {
  @override
  final XmlName name;

  final List<XmlAttribute> attributes;

  final bool isSelfClosing;

  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  @override
  String toString() => '${super.toString()}: <$name>';
}

class XmlEndElementEvent extends XmlEvent implements XmlNamed {
  @override
  final XmlName name;

  XmlEndElementEvent(this.name);

  @override
  String toString() => '${super.toString()}: </$name>';
}

class XmlDataEvent extends XmlEvent {
  final String text;

  XmlDataEvent(this.text);
}

class XmlDoctypeEvent extends XmlDataEvent {
  XmlDoctypeEvent(String text) : super(text);

  @override
  String toString() => '${super.toString()}: <DOCTYPE $text>';
}

class XmlCDATAEvent extends XmlDataEvent {
  XmlCDATAEvent(String text) : super(text);
  @override
  String toString() => '${super.toString()}: [[CDATA $text]';
}

class XmlCommentEvent extends XmlDataEvent {
  XmlCommentEvent(String text) : super(text);
}

class XmlProcessingEvent extends XmlDataEvent {
  final String target;
  XmlProcessingEvent(this.target, String text) : super(text);
  @override
  String toString() => '${super.toString()}: <!$target $text>';
}

class XmlTextEvent extends XmlDataEvent {
  XmlTextEvent(String text) : super(text);
  @override
  String toString() => '${super.toString()}: $text';
}

class XmlIterator extends Iterator<XmlEvent> {
  XmlIterator(String input) : context = Success(input, 0, null);

  Result context;

  @override
  XmlEvent get current => context.value;

  @override
  bool moveNext() {
    context = _eventParser.parseOn(context);
    return context.isSuccess;
  }
}

class XmlEventDefinition extends XmlProductionDefinition {
  @override
  Parser start() => ref(characterData)
      .or(ref(elementStart))
      .or(ref(elementEnd))
      .or(ref(comment))
      .or(ref(cdata))
      .or(ref(processing))
      .or(ref(doctype));

  @override
  Parser characterData() =>
      super.characterData().map((text) => XmlTextEvent(text));

  Parser elementStart() => char(XmlToken.openElement)
      .seq(ref(qualified))
      .seq(ref(attributes))
      .seq(ref(spaceOptional))
      .seq(string(XmlToken.closeEndElement).or(char(XmlToken.closeElement)))
      .map((each) => XmlStartElementEvent(
          each[1],
          List.castFrom<dynamic, XmlAttribute>(each[2]),
          each[4] == XmlToken.closeEndElement));

  Parser elementEnd() => string(XmlToken.openEndElement)
      .seq(ref(qualified))
      .seq(ref(spaceOptional))
      .seq(char(XmlToken.closeElement))
      .map((each) => XmlEndElementEvent(each[1]));

  @override
  Parser comment() => super.comment().map((each) => XmlCommentEvent(each[1]));

  @override
  Parser cdata() => super.cdata().map((each) => XmlCDATAEvent(each[1]));

  @override
  Parser processing() =>
      super.processing().map((each) => XmlProcessingEvent(each[1], each[2]));

  @override
  Parser doctype() => super.doctype().map((each) => XmlDataEvent(each[2]));

  @override
  Parser qualified() =>
      super.qualified().map((each) => XmlName.fromString(each));

  @override
  Parser attribute() => super
      .attribute()
      .map((each) => XmlAttribute(each[0], each[4][0], each[4][1]));

  @override
  Parser attributeValueDouble() => super
      .attributeValueDouble()
      .map((each) => [each[1], XmlAttributeType.DOUBLE_QUOTE]);

  @override
  Parser attributeValueSingle() => super
      .attributeValueSingle()
      .map((each) => [each[1], XmlAttributeType.SINGLE_QUOTE]);
}

final _eventParser = XmlEventDefinition().build();
