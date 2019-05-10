# Changelog

## 3.5.0

* Dart 2.3 compatibility and requirement.
* Turn various abstract classes into proper mixins.
* Numerous documentation improvements and code optimizations.
* Add an event parser example.

## 3.4.0

* Dart 2.2 compatibility and requirement.
* Take advantage of PetitParser fast-parse mode:
  * 15-30% faster DOM parsing, and
  * 15-50% faster event parsing.
* Improve error messages and reporting.

## 3.3.0

* New event based parsing in `xml_events`:
  * Lazy event parsing from a XML string into an `Iterable` of `XmlEvent`.
  * Async converters between streams of XML, `XmlEvent` and `XmlNode`.
* Clean up package structure by moving internal packages into the `src/` subtree.
* Remove the experimental SAX parser, the event parser allows more flexible streaming XML consumption.

## 3.2.4

* Remove unnecessary whitespace when printing self-closing tags.
* Remember if an element is self-closing for stable printing.

## 3.2.0

* Migrated to PetitParser 2.0

## 3.1.0

* Drop Dart 1.0 compatibility
* Cleanup, optimization and improved documentation
* Add experimental support for SAX parsing

## 3.0.0

* Mutable DOM
* Cleaned up documentation
* Dart 2.0 strong mode compatibility
* Reformatted using dartfmt

## 2.6.0

* Fix CDATA encoding
* Migrate to micro libraries
* Fixed linter issues

## 2.5.0

* Generic Method syntax with Dart 1.21

## 2.4.5

* Do no longer use ArgumentErrors, but instead use proper exceptions.

## 2.4.4

* Fixed attribute escaping
* Preserve single and double quotes

## 2.4.3

* Improved documentation

## 2.4.2

* Use enum as the node type

## 2.4.1

* Fixed attribute escaping

## 2.4.0

* Fixed linter issues
* Cleanup node hierarchy

## 2.3.2

* Improved documentation

## 2.3.1

* Improved test coverage

## 2.3.0

* Improved comments
* Optimize namespaces

## 2.2.2

* Formatted source

## 2.2.1

* Cleanup pretty printing

## 2.2.0

* Improved comments
