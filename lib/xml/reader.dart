library xml.reader;

import 'dart:collection';

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/parser.dart';
import 'package:xml/xml/production.dart';
import 'package:xml/xml/utils/name.dart';
import 'package:xml/xml/utils/node_list.dart';
import 'package:xml/xml/utils/node_type.dart';
import 'package:xml/xml/utils/token.dart';

// Definition of the XML productions.
final _production = XmlProductionDefinition();
final _parser = XmlParserDefinition();

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

// Callbacks used for SAX parsing.
typedef void StartDocumentHandler();
typedef void EndDocumentHandler();
typedef void StartElementHandler(
    XmlName name, XmlNodeList<XmlAttribute> attributes);
typedef void EndElementHandler(XmlName name);
typedef void CharacterDataHandler(String text);
typedef void ProcessingInstructionHandler(String target, String text);
typedef void DoctypeHandler(String text);
typedef void CommentHandler(String comment);
typedef void ParseErrorHandler(int position);
typedef void FatalExceptionHandler(int position, Exception exception);

/// Dart SAX is a "Simple API for XML" parsing.
class XmlReader {
  // Event handlers
  final StartDocumentHandler onStartDocument;
  final EndDocumentHandler onEndDocument;
  final StartElementHandler onStartElement;
  final EndElementHandler onEndElement;
  final CharacterDataHandler onCharacterData;
  final ProcessingInstructionHandler onProcessingInstruction;
  final DoctypeHandler onDoctype;
  final CommentHandler onComment;

  // Error handlers
  final ParseErrorHandler onParseError;

  /// Constructor of a SAX reader with its event handlers.
  XmlReader(
      {this.onStartDocument,
      this.onEndDocument,
      this.onStartElement,
      this.onEndElement,
      this.onCharacterData,
      this.onProcessingInstruction,
      this.onDoctype,
      this.onComment,
      this.onParseError});

  /// Parse an input string and trigger all related events.
  void parse(String input) {
    Result result = Success(input, 0, null);
    onStartDocument?.call();
    while (result.position < input.length) {
      result = _parseEvent(result);
    }
    onEndDocument?.call();
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
        XmlNodeList(attributeNodeTypes)
          ..addAll(List<XmlAttribute>.from(result.value[2])),
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

    // Parse comments:
    result = _comment.parseOn(context);
    if (result.isSuccess) {
      onComment?.call(result.value[1]);
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
      onProcessingInstruction?.call(result.value[1], result.value[2]);
      return result;
    }

    // Parse docytpes:
    result = _doctype.parseOn(context);
    if (result.isSuccess) {
      onDoctype?.call(result.value[2]);
      return result;
    }

    // Skip to the next character when there is a problem:
    onParseError?.call(context.position);
    return context.success(null, context.position + 1);
  }
}

/// A push based XmlReader interface, intended to be similar to .NET's XmlReader.
class XmlTextReader {
  /// Creates a new reader for `input`.
  ///
  /// Setting `ignoreWhitespace` to false will cause text nodes
  XmlTextReader(String input, {this.ignoreWhitespace = true}) {
    _result = Success(input, 0, null);
    _depth = 0;
    _eof = false;
  }

  /// If true, will ignore `XmlNodeType.TEXT` and when it is composed of whitespace.
  bool ignoreWhitespace;

  /// Parsing context.
  Result _result;

  /// The [XmlNodeType] of the current position of the reader.
  XmlNodeType get nodeType => _nodeType;
  XmlNodeType _nodeType;

  /// The [XmlName] of the current node of the reader.
  XmlName get name => _name;
  XmlName _name;

  /// The value of the current node of the reader.
  ///
  /// The value will have
  String get value => _value;
  String _value;

  /// Will return true if `nodeType == XmlNodeType.ELEMENT` and the element is self closing,
  /// e.g. `<element />`.
  bool get isEmptyElement => _isEmptyElement;
  bool _isEmptyElement;

  /// The zero based depth of the reader.
  int get depth => _depth;
  int _depth;

  /// True if the reader is positioned at the end of the buffer.
  bool get eof => _eof;
  bool _eof;

  /// The `List<XmlAttribute>` of the current element (if `nodeType == XmlNodeType.ELEMENT`).
  UnmodifiableListView<XmlAttribute> get attributes =>
      UnmodifiableListView<XmlAttribute>(_attributes);
  List<XmlAttribute> _attributes;

  /// Advances the reader to the next readable position.  Returns true if more data remains, false if not.
  bool read() {
    if (_result.position > _result.buffer.length) {
      _eof = true;
      return false;
    }

    _result = _parseEvent(_result);
    return (_result.isSuccess);
  }

  Result _parseEvent(Result context) {
    _attributes = <XmlAttribute>[];

    if (_isEmptyElement == true) {
      _depth--;
    }

    _isEmptyElement = null;
    _value = null;
    _nodeType = null;

    Result result = _characterData.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.TEXT;
      _value = result.value.trim();
      if (_value == '') {
        return _parseEvent(result);
      }
      return result;
    }

    result = _elementStart.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.ELEMENT;
      _name = result.value[1];
      _depth++;
      _attributes = List<XmlAttribute>.from(result.value[2]);
      if (result.value[4] == XmlToken.closeEndElement) {
        // _depth--;
        _isEmptyElement = true;
      } else {
        _isEmptyElement = false;
      }
      return result;
    }

    result = _elementEnd.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.END_ELEMENT;
      _name = result.value[1];
      _depth--;
      return result;
    }

    result = _comment.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.COMMENT;
      _value = result.value[1];
      return result;
    }

    // Parse CDATA as character data:
    result = _cdata.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.CDATA;
      _value = result.value[1];
      return result;
    }

    // Parse processing instruction:
    result = _processing.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.PROCESSING;
      _value = result.value[2];
      return result;
    }

    // Parse docytpes:
    result = _doctype.parseOn(context);
    if (result.isSuccess) {
      _nodeType = XmlNodeType.DOCUMENT_TYPE;
      _value = result.value[2];
      return result;
    }

    if (context.position == context.buffer.length) {
      _eof = true;
      return context.failure('EOF');
    }
    // Skip to the next character when there is a problem:
    return context.success(null, context.position + 1);
  }

  @override
  String toString() => eof
      ? 'XmlTextReader{EOF}'
      : 'XmlTextReader{$depth $nodeType $name $value $attributes}';
}
