// ignore_for_file: constant_identifier_names

import 'package:meta/meta.dart';

import '../../xml/utils/name.dart';
import '../xdm/atomic/qname.dart';

/// XPath 3.1 and XQuery standard error codes.
///
/// See <https://www.w3.org/2005/xqt-errors/> for details.
@immutable
class XPathErrorCode {
  // Functions and Operators: Function application
  static const FOAP0001 = XPathErrorCode(
    'FOAP0001',
    'Wrong number of arguments',
  );

  // Functions and Operators: Arithmetic
  static const FOAR0001 = XPathErrorCode('FOAR0001', 'Division by zero');
  static const FOAR0002 = XPathErrorCode(
    'FOAR0002',
    'Numeric operation overflow/underflow',
  );

  // Functions and Operators: Arrays
  static const FOAY0001 = XPathErrorCode(
    'FOAY0001',
    'Array index out of bounds',
  );
  static const FOAY0002 = XPathErrorCode('FOAY0002', 'Negative array length');

  // Functions and Operators: Casting and Type Conversion
  static const FOCA0001 = XPathErrorCode(
    'FOCA0001',
    'Input value too large for decimal',
  );
  static const FOCA0002 = XPathErrorCode('FOCA0002', 'Invalid lexical value');
  static const FOCA0003 = XPathErrorCode(
    'FOCA0003',
    'Input value too large for integer',
  );
  static const FOCA0005 = XPathErrorCode(
    'FOCA0005',
    'NaN supplied as float/double value',
  );
  static const FOCA0006 = XPathErrorCode(
    'FOCA0006',
    'String to be cast to decimal has too many digits of precision',
  );

  // Functions and Operators: Characters and Collation
  static const FOCH0001 = XPathErrorCode('FOCH0001', 'Codepoint not valid');
  static const FOCH0002 = XPathErrorCode('FOCH0002', 'Unsupported collation');
  static const FOCH0003 = XPathErrorCode(
    'FOCH0003',
    'Unsupported normalization form',
  );
  static const FOCH0004 = XPathErrorCode(
    'FOCH0004',
    'Collation does not support collation units',
  );

  // Functions and Operators: Documents and Collections
  static const FODC0001 = XPathErrorCode('FODC0001', 'No context document');
  static const FODC0002 = XPathErrorCode(
    'FODC0002',
    'Error retrieving resource',
  );
  static const FODC0003 = XPathErrorCode(
    'FODC0003',
    'Function not defined as deterministic',
  );
  static const FODC0004 = XPathErrorCode('FODC0004', 'Invalid collection URI');
  static const FODC0005 = XPathErrorCode(
    'FODC0005',
    'Invalid argument to fn:doc or fn:doc-available',
  );
  static const FODC0006 = XPathErrorCode(
    'FODC0006',
    'String passed to fn:parse-xml is not a well-formed XML document',
  );

  // Functions and Operators: Date and Time
  static const FODT0001 = XPathErrorCode(
    'FODT0001',
    'Overflow/underflow in date/time operation',
  );
  static const FODT0002 = XPathErrorCode(
    'FODT0002',
    'Overflow/underflow in duration operation',
  );
  static const FODT0003 = XPathErrorCode('FODT0003', 'Invalid timezone value');

  // Functions and Operators: Error function
  static const FOER0000 = XPathErrorCode('FOER0000', 'Unidentified error');

  // Functions and Operators: JSON
  static const FOJS0001 = XPathErrorCode('FOJS0001', 'JSON syntax error');
  static const FOJS0003 = XPathErrorCode('FOJS0003', 'JSON duplicate keys');
  static const FOJS0005 = XPathErrorCode('FOJS0005', 'Invalid options');
  static const FOJS0006 = XPathErrorCode(
    'FOJS0006',
    'Invalid XML representation of JSON',
  );
  static const FOJS0007 = XPathErrorCode(
    'FOJS0007',
    'Bad JSON escape sequence',
  );

  // Functions and Operators: Namespaces
  static const FONS0004 = XPathErrorCode(
    'FONS0004',
    'No namespace found for prefix',
  );

