import '../evaluation/cardinality.dart';
import 'item.dart';
import 'sequence.dart';

/// XDM 3.1 type descriptor hierarchy.
abstract class XPathType {
  const new({
    required this.name,
    this.parent,
    this.aliases = const [],
    this.isAtomic = true,
  });

  /// Canonical name of the type.
  final String name;

  /// Parent type in the hierarchy, if any.
  final XPathType? parent;

  /// Aliases for parsing (e.g. URI-qualified names, short names).
  final Iterable<String> aliases;

  /// Returns `true` if this type is an atomic type.
  final bool isAtomic;

  /// Returns `true` if this type is equal to or a subtype of [other].
  bool isSubtypeOf(XPathType other) {
    XPathType? current = this;
    while (current != null) {
      if (identical(current, other) || current == other) return true;
      current = current.parent;
    }
    return false;
  }

  /// Returns `true` if the [item] matches this type.
  bool matchesItem(XPathItem item) => item.type.isSubtypeOf(this);

  /// Returns `true` if the [sequence] matches this type.
  bool matchesSequence(XPathSequence sequence) {
    if (sequence.length != 1) return false;
    return matchesItem(sequence.single);
  }

  @override
  String toString() => name;
}

/// Sequence type with item type and cardinality constraint.
class XPathSequenceType extends XPathType {
  const new({
    required this.itemType,
    this.cardinality = XPathCardinality.zeroOrMore,
  }) : super(name: '', parent: null, isAtomic: false);

  /// The item type of the sequence.
  final XPathType itemType;

  /// The cardinality of the sequence.
  final XPathCardinality cardinality;

  @override
  String get name => '$itemType$cardinality';

  @override
  bool matchesItem(XPathItem item) => itemType.matchesItem(item);

  /// Returns `true` if the [sequence] matches this sequence type.
  @override
  bool matchesSequence(XPathSequence sequence) {
    if (!sequence.hasCardinality(cardinality)) return false;
    return sequence.every(matchesItem);
  }
}

class _XPathEmptySequenceType extends XPathType {
  const new() : super(name: 'empty-sequence()', isAtomic: false);

  /// Returns `true` if the [sequence] is empty.
  @override
  bool matchesSequence(XPathSequence sequence) => sequence.isEmpty;
}

/// The empty sequence type.
const xsEmptySequence = _XPathEmptySequenceType();

/// The generic sequence type `item()*`.
const xsSequence = XPathSequenceType(itemType: xsItem);

/// Standard internal concrete implementation of [XPathType].
class _XDMType extends XPathType {
  const new({
    required super.name,
    super.parent,
    super.aliases,
    super.isAtomic = true,
  });
}

// ---------------------------------------------------------------------------
// Item Root
// ---------------------------------------------------------------------------
const xsItem = _XDMType(name: 'item()', isAtomic: false);
const xsAny = xsItem;

// ---------------------------------------------------------------------------
// Node Kinds
// ---------------------------------------------------------------------------
const xsNode = _XDMType(name: 'node()', parent: xsItem, isAtomic: false);
const xsDocument = _XDMType(
  name: 'document-node()',
  parent: xsNode,
  isAtomic: false,
);
const xsElement = _XDMType(
  name: 'element()',
  parent: xsNode,
  aliases: ['xs:untyped'],
  isAtomic: false,
);
const xsAttribute = _XDMType(
  name: 'attribute()',
  parent: xsNode,
  isAtomic: false,
);
const xsText = _XDMType(name: 'text()', parent: xsNode, isAtomic: false);
const xsComment = _XDMType(name: 'comment()', parent: xsNode, isAtomic: false);
const xsProcessingInstruction = _XDMType(
  name: 'processing-instruction()',
  parent: xsNode,
  isAtomic: false,
);
const xsNamespace = _XDMType(
  name: 'namespace-node()',
  parent: xsNode,
  isAtomic: false,
);

// ---------------------------------------------------------------------------
// Functions, Maps, Arrays
// ---------------------------------------------------------------------------
const xsFunction = _XDMType(
  name: 'function(*)',
  parent: xsItem,
  isAtomic: false,
);
const xsMap = _XDMType(name: 'map(*)', parent: xsFunction, isAtomic: false);
const xsArray = _XDMType(name: 'array(*)', parent: xsFunction, isAtomic: false);

// ---------------------------------------------------------------------------
// Atomic Root
// ---------------------------------------------------------------------------
const xsAnyAtomicType = _XDMType(name: 'xs:anyAtomicType', parent: xsItem);

const xsUntypedAtomic = _XDMType(
  name: 'xs:untypedAtomic',
  parent: xsAnyAtomicType,
);

const xsString = _XDMType(name: 'xs:string', parent: xsAnyAtomicType);
const xsNormalizedString = _XDMType(
  name: 'xs:normalizedString',
  parent: xsString,
);
const xsToken = _XDMType(name: 'xs:token', parent: xsNormalizedString);
const xsLanguage = _XDMType(name: 'xs:language', parent: xsToken);
const xsNMToken = _XDMType(name: 'xs:NMTOKEN', parent: xsToken);
const xsName = _XDMType(name: 'xs:Name', parent: xsToken);
const xsNCName = _XDMType(name: 'xs:NCName', parent: xsName);
const xsID = _XDMType(name: 'xs:ID', parent: xsNCName);
const xsIDREF = _XDMType(name: 'xs:IDREF', parent: xsNCName);
const xsENTITY = _XDMType(name: 'xs:ENTITY', parent: xsNCName);

const xsBoolean = _XDMType(name: 'xs:boolean', parent: xsAnyAtomicType);

