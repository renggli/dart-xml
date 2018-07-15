library xml.reader;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/parser.dart';
import 'package:xml/xml/production.dart';
import 'package:xml/xml/utils/name.dart';
import 'package:xml/xml/utils/token.dart';

// Definition of the XML productions.
final _production = new XmlProductionDefinition();
final _parser = new XmlParserDefinition();

// Build the basic elements of the XML grammar.
final _characterData = _production.build(start: _production.characterData);
final _elementStart = char(XmlToken.openElement)
    .seq(_parser.build(start: _parser.qualified))
    .seq(_parser.build(start: _parser.attributes))
    .seq(whitespace().star())
    .seq(string(XmlToken.closeEndElement).or(char(XmlToken.closeElement)));
final _elementEnd = string(XmlToken.openEndElement)
    .seq(_parser.build(start: _parser.qualified))
    .seq(whitespace().star())
    .seq(char(XmlToken.closeElement));
final _comment = _production.build(start: _production.comment);
final _cdata = _production.build(start: _production.cdata);
final _processing = _production.build(start: _production.processing);
final _doctype = _production.build(start: _production.doctype);

typedef void StartDocumentHandler();
typedef void EndDocumentHandler();
typedef void StartElementHandler(XmlName name, List<XmlAttribute> attributes);
typedef void EndElementHandler(XmlName name);
typedef void CharacterDataHandler(String text);
typedef void ProcessingInstructionHandler(String target, String data);
typedef void ParseErrorHandler(int position);
typedef void FatalErrorHandler(int position, Error error);

/// Dart SAX is a "Simple API for XML" parsing.
class XmlReader {

  // Event handlers
  final StartDocumentHandler onStartDocument;
  final EndDocumentHandler onEndDocument;
  final StartElementHandler onStartElement;
  final EndElementHandler onEndElement;
  final CharacterDataHandler onCharacterData;
  final ProcessingInstructionHandler onProcessingInstruction;

  // Error handlers
  final ParseErrorHandler onParseError;
  final FatalErrorHandler onFatalError;

  XmlReader(
      {this.onStartDocument,
      this.onEndDocument,
      this.onStartElement,
      this.onEndElement,
      this.onCharacterData,
      this.onProcessingInstruction,
      this.onParseError,
      this.onFatalError});

  void parse(String input) {
    Result result = new Success(input, 0, null);
    try {
      onStartDocument?.call();
      while (result.isSuccess && result.position < input.length) {
        result = _parseEvent(result);
      }
    } on Error catch (error) {
      onFatalError?.call(result.position, error);
    } finally {
      onEndDocument?.call();
    }
  }

  Result _parseEvent(Result context) {
    // Parse textual character data:
    Result result = _characterData.parseOn(context);
    if (result.isSuccess) {
      onCharacterData?.call(result.value);
      return result;
    }

    // Parse the start of an element:
    result = _elementStart.parseOn(context);
    if (result.isSuccess) {
      onStartElement?.call(
        result.value[1],
        new List<XmlAttribute>.from(result.value[2]),
      );
      if (result.value[4] == XmlToken.closeEndElement) {
        onEndElement?.call(result.value[1]);
      }
      return result;
    }

    // Parse the end of an element:
    result = _elementEnd.parseOn(context);
    if (result.isSuccess) {
      onEndElement?.call(result.value[1]);
      return result;
    }

    // Skip over comments:
    result = _comment.parseOn(context);
    if (result.isSuccess) {
      return result;
    }

    // Parse CDATA as character data:
    result = _cdata.parseOn(context);
    if (result.isSuccess) {
      onCharacterData?.call(result.value[1]);
      return result;
    }

    // Parse processing instruction:
    result = _processing.parseOn(context);
    if (result.isSuccess) {
      onProcessingInstruction?.call(result.value[0], result.value[1]);
      return result;
    }

    // Parse doctype:
    result = _doctype.parseOn(context);
    if (result.isSuccess) {
      // skip over it (for now)
      return result;
    }

    // Skip to the next character in case of a problem
    onParseError?.call(context.position);
    return context.success(null, context.position + 1);
  }
}