  // Functions and Operators: Regular Expressions and General
  static const FORG0001 = XPathErrorCode(
    'FORG0001',
    'Invalid value for cast/constructor',
  );
  static const FORG0002 = XPathErrorCode(
    'FORG0002',
    'Invalid argument to fn:resolve-uri()',
  );
  static const FORG0003 = XPathErrorCode(
    'FORG0003',
    'Sequence contains more than one item',
  );
  static const FORG0004 = XPathErrorCode('FORG0004', 'Sequence is empty');
  static const FORG0005 = XPathErrorCode(
    'FORG0005',
    'Sequence does not contain exactly one item',
  );
  static const FORG0006 = XPathErrorCode('FORG0006', 'Invalid argument type');
  static const FORG0008 = XPathErrorCode(
    'FORG0008',
    'Both arguments to fn:dateTime have a specified timezone',
  );
  static const FORG0010 = XPathErrorCode('FORG0010', 'Invalid date/time');

  // Functions and Operators: Regular Expressions
  static const FORX0001 = XPathErrorCode(
    'FORX0001',
    'Invalid regular expression flags',
  );
  static const FORX0002 = XPathErrorCode(
    'FORX0002',
    'Invalid regular expression',
  );
  static const FORX0003 = XPathErrorCode(
    'FORX0003',
    'Regular expression matches zero-length string',
  );
  static const FORX0004 = XPathErrorCode(
    'FORX0004',
    'Invalid replacement string',
  );

  // Functions and Operators: Type Errors
  static const FOTY0012 = XPathErrorCode(
    'FOTY0012',
    'Argument contains node without typed value',
  );
  static const FOTY0013 = XPathErrorCode(
    'FOTY0013',
    'The argument to fn:data() contains a function item',
  );
  static const FOTY0015 = XPathErrorCode(
    'FOTY0015',
    'An argument to fn:deep-equal() contains a function item',
  );

  // Functions and Operators: Unparsed Text
  static const FOUT1170 = XPathErrorCode(
    'FOUT1170',
    'Resource is not a valid URI reference, or contains a fragment identifier',
  );
  static const FOUT1190 = XPathErrorCode(
    'FOUT1190',
    'Cannot decode resource using specified encoding',
  );
  static const FOUT1200 = XPathErrorCode(
    'FOUT1200',
    'Cannot retrieve resource',
  );

  // Serialization
  static const SENR0001 = XPathErrorCode(
    'SENR0001',
    'Item in sequence normalization is an attribute node or namespace node',
  );
  static const SEPM0004 = XPathErrorCode(
    'SEPM0004',
    'Invalid doctype-system or standalone parameter',
  );
  static const SEPM0016 = XPathErrorCode(
    'SEPM0016',
    'Invalid serialization parameter value',
  );
  static const SEPM0017 = XPathErrorCode(
    'SEPM0017',
    'Error evaluating serialization parameter setting',
  );
  static const SEPM0018 = XPathErrorCode(
    'SEPM0018',
    'Use-character-maps sequence length greater than one',
  );
  static const SEPM0019 = XPathErrorCode(
    'SEPM0019',
    'Duplicate serialization parameter',
  );
  static const SERE0020 = XPathErrorCode(
    'SERE0020',
    'Numeric value cannot be represented in JSON',
  );
  static const SERE0022 = XPathErrorCode(
    'SERE0022',
    'Duplicate map keys in JSON output',
  );
  static const SERE0023 = XPathErrorCode(
    'SERE0023',
    'Sequence length greater than one in JSON output',
  );

  // XPath Dynamic Errors
  static const XPDY0002 = XPathErrorCode(
    'XPDY0002',
    'Evaluation relies on dynamic context that has not been assigned a value',
  );
  static const XPDY0050 = XPathErrorCode(
    'XPDY0050',
    'Dynamic type does not match treat expression',
  );
  static const XPDY0130 = XPathErrorCode(
    'XPDY0130',
    'An implementation-dependent limit has been exceeded',
  );

