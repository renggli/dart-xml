import 'package:collection/collection.dart';

import '../../xml/exceptions/namespace_exception.dart';
import '../../xml/exceptions/parser_exception.dart';
import '../../xml/exceptions/tag_exception.dart';
import '../../xml/utils/namespace.dart' as ns;
import '../event.dart';
import '../events/declaration.dart';
import '../events/doctype.dart';
import '../events/end_element.dart';
import '../events/start_element.dart';
import '../utils/event_attribute.dart';
import 'has_name.dart';

/// Annotates [XmlEvent] instances with metadata, such as the underlying buffer,
/// the position in said buffer, the parent event, and namespaces. This class
/// also has the ability to validate parents and namespaces.
class XmlAnnotator {
  XmlAnnotator({
    required this.validateNesting,
    required this.validateNamespace,
    required this.validateDocument,
    required this.withBuffer,
    required this.withLocation,
    required this.withNamespace,
    required this.withParent,
  });

  final bool validateNesting;
  final bool validateNamespace;
  final bool validateDocument;
  final bool withBuffer;
  final bool withLocation;
  final bool withNamespace;
  final bool withParent;

  // State to validate parent relationship.
  final List<XmlStartElementEvent> _parents = [];

  // State with the active namespace declarations.
  final Map<String?, List<String?>> _namespaces = {};

  // State to validate document root.
  var _hasDeclaration = false;
  var _hasDoctype = false;
  var _hasElement = false;

  void annotate(XmlEvent event, {String? buffer, int? start, int? stop}) {
    if (withBuffer) {
      event.attachBuffer(buffer);
    }
    if (withLocation) {
      event.attachLocation(start, stop);
    }
    if (withParent && _parents.isNotEmpty) {
      event.attachParent(_parents.last);
    }
    if (withNamespace || validateNamespace) {
      _handleNamespace(event, buffer, start);
    }
    if (validateDocument) {
      _handleDocument(event, buffer, start);
    }
    _handleParent(event, buffer, start);
  }

  void close({String? buffer, int? position}) {
    // Validate the parent relationship.
    if (validateNesting && _parents.isNotEmpty) {
      throw XmlTagException.missingClosingTag(
        _parents.last.name,
        buffer: buffer,
        position: position,
      );
    }
    // Validate the document root events.
    if (validateDocument && !_hasElement) {
      throw XmlParserException(
        'Expected a single root element',
        buffer: buffer,
        position: position,
      );
    }
  }

  // Keep track and attach namespace declarations.
  void _handleNamespace(XmlEvent event, String? buffer, int? start) {
    switch (event) {
      case XmlStartElementEvent():
        for (final attribute in event.attributes) {
          _addNamespace(attribute);
        }
        _annotateNamespaceUri(event, buffer, start);
        for (final attribute in event.attributes) {
          _annotateNamespaceUri(attribute, buffer, start);
        }
        if (event.isSelfClosing) {
          for (final attribute in event.attributes) {
            _removeNamespace(attribute);
          }
        }
      case XmlEndElementEvent():
        _annotateNamespaceUri(event, buffer, start);
        if (_parents.isNotEmpty) {
          for (final attribute in _parents.last.attributes) {
            _removeNamespace(attribute);
          }
        }
    }
  }

  // Keeps track of a possible namespace declaration.
  void _addNamespace(XmlEventAttribute attribute) {
    if (attribute.name == ns.xmlns) {
      _namespaces
          .putIfAbsent(null, () => [])
          .add(attribute.value.isEmpty ? null : attribute.value);
    } else if (attribute.namespacePrefix == ns.xmlns) {
      _namespaces
          .putIfAbsent(attribute.localName, () => [])
          .add(attribute.value.isEmpty ? null : attribute.value);
    }
  }

  // Removes a possible namespace declaration.
  void _removeNamespace(XmlEventAttribute attribute) {
    if (attribute.name == ns.xmlns) {
      _namespaces[null]!.removeLast();
    } else if (attribute.namespacePrefix == ns.xmlns) {
      _namespaces[attribute.localName]!.removeLast();
    }
  }

  // Attach and validate the namespace.
  void _annotateNamespaceUri(XmlHasName name, String? buffer, int? start) {
    final namespacePrefix = name.namespacePrefix;
    final namespaceUri =
        // XML namespace.
        namespacePrefix == ns.xml
        ? ns.xmlUri
        // XML namespace declaration.
        : namespacePrefix == ns.xmlns || name.qualifiedName == ns.xmlns
        ? ns.xmlnsUri
        // User defined namespace.
        : _namespaces[namespacePrefix]?.lastOrNull;
    if (withNamespace && namespaceUri != null) {
      name.attachNamespace(namespaceUri);
    }
    if (validateNamespace && namespaceUri == null && namespacePrefix != null) {
      throw XmlNamespaceException.unknownNamespacePrefix(
        namespacePrefix,
        buffer: buffer,
        position: start,
      );
    }
  }

  // Validate the document root events.
  void _handleDocument(XmlEvent event, String? buffer, int? start) {
    if (_parents.isNotEmpty) return;
    switch (event) {
      case XmlDeclarationEvent():
        if (_hasDeclaration) {
          throw XmlParserException(
            'Expected at most one XML declaration',
            buffer: buffer,
            position: start,
          );
        } else if (_hasDoctype || _hasElement) {
          throw XmlParserException(
            'Unexpected XML declaration',
            buffer: buffer,
            position: start,
          );
        }
        _hasDeclaration = true;
      case XmlDoctypeEvent():
        if (_hasDoctype) {
          throw XmlParserException(
            'Expected at most one doctype declaration',
            buffer: buffer,
            position: start,
          );
        } else if (_hasElement) {
          throw XmlParserException(
            'Unexpected doctype declaration',
            buffer: buffer,
            position: start,
          );
        }
        _hasDoctype = true;
      case XmlStartElementEvent():
        if (_hasElement) {
          throw XmlParserException(
            'Unexpected root element',
            buffer: buffer,
            position: start,
          );
        }
        _hasElement = true;
    }
  }

  // Handle the parent relationship.
  void _handleParent(XmlEvent event, String? buffer, int? start) {
    switch (event) {
      case XmlStartElementEvent():
        if (withParent) {
          for (final attribute in event.attributes) {
            attribute.attachParent(event);
          }
        }
        if (!event.isSelfClosing) {
          _parents.add(event);
        }
      case XmlEndElementEvent():
        if (validateNesting) {
          if (_parents.isEmpty) {
            throw XmlTagException.unexpectedClosingTag(
              event.name,
              buffer: buffer,
              position: start,
            );
          } else if (_parents.last.name != event.name) {
            throw XmlTagException.mismatchClosingTag(
              _parents.last.name,
              event.name,
              buffer: buffer,
              position: start,
            );
          }
        }
        if (_parents.isNotEmpty) {
          _parents.removeLast();
        }
    }
  }
}
