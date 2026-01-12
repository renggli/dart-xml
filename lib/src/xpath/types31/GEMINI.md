# XPath Types

This module implements the XPath 3.1 types as defined in [XPath Functions and Operators 3.1](https://www.w3.org/TR/xpath-functions-31/).

Sequences are implemented as an `XPathSequence`, a thin wrapper around a Dart [Iterable].
The impelementation is defined in [sequence.dart](sequence.dart).

All other XPath types directly map to corresponding Dart types.

## Nodes

XML nodes are represented by the [XmlNode](../../xml/nodes/node.dart) class and its subtypes:

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `attribute` | `XmlAttribute` | `XPathNode` | `.toXPathNode()` |
| `comment` | `XmlComment` | `XPathNode` | `.toXPathNode()` |
| `document` | `XmlDocument` | `XPathNode` | `.toXPathNode()` |
| `element` | `XmlElement` | `XPathNode` | `.toXPathNode()` |
| `node` | `XmlNode` | `XPathNode` | `.toXPathNode()` |
| `processing-instruction` | `XmlProcessing` | `XPathNode` | `.toXPathNode()` |
| `text` | `XmlText` and `XmlCDATA` | `XPathNode` | `.toXPathNode()` |

## Functions

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `function(*)` | `Function` | `XPathFunction` | `.toXPathFunction()` |
| `array(*)` | `List<Object>` | `XPathArray` | `.toXPathArray()` and `.toXPathFunction()` |
| `map(*)` | `Map<Object, Object>` | `XPathMap` | `.toXPathMap()` and `.toXPathFunction()` |

## Atomics

### Dates, Times and Durations

Date and time values are represented by the Dart `DateTime` class.
Duration values are represented by the Dart `Duration`.

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `xs:date` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:dateTime` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:dateTimeStamp` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:dayTimeDuration` | `Duration` | `XPathDuration` | `.toXPathDuration()` |
| `xs:duration` | `Duration` | `XPathDuration` | `.toXPathDuration()` |
| `xs:gDay` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:gMonth` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:gMonthDay` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:gYear` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:gYearMonth` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:time` | `DateTime` | `XPathDateTime` | `.toXPathDateTime()` |
| `xs:yearMonthDuration` | `Duration` | `XPathDuration` | `.toXPathDuration()` |

### Numerics

Numeric values are represented by the Dart `num` class and its subtypes.
Helpers are defined in [number.dart](number.dart).

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `xs:byte` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:decimal` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:double` | `double` | `XPathNumber` | `.toXPathNumber()` |
| `xs:float` | `double` | `XPathNumber` | `.toXPathNumber()` |
| `xs:int` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:integer` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:long` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:negativeInteger` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:nonNegativeInteger` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:nonPositiveInteger` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:positiveInteger` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:short` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:unsignedByte` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:unsignedInt` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:unsignedLong` | `int` | `XPathNumber` | `.toXPathNumber()` |
| `xs:unsignedShort` | `int` | `XPathNumber` | `.toXPathNumber()` |

### Strings

String values are represented by the Dart `String` class.
Helpers are defined in [string.dart](string.dart).

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `xs:string` | `String` | `XPathString` | `.toXPathString()` |
| `xs:normalizedString` | `String` | `XPathString` | `.toXPathString()` |
| `xs:token` | `String` | `XPathString` | `.toXPathString()` |
| `xs:language` | `String` | `XPathString` | `.toXPathString()` |
| `xs:NMTOKEN` | `String` | `XPathString` | `.toXPathString()` |
| `xs:Name` | `String` | `XPathString` | `.toXPathString()` |
| `xs:NCName` | `String` | `XPathString` | `.toXPathString()` |
| `xs:ID` | `String` | `XPathString` | `.toXPathString()` |
| `xs:IDREF` | `String` | `XPathString` | `.toXPathString()` |
| `xs:ENTITY` | `String` | `XPathString` | `.toXPathString()` |

### Booleans

Boolean values are represented by the Dart `bool` class.
Helpers are defined in [boolean.dart](boolean.dart).

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `xs:boolean` | `bool` | `XPathBoolean` | `.toXPathBoolean()` |

### Others

| XPath Type | Dart Type | Dart Extension Type | Dart Cast |
| --- | --- | --- | --- |
| `xs:base64Binary` | `Uint8List` | `XPathBase64Binary` | `.toXPathBase64Binary()` |
| `xs:hexBinary` | `Uint8List` | `XPathHexBinary` | `.toXPathHexBinary()` |
| `xs:anyURI` | `String` | `XPathString` | `.toXPathString()` |
| `xs:QName` | `String` | `XPathString` | `.toXPathString()` |
| `xs:NOTATION` | `String` | `XPathString` | `.toXPathString()` |
