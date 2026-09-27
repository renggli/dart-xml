# Dart XML

[![Pub Package](https://img.shields.io/pub/v/xml.svg)](https://pub.dev/packages/xml)
[![Build Status](https://github.com/renggli/dart-xml/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/renggli/dart-xml/actions/workflows/dart.yml)
[![Code Coverage](https://codecov.io/gh/renggli/dart-xml/branch/main/graph/badge.svg?token=TDwmzZtPdj)](https://codecov.io/gh/renggli/dart-xml)
[![GitHub Issues](https://img.shields.io/github/issues/renggli/dart-xml.svg)](https://github.com/renggli/dart-xml/issues)
[![GitHub Forks](https://img.shields.io/github/forks/renggli/dart-xml.svg)](https://github.com/renggli/dart-xml/network)
[![GitHub Stars](https://img.shields.io/github/stars/renggli/dart-xml.svg)](https://github.com/renggli/dart-xml/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/renggli/dart-xml/main/LICENSE)

Dart XML is a lightweight, full-featured XML and XPath library for Dart and Flutter.

- **DOM Model**: In-memory document tree with navigation, querying, mutation, standard W3C position comparison, and customizable serialization.
- **XPath 3.1 & XDM**: W3C-compliant query engine supporting expressions, standard functions and operators, serialization (`fn:serialize`), XML Schema regular expressions, JSON integration, and native maps and arrays.
- **Event-Driven Streaming (SAX)**: Push- and pull-based event streaming via Dart `Iterable` and `Stream` APIs for memory-efficient processing of arbitrary large documents.
- **Fluent Builder**: Declarative, type-safe builder API for constructing XML documents and fragments.
- **Zero Overhead**: Fast and portable across Dart VM, Flutter, and Web (Wasm & JavaScript), built on [PetitParser](https://github.com/petitparser/dart-petitparser).

## Installation

Add `xml` as a dependency to your `pubspec.yaml` or run:

```bash
dart pub add xml
```

Import the primary XML library:

```dart
import 'package:xml/xml.dart';
```

> [!TIP]
> This library makes extensive use of [static extension methods](https://dart.dev/language/extension-methods). Avoid using import prefixes or selective `show` clauses that hide extension members. For collision avoidance, public DOM classes carry an `Xml` prefix.

## Reading and Writing

Parse XML into an `XmlDocument` tree using `XmlDocument.parse()`:

```dart
final bookshelfXml = '''<?xml version="1.0"?>
<bookshelf>
  <book>
    <title lang="en">Growing a Language</title>
    <price>29.99</price>
  </book>
  <book>
    <title lang="en">Learning XML</title>
    <price>39.95</price>
  </book>
  <price>132.00</price>
</bookshelf>''';

final document = XmlDocument.parse(bookshelfXml);
```

If the document is malformed, an `XmlParserException` (subclass of `XmlException`) is thrown with exact line and column coordinates.

### Serialization and Pretty Printing

Serialize any node back to XML using `toString()` or `toXmlString()`:

```dart
// Compact serialization:
print(document.toString());

// Formatted pretty printing with custom indentation:
print(document.toXmlString(pretty: true, indent: '  '));
```

### File I/O

Read files using [`dart:io`](https://api.dart.dev/stable/dart-io/dart-io-library.html):

```dart
import 'dart:io';

final file = File('bookshelf.xml');
final document = XmlDocument.parse(file.readAsStringSync());
```

For large files that should not be fully buffered into memory, use the [streaming event-driven API](#event-driven-streaming).

## Traversing and Querying

### Accessors and Mutation

Nodes provide mutable lists for structural manipulation:

- `attributes`: Attributes declared on this node.
- `elementAttributes`: Attributes excluding namespace declarations (`xmlns` or `xmlns:*`).
- `children`: Direct child nodes of this node.

Lists support standard `List` methods (`add`, `addAll`, `insert`, `remove`). Inserting nodes automatically detaches them from any existing parent and moves them into position. Fragments (`XmlDocumentFragment`) are expanded in-place.

### Traversal Axes

Navigate the DOM along document order axes:

- `descendants`: All descendants in document order (attributes, child elements, text, etc.).
- `ancestors`: Preceding ancestor chain up to the root (reverse document order).
- `siblings`: Sibling nodes at the same tree level.
- `preceding`: Nodes preceding the opening tag of the current node in document order.
- `following`: Nodes following the closing tag of the current node in document order.

Convenience getters filter these axes for element nodes only: `childElements`, `descendantElements`, `ancestorElements`, `siblingElements`, `precedingElements`, and `followingElements`.

```dart
// Extract all text content from the document:
final text = document.descendants
    .whereType<XmlText>()
    .map((node) => node.value.trim())
    .where((str) => str.isNotEmpty)
    .join('\n');
```

### Element Searching

Find elements by tag name:

- `getElement(String name)`: First direct child element with matching name, or `null`.
- `findElements(String name)`: Direct child elements matching name.
- `findAllElements(String name)`: Recursive descendants matching name.

```dart
// Find all titles:
final titles = document.findAllElements('title')
    .map((element) => element.innerText);
// ['Growing a Language', 'Learning XML']

// Calculate the total book prices:
final total = document.findAllElements('book')
    .map((book) => double.parse(book.findElements('price').single.innerText))
    .reduce((a, b) => a + b);
print(total); // 69.94
```

### Node Comparison & Document Position

Compare nodes using standard DOM Level 3 / DOM 4 semantics:

```dart
// Structural equality comparison:
final isSame = nodeA.isEqualNode(nodeB);

// Bitmask position comparison:
final position = nodeA.compareDocumentPosition(nodeB);
if (position.isPreceding) {
  print('nodeA precedes nodeB in document order');
}
```

## XPath 3.1 & XDM

PetitXml includes a comprehensive, high-performance W3C [XPath 3.1](https://www.w3.org/TR/xpath-31/) implementation.

To enable XPath on DOM nodes, import:

```dart
import 'package:xml/xpath.dart';
```

### Node Selection (`xpath`)

`XmlNode.xpath(String expression)` evaluates an expression and returns a lazy `Iterable<XmlNode>`:

```dart
// Find all books:
final books = document.xpath('/bookshelf/book');

// Find the second book (1-based index):
final secondBook = document.xpath('/bookshelf/book[2]');

// Find elements by attribute value:
final englishTitles = document.xpath('//title[@lang="en"]');

// Predicate with relative path:
final englishBooks = document.xpath('//book[title/@lang="en"]');
```

### Full XDM Evaluation (`xpathEvaluate`)

`XmlNode.xpathEvaluate(String expression)` evaluates expressions returning an `XPathSequence` containing nodes, atomic values, functions, maps, or arrays:

```dart
// Evaluate XPath functions directly:
final totalPrice = document.xpathEvaluate('sum(//book/price)').single;
print(totalPrice.toValue()); // 69.94

// Count matching nodes:
final bookCount = document.xpathEvaluate('count(//book)').single;
print(bookCount.toValue()); // 2

// String and regex operations:
final joined = document.xpathEvaluate('string-join(//title, ", ")').single;
print(joined.toValue()); // 'Growing a Language, Learning XML'
```

### Reverse XPath Generation

Generate a canonical XPath expression leading to any node in the document:

```dart
final title = document.findAllElements('title').first;
print(title.xpathGenerate()); // /bookshelf/book[1]/title
```

### Configuration and Extensibility

Pass an `XPathConfiguration` to customize variables, extension functions, namespaces, and document loaders:

```dart
final config = XPathConfiguration.standard(
  variables: {'taxRate': 0.08},
  namespaces: {'bk': 'https://example.com/books'},
);

final result = document.xpathEvaluate(
  '//book/price * (1 + \$taxRate)',
  configuration: config,
);
```

## Building XML

The `XmlBuilder` class provides a declarative, fluent API to construct XML structures programmatically:

```dart
final builder = XmlBuilder();
builder.processing('xml', 'version="1.0"');
builder.element('bookshelf', nest: () {
  builder.element('book', nest: () {
    builder.element('title', nest: () {
      builder.attribute('lang', 'en');
      builder.text('Growing a Language');
    });
    builder.element('price', nest: 29.99);
  });
  builder.element('book', nest: () {
    builder.element('title', nest: () {
      builder.attribute('lang', 'en');
      builder.text('Learning XML');
    });
    builder.element('price', nest: 39.95);
  });
  builder.element('price', nest: 132.00);
});

final document = builder.buildDocument();
```

Modular builder methods can be composed to assemble nested document fragments:

```dart
void buildBook(XmlBuilder builder, String title, String lang, num price) {
  builder.element('book', nest: () {
    builder.element('title', nest: () {
      builder.attribute('lang', lang);
      builder.text(title);
    });
    builder.element('price', nest: price);
  });
}

final builder = XmlBuilder();
buildBook(builder, 'The War of the Worlds', 'en', 12.50);
buildBook(builder, 'Voyages extraordinaires', 'fr', 18.20);

// Attach the generated fragment into an existing tree:
document.rootElement.children.add(builder.buildFragment());
```

## Event-Driven Streaming

For large files or streaming network sources where buffering an entire DOM tree in memory is impractical, use the event-driven SAX parser:

```dart
import 'package:xml/xml_events.dart';
```

### Lazy Iterables

Parse an XML string incrementally on-demand:

```dart
parseEvents(bookshelfXml)
    .whereType<XmlTextEvent>()
    .map((event) => event.value.trim())
    .where((text) => text.isNotEmpty)
    .forEach(print);
```

### Asynchronous Streams

Process asynchronous streams from files or HTTP connections using stream transformers:

```dart
final file = File('large_sitemap.xml');

await file.openRead()
    .transform(utf8.decoder)
    .toXmlEvents()
    .normalizeEvents()
    .selectSubtreeEvents((event) => event.name == 'loc')
    .toXmlNodes()
    .expand((nodes) => nodes)
    .forEach((node) => print(node.innerText));
```

### Hierarchical Context & Namespaces

Enable `withParent: true` and `withNamespace: true` to annotate events with parent linkages and resolved namespace URIs:

```dart
const shiporderXsd = '''<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="shiporder">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="orderperson" type="xs:string"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>''';

await Stream.fromIterable([shiporderXsd])
    .toXmlEvents(withNamespace: true, withParent: true)
    .normalizeEvents()
    .selectSubtreeEvents((event) =>
        event.localName == 'element' &&
        event.namespaceUri == 'http://www.w3.org/2001/XMLSchema')
    .toXmlNodes()
    .expand((nodes) => nodes)
    .forEach((node) => print(node.toXmlString(pretty: true)));
```

## Command-Line Tools & Examples

The repository includes runnable command-line applications in the [`example/`](https://github.com/renggli/dart-xml/tree/main/example) directory:

- **XPath Query Tool**: Evaluate XPath 3.1 expressions against files or inline computations:

  ```bash
  dart run example/xml_xpath.dart -x "//book/title" example/books.xml
  dart run example/xml_xpath.dart "1 + 2 * 3"
  ```

- **Pretty Printer & Highlighter**: Format and colorize XML files in the terminal:

  ```bash
  dart run example/xml_pp.dart example/books.xml
  ```

- **Source Position Locator**: Determine character positions and line numbers for DOM nodes:

  ```bash
  dart run example/xml_pos.dart example/books.xml
  ```

- **Online Demo**: Try the interactive parser in your browser at the [PetitParser Web Demo](https://petitparser.github.io/examples/xml/xml.html).

## Standards Compliance

PetitXml conforms to the following official W3C specifications:

- [Extensible Markup Language (XML) 1.0 (Fifth Edition)](https://www.w3.org/TR/xml/)
- [Namespaces in XML 1.0 (Third Edition)](https://www.w3.org/TR/xml-names/)
- [XML Path Language (XPath) 3.1](https://www.w3.org/TR/xpath-31/)
- [XPath and XQuery Functions and Operators 3.1](https://www.w3.org/TR/xpath-functions-31/)
- [W3C DOM4](https://www.w3.org/TR/domcore/) / [DOM Level 3 Core](https://www.w3.org/TR/DOM-Level-3-Core/)

### Scope and Limitations

- **Schema Validation**: Does not validate against XML Schema (XSD) definitions.
- **DTD Enforcement**: Basic DTD parsing is supported (`XmlDoctype`), but external DTD entity resolution and validation are not enforced.
- **XSLT / XQuery**: XSLT transformations and full XQuery modules are outside the scope of this package.

## History & License

Dart XML originated as an example parser for the [PetitParser](https://github.com/petitparser/dart-petitparser) framework and replaced the original `dart-xml` package in April 2014.

Released under the [MIT License](https://raw.githubusercontent.com/renggli/dart-xml/main/LICENSE).
