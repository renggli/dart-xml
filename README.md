Dart XML
========

Dart XML is a lightweight library for parsing, traversing, and querying XML documents.

This library is open source, stable and well tested. Development happens on [GitHub](http://github.com/renggli/dart-xml). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/dart+xml).

Continuous build results are available from [Jenkins](http://jenkins.lukas-renggli.ch/job/dart-xml/). Up-to-date [documentation](http://jenkins.lukas-renggli.ch/job/dart-xml/javadoc/) is created automatically with every new push.


Basic Usage
-----------

### Installation

Add the dependency to your package's pubspec.yaml file:

    dependencies:
      xml: ">=2.0.0 <3.0.0"

Then on the command line run:

    $ pub get

To import the package into your Dart code write:

    import 'package:xml/xml.dart';

### Reading and Writing

To read XML input use the top-level function `parse(String input)`:

    var bookshelfXml = '''<?xml version="1.0"?>
        <bookshelf>
          <book>
            <title lang="english">Growing a Language</title>
            <price>29.99</price>
          </book>
          <book>
            <title lang="english">Learning XML</title>
            <price>39.95</price>
          </book>
          <price>132.00</price>
        </bookshelf>''';
    var document = parse(bookshelfXml);

The resulting object is an instance of `XmlDocument`. In case the document cannot be parsed, a `ParseError` is thrown.

To write back the parsed XML document simply call `toString()`:

    print(document.toString());

### Traversing and Querying

Accessors allow to access nodes in the XML tree:

- `attributes` returns an iterable over the attributes of the current node.
- `children` returns an iterable over the children of the current node.

There are various methods to traverse the XML tree along its axes:

- `preceding` returns an iterable over nodes preceding the opening tag of the current node in document order.
- `descendants` returns an iterable over the descendants of the current node in document order. This includes the attributes of the current node, its children, the grandchildren, and so on.
- `following` the nodes following the closing tag of the current node in document order.
- `ancestors` returns an iterable over the ancestor nodes of the current node, that is the parent, the grandparent, and so on. Note that this is the only iterable that traverses nodes in reverse document order.

For example, the `descendants` iterator could be used to extract all textual contents from an XML tree:

    var textual = document.descendants
        .where((node) => node is XmlText && !node.text.trim().isEmpty)
        .join('\n');
    print(textual);

Additionally, there are helpers to find elements with a specific tag:

- `findElements(String name)` finds direct children of the current node with the provided tag `name`.
- `findAllElements(String name)` finds direct and indirect children of the current node with the provided tag `name`.

For example, to find all the nodes with the _<title>_ tag you could write:

    var titles = document.findAllElements('title');

This returns a lazy iterator that recursively walks through the XML document and yields all the element nodes with the requested tag name. To extract the textual contents call `text`:

    titles
        .map((node) => node.text)
        .forEach(print);

This prints _Growing a Language_ and _Learning XML_.

Similary, to compute the total price of all the books one could write the following expression:

    var total = document.findAllElements('book')
        .map((node) => double.parse(node.findElements('price').single.text))
        .reduce((a, b) => a + b);
    print(total);

Note that this first find all the books, and then extracts the price to avoid counting the price tag that is included in the bookshelf.

Misc
----

### Supports

- Standard well-formed XML and HTML.
- Decodes and encodes commonly used character entities.
- Querying and traversing API using Dart iterators.

### Limitations

- Doesn't validate namespace declarations.
- Doesn't validate schema declarations.
- Doesn't parse and enforce DTD.

### History

This library started as an example of the [PetitParser](https://github.com/renggli/PetitParserDart) library. To my own surprise various people started to use it to read XML files. In April 2014 I was asked to replace the original [dart-xml](https://github.com/prujohn/dart-xml) library from John Evans.

### License

The MIT License, see [LICENSE](LICENSE).