const xsBase64Binary = _XDMType(
  name: 'xs:base64Binary',
  parent: xsAnyAtomicType,
);
const xsHexBinary = _XDMType(name: 'xs:hexBinary', parent: xsAnyAtomicType);

const xsAnyURI = _XDMType(name: 'xs:anyURI', parent: xsAnyAtomicType);
const xsQName = _XDMType(name: 'xs:QName', parent: xsAnyAtomicType);
const xsNOTATION = _XDMType(name: 'xs:NOTATION', parent: xsAnyAtomicType);
const xsError = _XDMType(name: 'xs:error', parent: xsAnyAtomicType);

// ---------------------------------------------------------------------------
// Numerics
// ---------------------------------------------------------------------------
const xsNumeric = _XDMType(name: 'xs:numeric', parent: xsAnyAtomicType);
const xsDouble = _XDMType(name: 'xs:double', parent: xsNumeric);
const xsFloat = _XDMType(
  name: 'xs:float',
  parent: xsNumeric,
  aliases: ['float'],
);
const xsDecimal = _XDMType(name: 'xs:decimal', parent: xsNumeric);

// Integers (arbitrary precision)
const xsInteger = _XDMType(name: 'xs:integer', parent: xsDecimal);
const xsNonPositiveInteger = _XDMType(
  name: 'xs:nonPositiveInteger',
  parent: xsInteger,
);
const xsNegativeInteger = _XDMType(
  name: 'xs:negativeInteger',
  parent: xsNonPositiveInteger,
);
const xsLong = _XDMType(name: 'xs:long', parent: xsInteger);
const xsInt = _XDMType(name: 'xs:int', parent: xsLong);
const xsShort = _XDMType(name: 'xs:short', parent: xsInt);
const xsByte = _XDMType(name: 'xs:byte', parent: xsShort);

const xsNonNegativeInteger = _XDMType(
  name: 'xs:nonNegativeInteger',
  parent: xsInteger,
);
const xsPositiveInteger = _XDMType(
  name: 'xs:positiveInteger',
  parent: xsNonNegativeInteger,
);
const xsUnsignedLong = _XDMType(
  name: 'xs:unsignedLong',
  parent: xsNonNegativeInteger,
);
const xsUnsignedInt = _XDMType(name: 'xs:unsignedInt', parent: xsUnsignedLong);
const xsUnsignedShort = _XDMType(
  name: 'xs:unsignedShort',
  parent: xsUnsignedInt,
);
const xsUnsignedByte = _XDMType(
  name: 'xs:unsignedByte',
  parent: xsUnsignedShort,
);

// ---------------------------------------------------------------------------
// Temporal Types
// ---------------------------------------------------------------------------
const xsDateTime = _XDMType(name: 'xs:dateTime', parent: xsAnyAtomicType);
const xsDateTimeStamp = _XDMType(name: 'xs:dateTimeStamp', parent: xsDateTime);
const xsDate = _XDMType(name: 'xs:date', parent: xsAnyAtomicType);
const xsTime = _XDMType(name: 'xs:time', parent: xsAnyAtomicType);

const xsGYear = _XDMType(name: 'xs:gYear', parent: xsAnyAtomicType);
const xsGYearMonth = _XDMType(name: 'xs:gYearMonth', parent: xsAnyAtomicType);
const xsGMonth = _XDMType(name: 'xs:gMonth', parent: xsAnyAtomicType);
const xsGMonthDay = _XDMType(name: 'xs:gMonthDay', parent: xsAnyAtomicType);
const xsGDay = _XDMType(name: 'xs:gDay', parent: xsAnyAtomicType);

const xsDuration = _XDMType(name: 'xs:duration', parent: xsAnyAtomicType);
const xsYearMonthDuration = _XDMType(
  name: 'xs:yearMonthDuration',
  parent: xsDuration,
);
const xsDayTimeDuration = _XDMType(
  name: 'xs:dayTimeDuration',
  parent: xsDuration,
);

/// Lookup table of all standard types by name and alias.
final Map<String, XPathType> standardTypes = {
  for (final type in allStandardTypes) ...{
    type.name: type,
    for (final alias in type.aliases) alias: type,
    if (type.name.startsWith('xs:')) ...{
      type.name.substring(3): type,
      'Q{http://www.w3.org/2001/XMLSchema}${type.name.substring(3)}': type,
    },
  },
};

/// All standard built-in types.
const allStandardTypes = <XPathType>[
  xsEmptySequence,
  xsItem,
  xsNode,
  xsDocument,
  xsElement,
  xsAttribute,
  xsText,
  xsComment,
  xsProcessingInstruction,
  xsNamespace,
  xsFunction,
  xsMap,
  xsArray,
  xsAnyAtomicType,
  xsUntypedAtomic,
  xsString,
  xsNormalizedString,
  xsToken,
  xsLanguage,
  xsNMToken,
  xsName,
  xsNCName,
  xsID,
  xsIDREF,
  xsENTITY,
  xsBoolean,
  xsBase64Binary,
  xsHexBinary,
  xsAnyURI,
  xsQName,
  xsNOTATION,
  xsError,
  xsNumeric,
  xsDouble,
  xsFloat,
  xsDecimal,
  xsInteger,
  xsNonPositiveInteger,
  xsNegativeInteger,
  xsLong,
  xsInt,
  xsShort,
  xsByte,
  xsNonNegativeInteger,
  xsPositiveInteger,
  xsUnsignedLong,
  xsUnsignedInt,
  xsUnsignedShort,
  xsUnsignedByte,
  xsDateTime,
  xsDateTimeStamp,
  xsDate,
  xsTime,
  xsGYear,
  xsGYearMonth,
  xsGMonth,
  xsGMonthDay,
  xsGDay,
  xsDuration,
  xsYearMonthDuration,
  xsDayTimeDuration,
];
