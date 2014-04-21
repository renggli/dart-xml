Dart XML
========

Dart XML is a lightweigth library for parsing, traversing, and querying XML documents.

The library is open source, stable and well tested. Development happens on [GitHub](http://github.com/renggli/dart-xml). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/dart-xml).

Continuous build results are available from [Jenkins](http://jenkins.lukas-renggli.ch/job/dart-xml/). An introductionary tutorial is part of the class [documentation](http://jenkins.lukas-renggli.ch/job/dart-xml/javadoc/xml.html).


Basic Usage
-----------

## Installation

Add the dependency to the pacakge's pubspec.yaml file:

    dependencies:
      xml: ">=2.0.0 <3.0.0"

And on the command line run:

    $ pub get

To import the package into your Dart code write:

    import 'package:xml/xml.dart';

## Reading and Writing

To read XML input use the function `parse(String input)`:

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

## Traversing and Querying

Accessors allow to access all nodes in the XML tree:

- `attributes` returns an iterable over the attributes of the current node.
- `children` returns an iterable over the direct children of the current node.

There are helpers to find elements with a specific tag:

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

Finally, there is the `all` iterator:

- `iterable` returns an iterable over the complete sub-tree of the current node in document order. This includes the attributes of the current node, its children, the children of its children, and so on. 

This could for example be used to extract all textual contents from the XML tree:

    var textual = document.iterable
        .where((node) => node is XmlText && !node.text.trim().isEmpty)
        .join('\n');
    print(textual);


Fine Print
----------

## Supports

- Standard well-formed XML and HTML.
- Decodes and encodes commonly used character entities.
- Querying and traversing API using Dart iterators.

## Limitations

- Doens't resolve and validate namespace declarations and usage.
- Doesn't validate any schema declarations.
- Doens't parse and enforce DTD.

## License

The MIT License, see [LICENSE](LICENSE).
