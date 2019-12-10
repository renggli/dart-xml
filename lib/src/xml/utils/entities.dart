library xml.utils.entities;

import '../entities/default_mapping.dart';
import 'attribute_type.dart';

const defaultEntityMapping = XmlDefaultEntityMapping.xml();

/// Encode a string to be serialized as an XML text node.
@deprecated
String encodeXmlText(String input) => defaultEntityMapping.encodeText(input);

/// Encode a string to be serialized as an XML attribute value.
@deprecated
String encodeXmlAttributeValue(String input, XmlAttributeType type) =>
    defaultEntityMapping.encodeAttributeValue(input, type);

/// Encode a string to be serialized as an XML attribute value with quotes.
@deprecated
String encodeXmlAttributeValueWithQuotes(String input, XmlAttributeType type) =>
    defaultEntityMapping.encodeAttributeValueWithQuotes(input, type);
