# XPath

Adhere to the official XPath 3.1 stnadard at all times:

- XML Path Language (XPath) 3.1: <https://www.w3.org/TR/xpath-31/>
- XPath Functions and Operators 3.1: <https://www.w3.org/TR/xpath-functions-31/>

## Overal Design

The core goals of this design are **efficiency**, **compactness**, and **readability**. To achieve this, we avoid heavy wrapper objects and runtime interpreters where possible. Instead, we leverage Dart's strong type system, modern features, and core libraries.

- **Zero-Wrapper**: Map XPath Data Model types map directly to native Dart types.
- **Lazy Sequences**: Use Dart's `Iterable` for all sequences to ensure laziness and low memory footprint.
- **Functional AST**: Expression nodes are executable functors, reducing the need for a separate interpreter pass for evaluation.

## Data Model

Instead of wrapping every integer, string, and node, we use Dart's native types. This allows the XPath engine to interact seamlessly with existing Dart objects.

Types are implemented as subclasses of [XPathType](definitions/type.dart). Types can check if a Dart Object is of their type with [XPathType.matches], and they can convert themselves to any other XPath type with [XPathType.cast].

Sequences are implemented as an `XPathSequence`, a thin wrapper around a Dart [Iterable]. The impelementation is defined in [sequence.dart](types/sequence.dart).

All other XPath types directly map to corresponding Dart types.

| XPath Type | Dart Type | Type Implementation
| --- | --- | ---
| `item()` | `xsAny` | `Object`
| `sequence` | `xsSequence` or `XPathSequenceType` | `XPathSequence`
| `empty-sequence` | `xsEmptySequence` | `XPathSequence`

### Nodes

XML nodes are represented by the [XmlNode](../../xml/nodes/node.dart) class and its subtypes.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `attribute` | `XmlAttribute` | `xsAttribute`
| `comment` | `XmlComment` | `xsComment`
| `document` | `XmlDocument` | `xsDocument`
| `element` | `XmlElement` | `xsElement`
| `node` | `XmlNode` | `xsNode`
| `processing-instruction` | `XmlProcessingInstruction` | `xsProcessingInstruction`
| `text` | `XmlText` and `XmlCDATA` | `xsText`

### Functions

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `function(*)` | `XPathFunction` | `xsFunction`
| `array(*)` | `XPathArray` | `xsArray`
| `map(*)` | `XPathMap` | `xsMap`

### Dates, Times and Durations

Date and time values are represented by the Dart `DateTime` class.
Duration values are represented by the Dart `Duration`.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:date` | `DateTime` | `xsDateTime`
| `xs:dateTime` | `DateTime` | `xsDateTime`
| `xs:dateTimeStamp` | `DateTime` | `xsDateTime`
| `xs:dayTimeDuration` | `Duration` | `xsDuration`
| `xs:duration` | `Duration` | `xsDuration`
| `xs:gDay` | `DateTime` | `xsDateTime`
| `xs:gMonth` | `DateTime` | `xsDateTime`
| `xs:gMonthDay` | `DateTime` | `xsDateTime`
| `xs:gYear` | `DateTime` | `xsDateTime`
| `xs:gYearMonth` | `DateTime` | `xsDateTime`
| `xs:time` | `DateTime` | `xsDateTime`
| `xs:yearMonthDuration` | `Duration` | `xsDuration`

### Numerics

Numeric values are represented by the Dart `num` class and its subtypes.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:numeric` | `num` | `xsNumeric`
| `xs:byte` | `int` | `xsInteger`
| `xs:decimal` | `int` | `xsInteger`
| `xs:double` | `double` | `xsDouble`
| `xs:float` | `double` | `xsDouble`
| `xs:int` | `int` | `xsInteger`
| `xs:integer` | `int` | `xsInteger`
| `xs:long` | `int` | `xsInteger`
| `xs:negativeInteger` | `int` | `xsInteger`
| `xs:nonNegativeInteger` | `int` | `xsInteger`
| `xs:nonPositiveInteger` | `int` | `xsInteger`
| `xs:positiveInteger` | `int` | `xsInteger`
| `xs:short` | `int` | `xsInteger`
| `xs:unsignedByte` | `int` | `xsInteger`
| `xs:unsignedInt` | `int` | `xsInteger`
| `xs:unsignedLong` | `int` | `xsInteger`
| `xs:unsignedShort` | `int` | `xsInteger`

### Strings

String values are represented by the Dart `String` class.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:string` | `String` | `xsString`
| `xs:normalizedString` | `String` | `xsString`
| `xs:token` | `String` | `xsString`
| `xs:language` | `String` | `xsString`
| `xs:NMTOKEN` | `String` | `xsString`
| `xs:Name` | `String` | `xsString`
| `xs:NCName` | `String` | `xsString`
| `xs:ID` | `String` | `xsString`
| `xs:IDREF` | `String` | `xsString`
| `xs:ENTITY` | `String` | `xsString`

### Booleans

Boolean values are represented by the Dart `bool` class.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:boolean` | `bool` | `xsBoolean`

### Others

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:base64Binary` | `XPathBase64Binary` | `xsBase64Binary`
| `xs:hexBinary` | `XPathHexBinary` | `xsHexBinary`
| `xs:anyURI` | `String` | `xsString`
| `xs:QName` | `XmlName` | `xsQName`
| `xs:NOTATION` | `String` | `xsString`

## Functions & Operators

All **XPath functions** are implemented in the [functions](functions) directory. A function definition follows the pattern:

1. A comment with a link to the standard describing the function.
2. A const `XPathFunctionDefinition` describing the function signature referring to the implementation function below.
     - Arguments with the cardinalty `XPathCardinality.exactlyOne` (default) has the corresponding native type.
     - Arguments with the cardinalty `XPathCardinality.zeroOrOne` has the corresponding type nullable.
     - Arguments with the cardinalty `XPathCardinality.zeroOrMore` or `XPathCardinality.oneOrMore` have type `XPathSequence`.
3. The private function implementation following these principles:
     - The first argument is always `XPathContext context`.
     - The following arguments are the arguments as described in the definition.
     - The argument types must be the corresponding native types, optional arguments are nullable.
     - The return type is always `XPathSequence`.
     - The function body should not do any type validation or argument unpacking. This must be done through the configuration in `XPathFunctionDefinition`.

All **XPath operators** are implemented as functions in the [operators](operators) directory. An operator definition follows the pattern:

1. A comment with a link to the standard describing the operator.
2. The operator implementation following these principles
     - The arguments are always of the type `XPathSequence`.
     - The return type is always `XPathSequence`.
