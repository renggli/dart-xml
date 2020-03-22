Dart XML Examples
=================

This package contains examples to illustrate the use of [Dart XML](https://github.com/renggli/dart-xml). A tutorial and full documentation is contained in the [package description](https://pub.dev/packages/xml) and [API documentation](https://pub.dev/documentation/xml/latest/).

### ip_lookup

This example performs an API call to [ip-api.com](http://ip-api.com/) to search for IP and domain meta-data. If no query is provided the current IP address will be used. Various options can be changed over the command line arguments.

```bash
dart example/ip_api.dart --help
dart example/ip_api.dart --fields=query,city,country
```

### xml_flatten

This example contains a command-line application that flattens an XML documents from the file-system into a list of events that are printed to the console. For example: 

```bash
dart example/xml_flatten.dart example/books.xml
```

### xml_grep

This example contains a command-line application that reads XML documents from the file-system and prints matching tags to the console. For example: 

```bash
dart example/xml_grep.dart -t title example/books.xml
```

### xml_pos

This example contains a command-line application that uses a custom XML parser that collects the tokens of each XML node while parsing. This allows to print line and column information in the original document.

```bash
dart example/xml_pos.dart example/books.xml
```

### xml_pp

This example contains a command-line application that reads XML documents from the file-system and pretty prints and syntax highlights the formatted document to the console.

```bash
dart example/xml_pp.dart example/books.xml
```