  // XPath Static Errors
  static const XPST0001 = XPathErrorCode(
    'XPST0001',
    'Static context component not assigned a value',
  );
  static const XPST0003 = XPathErrorCode(
    'XPST0003',
    'Expression is not a valid instance of the grammar',
  );
  static const XPST0005 = XPathErrorCode(
    'XPST0005',
    'Static type of expression is empty-sequence()',
  );
  static const XPST0008 = XPathErrorCode(
    'XPST0008',
    'Undefined name in static context',
  );
  static const XPST0010 = XPathErrorCode(
    'XPST0010',
    'Namespace axis is not supported',
  );
  static const XPST0017 = XPathErrorCode(
    'XPST0017',
    'Function signature does not match',
  );
  static const XPST0051 = XPathErrorCode(
    'XPST0051',
    'Atomic type not defined in in-scope schema types',
  );
  static const XPST0080 = XPathErrorCode(
    'XPST0080',
    'Target type of cast is xs:NOTATION, xs:anySimpleType, or xs:anyAtomicType',
  );
  static const XPST0081 = XPathErrorCode(
    'XPST0081',
    'Namespace prefix cannot be expanded using statically known namespaces',
  );

  // XPath Type Errors
  static const XPTY0004 = XPathErrorCode('XPTY0004', 'Type error');
  static const XPTY0018 = XPathErrorCode(
    'XPTY0018',
    'Result of path operator contains both nodes and non-nodes',
  );
  static const XPTY0019 = XPathErrorCode(
    'XPTY0019',
    'Path expression does not evaluate to a sequence of nodes',
  );
  static const XPTY0020 = XPathErrorCode(
    'XPTY0020',
    'Context item in axis step is not a node',
  );

  // XQuery Dynamic Errors
  static const XQDY0137 = XPathErrorCode(
    'XQDY0137',
    'No two keys in a map may have the same key value',
  );

  /// Standard list of predefined XPath error codes.
  static const values = <XPathErrorCode>[
    FOAP0001,
    FOAR0001,
    FOAR0002,
    FOAY0001,
    FOAY0002,
    FOCA0001,
    FOCA0002,
    FOCA0003,
    FOCA0005,
    FOCA0006,
    FOCH0001,
    FOCH0002,
    FOCH0003,
    FOCH0004,
    FODC0001,
    FODC0002,
    FODC0003,
    FODC0004,
    FODC0005,
    FODC0006,
    FODT0001,
    FODT0002,
    FODT0003,
    FOER0000,
    FOJS0001,
    FOJS0003,
    FOJS0005,
    FOJS0006,
    FOJS0007,
    FONS0004,
    FORG0001,
    FORG0002,
    FORG0003,
    FORG0004,
    FORG0005,
    FORG0006,
    FORG0008,
    FORG0010,
    FORX0001,
    FORX0002,
    FORX0003,
    FORX0004,
    FOTY0012,
    FOTY0013,
    FOTY0015,
    FOUT1170,
    FOUT1190,
    FOUT1200,
    SENR0001,
    SEPM0004,
    SEPM0016,
    SEPM0017,
    SEPM0018,
    SEPM0019,
    SERE0020,
    SERE0022,
    SERE0023,
    XPDY0002,
    XPDY0050,
    XPDY0130,
    XPST0001,
    XPST0003,
    XPST0005,
    XPST0008,
    XPST0010,
    XPST0017,
    XPST0051,
    XPST0080,
    XPST0081,
    XPTY0004,
    XPTY0018,
    XPTY0019,
    XPTY0020,
    XQDY0137,
  ];

  /// Creates a new [XPathErrorCode] with the given [name], [message], and optional [namespaceUri].
  const new(
    this.name, [
    this.message = 'Unidentified error',
    this.namespaceUri = standardNamespaceUri,
  ]);

  /// The standard XPath/XQuery error namespace URI.
  static const String standardNamespaceUri =
      'http://www.w3.org/2005/xqt-errors';

  /// The error code name (e.g. `'XPTY0004'`).
  final String name;

  /// The official standard error description.
  final String message;

  /// The namespace URI of the error code.
  final String namespaceUri;

  /// The error code name (alias for [name]).
  String get code => name;

  /// The qualified name of the error code in its error namespace.
  XPathQName get qname => XPathQName(
    namespaceUri == standardNamespaceUri
        ? XmlName.qualified('err:$name', namespaceUri: namespaceUri)
        : XmlName.parts(name, namespaceUri: namespaceUri),
  );

  /// Looks up a known [XPathErrorCode] by its code name or qualified name, or returns `null`.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPathErrorCode &&
          name == other.name &&
          namespaceUri == other.namespaceUri;

  @override
  int get hashCode => Object.hash(name, namespaceUri);

  @override
  String toString() => 'XPathErrorCode($name: $message)';
}
