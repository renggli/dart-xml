# XPath 3.1 Types

This library implements the XPath 3.1 types as defined in [XPath Functions and Operators 3.1](https://www.w3.org/TR/xpath-functions-31/).

Sequences are implemented as an `XPathSequence`, a thin wrapper around a Dart [Iterable].
The impelementation is defined in [sequence.dart](sequence.dart).

All other XPath types directly map to corresponding Dart types.

## Nodes

XML nodes are represented by the [XmlNode](../../xml/nodes/node.dart) class and its subtypes:

| XPath Type | Dart Type |
| --- | --- |
| `attribute` | `XmlAttribute` |
| `comment` | `XmlComment` |
| `document` | `XmlDocument` |
| `element` | `XmlElement` |
| `node` | `XmlNode` |
| `processing-instruction` | `XmlProcessing` |
| `text` | `XmlText` and `XmlCDATA` |

## Functions

| XPath Type | Dart Type |
| --- | --- |
| `function(*)` | `Function` |
| `array(*)` | `List` |
| `map(*)` | `Map` |

## Atomics

### Dates, Times and Durations

Date and time values are represented by the Dart `DateTime` class.
Duration values are represented by the Dart `Duration`.

| XPath Type | Dart Type |
| --- | --- |
| `xs:date` | `DateTime` |
| `xs:dateTime` | `DateTime` |
| `xs:dateTimeStamp` | `DateTime` |
| `xs:dayTimeDuration` | `Duration` |
| `xs:duration` | `Duration` |
| `xs:gDay` | `DateTime` |
| `xs:gMonth` | `DateTime` |
| `xs:gMonthDay` | `DateTime` |
| `xs:gYear` | `DateTime` |
| `xs:gYearMonth` | `DateTime` |
| `xs:time` | `DateTime` |
| `xs:yearMonthDuration` | `Duration` |

### Numerics

Numeric values are represented by the Dart `num` class and its subtypes.
Helpers are defined in [number.dart](number.dart).

| XPath Type | Dart Type |
| --- | --- |
| `xs:byte` | `int` |
| `xs:decimal` | `int` |
| `xs:double` | `double` |
| `xs:float` | `double` |
| `xs:int` | `int` |
| `xs:integer` | `int` |
| `xs:long` | `int` |
| `xs:negativeInteger` | `int` |
| `xs:nonNegativeInteger` | `int` |
| `xs:nonPositiveInteger` | `int` |
| `xs:positiveInteger` | `int` |
| `xs:short` | `int` |
| `xs:unsignedByte` | `int` |
| `xs:unsignedInt` | `int` |
| `xs:unsignedLong` | `int` |
| `xs:unsignedShort` | `int` |

### Strings

String values are represented by the Dart `String` class.
Helpers are defined in [string.dart](string.dart).

| XPath Type | Dart Type |
| --- | --- |
| `xs:string` | `String` |
| `xs:normalizedString` | `String` |
| `xs:token` | `String` |
| `xs:language` | `String` |
| `xs:NMTOKEN` | `String` |
| `xs:Name` | `String` |
| `xs:NCName` | `String` |
| `xs:ID` | `String` |
| `xs:IDREF` | `String` |
| `xs:ENTITY` | `String` |

### Booleans

Boolean values are represented by the Dart `bool` class.
Helpers are defined in [boolean.dart](boolean.dart).

| XPath Type | Dart Type |
| --- | --- |
| `xs:boolean` | `bool` |

### Others

| XPath Type | Dart Type |
| --- | --- |
| `xs:base64Binary` | `Uint8List` |
| `xs:hexBinary` | `Uint8List` |
| `xs:anyURI` | `URI` |
| `xs:QName` | `XmlName` |
| `xs:NOTATION` | `String` |

