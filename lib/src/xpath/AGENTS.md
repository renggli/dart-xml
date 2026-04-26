# XPath

Adhere to the official XPath 3.1 standard at all times:

- XML Path Language (XPath) 3.1: <https://www.w3.org/TR/xpath-31/>
- XPath Functions and Operators 3.1: <https://www.w3.org/TR/xpath-functions-31/>

## Overal Design

The core goals of this design are **efficiency**, **compactness**, and **readability**. To achieve this, we avoid heavy wrapper objects and runtime interpreters where possible. Instead, we leverage Dart's strong type system, modern features, and core libraries.

- **Zero-Wrapper**: Map XPath Data Model types map directly to native Dart types.
- **Lazy Sequences**: Use Dart's `Iterable` for all sequences to ensure laziness and low memory footprint.
- **Functional AST**: Expression nodes are executable functors, reducing the need for a separate interpreter pass for evaluation.
- **Exceptions**: Use Dart's exception system and human readable error messages to report errors.

## Data Model

Instead of wrapping every integer, string, and node, we use Dart's native types. This allows the XPath engine to interact seamlessly with existing Dart objects.

Type descriptions are implemented as subclasses of [XPathType](definitions/type.dart). Types can check if a Dart Object is of their type with [XPathType.matches]. Types can convert any other object to their type with [XPathType.cast].

### Sequences

Sequences are implemented as an `XPathSequence`, a thin wrapper around a Dart [Iterable]. The impelementation is defined in [sequence.dart](types/sequence.dart).

| XPath Type | Dart Type | Type Implementation
| --- | --- | ---
| `sequence` | `XPathSequence` | `xsSequence`
| `empty-sequence` | `XPathSequence` | `xsEmptySequence`

There are various optimized implementations for specific use-cases. Use the most appropriate implementation for a given use-case.

| XPathSequence | Description
| --- | ---
| `XPathSequence.empty` | The empty sequence.
| `XPathSequence.trueSequence` | The sequence with a single `true` value.
| `XPathSequence.falseSequence` | The sequence with a single `false` value.
| `XPathSequence.emptyString` | The sequence with an empty string.
| `XPathSequence.nan` | The sequence with a NaN value.
| `XPathSequence.emptyArray` | The sequence with an empty array.
| `XPathSequence.emptyMap` | The sequence with an empty map.
| `const XPathSequence.single(value)` | The sequence with a single value.
| `const XPathSequence(iterable)` | The sequence of an iterable.
| `XPathSequence.cached(iterable)` | The sequence of an iterable that is at most evaluated once and then cached.
| `XPathSequence.range(start, stop)` | The sequence of integers from start to stop.

### Nodes

XML nodes are represented by the [XmlNode](../../xml/nodes/node.dart) class and its subtypes.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `attribute` | `XmlAttribute` | `xsAttribute`
| `comment` | `XmlComment` | `xsComment`
| `document` | `XmlDocument` | `xsDocument`
| `element` | `XmlElement` | `xsElement`
| `node` | `XmlNode` | `xsNode`
| `namespace` | `XmlNamespace` | `xsNamespace`
| `processing-instruction` | `XmlProcessing` | `xsProcessingInstruction`
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
| `xs:date` | `XPathDate` | `xsDate`
| `xs:dateTime` | `DateTime` | `xsDateTime`
| `xs:dateTimeStamp` | `XPathDateTimeStamp` | `xsDateTimeStamp`
| `xs:dayTimeDuration` | `XPathDayTimeDuration` | `xsDayTimeDuration`
| `xs:duration` | `Duration` | `xsDuration`
| `xs:gDay` | `XPathGDay` | `xsGDay`
| `xs:gMonth` | `XPathGMonth` | `xsGMonth`
| `xs:gMonthDay` | `XPathGMonthDay` | `xsGMonthDay`
| `xs:gYear` | `XPathGYear` | `xsGYear`
| `xs:gYearMonth` | `XPathGYearMonth` | `xsGYearMonth`
| `xs:time` | `XPathTime` | `xsTime`
| `xs:yearMonthDuration` | `XPathYearMonthDuration` | `xsYearMonthDuration`

### Numerics

Numeric values are represented by the Dart `num` class and its subtypes.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:numeric` | `num` | `xsNumeric`
| `xs:byte` | `int` | `xsByte`
| `xs:decimal` | `num` | `xsDecimal`
| `xs:double` | `double` | `xsDouble`
| `xs:float` | `double` | `xsDouble`
| `xs:int` | `int` | `xsInt`
| `xs:integer` | `int` | `xsInteger`
| `xs:long` | `int` | `xsLong`
| `xs:negativeInteger` | `int` | `xsNegativeInteger`
| `xs:nonNegativeInteger` | `int` | `xsNonNegativeInteger`
| `xs:nonPositiveInteger` | `int` | `xsNonPositiveInteger`
| `xs:positiveInteger` | `int` | `xsPositiveInteger`
| `xs:short` | `int` | `xsShort`
| `xs:unsignedByte` | `int` | `xsUnsignedByte`
| `xs:unsignedInt` | `int` | `xsUnsignedInt`
| `xs:unsignedLong` | `int` | `xsUnsignedLong`
| `xs:unsignedShort` | `int` | `xsUnsignedShort`

### Strings

String values are represented by the Dart `String` class.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:string` | `String` | `xsString`
| `xs:normalizedString` | `String` | `xsString`
| `xs:token` | `String` | `xsString`
| `xs:language` | `String` | `xsString`
| `xs:NMTOKEN` | `String` | `xsString`
| `xs:NMTOKENS` | `String` | `xsString`
| `xs:Name` | `String` | `xsString`
| `xs:NCName` | `String` | `xsString`
| `xs:ID` | `String` | `xsString`
| `xs:IDREF` | `String` | `xsString`
| `xs:IDREFS` | `String` | `xsString`
| `xs:ENTITY` | `String` | `xsString`
| `xs:ENTITIES` | `String` | `xsString`

### Booleans

Boolean values are represented by the Dart `bool` class.

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `xs:boolean` | `bool` | `xsBoolean`

### Others

| XPath Type | Dart Type | Implementation
| --- | --- | ---
| `item()` | `Object` | `xsAny`
| `xs:base64Binary` | `XPathBase64Binary` | `xsBase64Binary`
| `xs:hexBinary` | `XPathHexBinary` | `xsHexBinary`
| `xs:anyURI` | `String` | `xsString`
| `xs:QName` | `XmlName` | `xsQName`
| `xs:untyped` | `Object` | `xsAny`
| `xs:untypedAtomic` | `Object` | `xsAny`
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
