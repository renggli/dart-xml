/**
 * Dart XML is a lightweight library for parsing, traversing, and
 * querying XML documents.
 */
library xml;

import 'dart:collection';

import 'package:petitparser/petitparser.dart';

part 'xml/nodes/attribute.dart';
part 'xml/nodes/cdata.dart';
part 'xml/nodes/comment.dart';
part 'xml/nodes/data.dart';
part 'xml/nodes/doctype.dart';
part 'xml/nodes/document.dart';
part 'xml/nodes/element.dart';
part 'xml/nodes/node.dart';
part 'xml/nodes/parent.dart';
part 'xml/nodes/processing.dart';
part 'xml/nodes/text.dart';

part 'xml/utils/entities.dart';
part 'xml/utils/iterator.dart';
part 'xml/utils/name.dart';
part 'xml/utils/type.dart';
part 'xml/utils/writable.dart';

part 'xml/grammar.dart';
part 'xml/parser.dart';

final XmlParser _PARSER = new XmlParser();

/**
 * Return an [XmlDocument] for the given [input] string, or throws a
 * [ParserError] if the input is invalid.
 */
XmlDocument parse(String input) => _PARSER.parse(input).value;
