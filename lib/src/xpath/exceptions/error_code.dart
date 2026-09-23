// ignore_for_file: constant_identifier_names

import '../../xml/utils/name.dart';
import '../xdm/atomic/qname.dart';

/// XPath 3.1 and XQuery standard error codes.
///
/// See <https://www.w3.org/2005/xqt-errors/> for details.
enum XPathErrorCode {
  // Functions and Operators: Function application
  FOAP0001('Wrong number of arguments'),

  // Functions and Operators: Arithmetic
  FOAR0001('Division by zero'),
  FOAR0002('Numeric operation overflow/underflow'),

  // Functions and Operators: Arrays
  FOAY0001('Array index out of bounds'),
  FOAY0002('Negative array length'),

  // Functions and Operators: Casting and Type Conversion
  FOCA0001('Input value too large for decimal'),
  FOCA0002('Invalid lexical value'),
  FOCA0003('Input value too large for integer'),
  FOCA0005('NaN supplied as float/double value'),
  FOCA0006('String to be cast to decimal has too many digits of precision'),

  // Functions and Operators: Characters and Collation
  FOCH0001('Codepoint not valid'),
  FOCH0002('Unsupported collation'),
  FOCH0003('Unsupported normalization form'),
  FOCH0004('Collation does not support collation units'),

  // Functions and Operators: Documents and Collections
  FODC0001('No context document'),
  FODC0002('Error retrieving resource'),
  FODC0003('Function not defined as deterministic'),
  FODC0004('Invalid collection URI'),
  FODC0005('Invalid argument to fn:doc or fn:doc-available'),
  FODC0006('String passed to fn:parse-xml is not a well-formed XML document'),

  // Functions and Operators: Date and Time
  FODT0001('Overflow/underflow in date/time operation'),
  FODT0002('Overflow/underflow in duration operation'),
  FODT0003('Invalid timezone value'),

  // Functions and Operators: Error function
  FOER0000('Unidentified error'),

  // Functions and Operators: JSON
  FOJS0001('JSON syntax error'),
  FOJS0003('JSON duplicate keys'),
  FOJS0005('Invalid options'),
  FOJS0006('Invalid XML representation of JSON'),
  FOJS0007('Bad JSON escape sequence'),

  // Functions and Operators: Namespaces
  FONS0004('No namespace found for prefix'),

  // Functions and Operators: Regular Expressions and General
  FORG0001('Invalid value for cast/constructor'),
  FORG0002('Invalid argument to fn:resolve-uri()'),
  FORG0003('Sequence contains more than one item'),
  FORG0004('Sequence is empty'),
  FORG0005('Sequence does not contain exactly one item'),
  FORG0006('Invalid argument type'),
  FORG0008('Both arguments to fn:dateTime have a specified timezone'),
  FORG0010('Invalid date/time'),

  // Functions and Operators: Regular Expressions
  FORX0001('Invalid regular expression flags'),
  FORX0002('Invalid regular expression'),
  FORX0003('Regular expression matches zero-length string'),
  FORX0004('Invalid replacement string'),

  // Functions and Operators: Type Errors
  FOTY0012('Argument contains node without typed value'),
  FOTY0013('The argument to fn:data() contains a function item'),
  FOTY0015('An argument to fn:deep-equal() contains a function item'),

  // Functions and Operators: Unparsed Text
  FOUT1170(
    'Resource is not a valid URI reference, or contains a fragment identifier',
  ),
  FOUT1190('Cannot decode resource using specified encoding'),
  FOUT1200('Cannot retrieve resource'),

  // Serialization
  SENR0001(
    'Item in sequence normalization is an attribute node or namespace node',
  ),
  SEPM0004('Invalid doctype-system or standalone parameter'),
  SEPM0016('Invalid serialization parameter value'),
  SEPM0017('Error evaluating serialization parameter setting'),
  SEPM0018('Use-character-maps sequence length greater than one'),
  SEPM0019('Duplicate serialization parameter'),
  SERE0020('Numeric value cannot be represented in JSON'),
  SERE0022('Duplicate map keys in JSON output'),
  SERE0023('Sequence length greater than one in JSON output'),

  // XPath Dynamic Errors
  XPDY0002(
    'Evaluation relies on dynamic context that has not been assigned a value',
  ),
  XPDY0050('Dynamic type does not match treat expression'),
  XPDY0130('An implementation-dependent limit has been exceeded'),

  // XPath Static Errors
  XPST0001('Static context component not assigned a value'),
  XPST0003('Expression is not a valid instance of the grammar'),
  XPST0005('Static type of expression is empty-sequence()'),
  XPST0008('Undefined name in static context'),
  XPST0010('Namespace axis is not supported'),
  XPST0017('Function signature does not match'),
  XPST0051('Atomic type not defined in in-scope schema types'),
  XPST0080(
    'Target type of cast is xs:NOTATION, xs:anySimpleType, or xs:anyAtomicType',
  ),
  XPST0081(
    'Namespace prefix cannot be expanded using statically known namespaces',
  ),

  // XPath Type Errors
  XPTY0004('Type error'),
  XPTY0018('Result of path operator contains both nodes and non-nodes'),
  XPTY0019('Path expression does not evaluate to a sequence of nodes'),
  XPTY0020('Context item in axis step is not a node'),

  // XQuery Dynamic Errors
  XQDY0137('No two keys in a map may have the same key value');

  new(this.message);

  /// The official standard error description.
  final String message;

  /// The error code name (e.g. `'XPTY0004'`).
  String get code => name;

  /// The qualified name of the error code in the standard error namespace.
  XPathQName get qname =>
      XPathQName(XmlName.qualified('err:$name', namespaceUri: namespaceUri));

  /// The standard XPath/XQuery error namespace URI.
  static const String namespaceUri = 'http://www.w3.org/2005/xqt-errors';

  /// Looks up an [XPathErrorCode] by its code name or qualified name.
  static XPathErrorCode? tryFromCode(String code) {
    final clean = code.contains(':') ? code.split(':').last : code;
    for (final val in values) {
      if (val.name == clean) return val;
    }
    return null;
  }

  /// Formats the error message with the error code.
  String format([String? details]) => details != null
      ? '$details [${qname.stringValue}]'
      : '$message [${qname.stringValue}]';
}
