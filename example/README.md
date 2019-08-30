Dart XML Examples
=================

This package contains examples to illustrate the use of [Dart XML](https://github.com/renggli/dart-xml). A tutorial and full documentation is contained in the [package description](https://pub.dartlang.org/packages/xml) and [API documentation](https://pub.dartlang.org/documentation/xml/latest/).

### ip_lookup

This example performs an API call to [ip-api.com](http://ip-api.com/) to search for IP and domain meta-data. If no query is provided the current IP address will be used. Various options can be changed over the command line arguments.

    dart example/ip.dart example/books.xml

### xml_flatten

This example contains a command-line application that flattens an XML documents from the file-system into a list of events that are printed to the console. For example: 

    dart example/xml_flatten.dart example/books.xml

### xml_pp

This example contains a command-line application that reads XML documents from the file-system and pretty prints the formatted document to the console.

    dart example/xml_pp.dart example/books.xml

### xml_grep

This example contains a command-line application that reads XML documents from the file-system and prints matching tags to the console. For example: 

    dart example/xml_grep.dart -t title example/books.xml