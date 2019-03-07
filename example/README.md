Dart XML Examples
=================

This package contains examples to illustrate the use of [Dart XML](https://github.com/renggli/dart-xml). A tutorial and full documentation is contained in the [package description](https://pub.dartlang.org/packages/xml) and [API documentation](https://pub.dartlang.org/documentation/xml/latest/).

### xml_flatten

This example contains a command-line application that flattens an XML documents from the file-system into a list of events that are printed to the console. For example: 

    dart example/xml_flatten.dart example/books.xml

### xml_pp

This example contains a command-line application that reads XML documents from the file-system and pretty prints the formatted document to the console.

    dart example/xml_pp.dart example/books.xml

### xml_grep

This example contains a command-line application that reads XML documents from the file-system and prints matching tags to the console. For example: 

    dart example/xml_grep.dart -t title example/books.xml