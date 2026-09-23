import 'package:collection/collection.dart';

import '../evaluation/cardinality.dart';
import 'function_item.dart';
import 'functions/array.dart';
import 'functions/map.dart';
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
    if (identical(this, other) || this == other) return true;
    if (other is XPathSequenceType) {
      return isSubtypeOf(other.itemType);
    }
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
  bool isSubtypeOf(XPathType other) {
    if (identical(this, other) || this == other) return true;
    if (other == xsItem || other == xsSequence) return true;
    if (other is XPathSequenceType) {
      return itemType.isSubtypeOf(other.itemType) &&
          cardinality.isSubtypeOf(other.cardinality);
    }
    if (cardinality == XPathCardinality.exactlyOne) {
      return itemType.isSubtypeOf(other);
    }
    return false;
  }

  @override
  bool matchesItem(XPathItem item) => itemType.matchesItem(item);

  /// Returns `true` if the [sequence] matches this sequence type.
  @override
  bool matchesSequence(XPathSequence sequence) {
    if (!sequence.hasCardinality(cardinality)) return false;
    return sequence.every(itemType.matchesItem);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPathSequenceType &&
          itemType == other.itemType &&
          cardinality == other.cardinality;

  @override
  int get hashCode => Object.hash(itemType, cardinality);
}

class _XPathEmptySequenceType extends XPathType {
  const new() : super(name: 'empty-sequence()', isAtomic: false);

  @override
  bool isSubtypeOf(XPathType other) {
    if (identical(this, other) || other == this) return true;
    if (other == xsItem) return false;
    if (other is XPathSequenceType) {
      return other.cardinality == XPathCardinality.zeroOrOne ||
          other.cardinality == XPathCardinality.zeroOrMore;
    }
    return false;
  }

  @override
  bool matchesItem(XPathItem item) => false;

  /// Returns `true` if the [sequence] is empty.
  @override
  bool matchesSequence(XPathSequence sequence) => sequence.isEmpty;
}

/// The empty sequence type.
const xsEmptySequence = _XPathEmptySequenceType();

/// The generic sequence type `item()*`.
const xsSequence = XPathSequenceType(itemType: xsItem);

/// XDM 3.1 array type descriptor (e.g. `array(*)`, `array(xs:string)`).
class XPathArrayType extends XPathType {
  const new([this.memberType = xsSequence])
    : super(name: 'array(*)', parent: xsArray, isAtomic: false);

  /// The member type of the array.
  final XPathType memberType;

  @override
  String get name =>
      memberType == xsSequence ? 'array(*)' : 'array($memberType)';

  @override
  bool isSubtypeOf(XPathType other) {
    if (super.isSubtypeOf(other)) return true;
    if (other is XPathArrayType) {
      return memberType.isSubtypeOf(other.memberType);
    }
    return false;
  }

  @override
  bool matchesItem(XPathItem item) {
    if (item is! XPathArray) return false;
    if (memberType == xsSequence || memberType == xsItem) return true;
    return item.members.every(memberType.matchesSequence);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPathArrayType && memberType == other.memberType;

  @override
  int get hashCode => memberType.hashCode;
}

/// XDM 3.1 map type descriptor (e.g. `map(*)`, `map(xs:string, xs:integer)`).
class XPathMapType extends XPathType {
  const new([this.keyType = xsAnyAtomicType, this.valueType = xsSequence])
    : super(name: 'map(*)', parent: xsMap, isAtomic: false);

  /// The expected key type of the map.
  final XPathType keyType;

  /// The expected value type of each entry in the map.
  final XPathType valueType;

  @override
  String get name => (keyType == xsAnyAtomicType && valueType == xsSequence)
      ? 'map(*)'
      : 'map($keyType, $valueType)';

  @override
  bool isSubtypeOf(XPathType other) {
    if (super.isSubtypeOf(other)) return true;
    if (other is XPathMapType) {
      return keyType.isSubtypeOf(other.keyType) &&
          valueType.isSubtypeOf(other.valueType);
    }
    // A map(K, V) is also a subtype of function(T) as R if:
    // - T is a supertype of K (or T is xs:anyAtomicType), i.e. K.isSubtypeOf(T)
    // - V is a subtype of R
    if (other is XPathFunctionType) {
      if (other.isAny) return true;
      final params = other.parameterTypes!;
      if (params.length != 1) return false;
      if (!keyType.isSubtypeOf(params[0])) return false;
      final ret = other.returnType;
      if (ret != null && !valueType.isSubtypeOf(ret)) return false;
      return true;
    }
    return false;
  }

  @override
  bool matchesItem(XPathItem item) {
    if (item is! XPathMap) return false;
    if (keyType == xsAnyAtomicType && valueType == xsSequence) return true;
    for (final entry in item.entries.entries) {
      if (!keyType.matchesItem(entry.key)) return false;
      if (!valueType.matchesSequence(entry.value)) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPathMapType &&
          keyType == other.keyType &&
          valueType == other.valueType;

  @override
  int get hashCode => Object.hash(keyType, valueType);
}

/// XDM 3.1 function type descriptor (e.g. `function(*)`, `function(xs:string) as xs:integer`).
class XPathFunctionType extends XPathType {
  const new({this.parameterTypes, this.returnType})
    : super(name: 'function(*)', parent: xsFunction, isAtomic: false);

  /// Expected parameter types, or `null` for `function(*)`.
  final List<XPathType>? parameterTypes;

  /// Expected return type, if specified.
  final XPathType? returnType;

  /// Returns `true` if this is the generic unconstrained `function(*)`.
  bool get isAny => parameterTypes == null;

  @override
  String get name {
    if (parameterTypes == null) return 'function(*)';
    final params = parameterTypes!.map((t) => t.toString()).join(', ');
    final ret = returnType != null ? ' as $returnType' : '';
    return 'function($params)$ret';
  }

  @override
  bool isSubtypeOf(XPathType other) {
    if (super.isSubtypeOf(other)) return true;
    if (other is XPathFunctionType) {
      if (other.isAny) return true;
      if (isAny) return false;
      if (parameterTypes!.length != other.parameterTypes!.length) return false;
      for (var i = 0; i < parameterTypes!.length; i++) {
        // Contravariance: other.parameter must be a subtype of this.parameter.
        if (!other.parameterTypes![i].isSubtypeOf(parameterTypes![i])) {
          return false;
        }
      }
      if (other.returnType != null) {
        if (returnType == null) return false;
        // Covariance: this.returnType must be a subtype of other.returnType.
        if (!returnType!.isSubtypeOf(other.returnType!)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  bool matchesItem(XPathItem item) {
    if (item is! XPathFunctionItem) return false;
    if (isAny) return true;
    if (item.arity != parameterTypes!.length) return false;

    if (item is XPathMap) {
      if (parameterTypes!.length != 1) return false;
      final argType = parameterTypes!.single;
      if (!argType.isSubtypeOf(xsAnyAtomicType) &&
          !argType.isSubtypeOf(
            const XPathSequenceType(
              itemType: xsAnyAtomicType,
              cardinality: XPathCardinality.zeroOrOne,
            ),
          )) {
        return false;
      }
      if (returnType != null) {
        if (!returnType!.matchesSequence(XPathSequence.empty)) return false;
        for (final entry in item.entries.entries) {
          if (argType.matchesItem(entry.key)) {
            if (!returnType!.matchesSequence(entry.value)) return false;
          }
        }
      }
      return true;
    }

    if (item is XPathArray) {
      if (parameterTypes!.length != 1) return false;
      final argType = parameterTypes!.single;
      if (!argType.isSubtypeOf(xsInteger) &&
          !argType.isSubtypeOf(
            const XPathSequenceType(
              itemType: xsInteger,
              cardinality: XPathCardinality.zeroOrOne,
            ),
          )) {
        return false;
      }
      if (returnType != null) {
        for (final member in item.members) {
          if (!returnType!.matchesSequence(member)) return false;
        }
      }
      return true;
    }

    if (item.parameterTypes != null) {
      if (item.parameterTypes!.length != parameterTypes!.length) return false;
      for (var i = 0; i < parameterTypes!.length; i++) {
        if (!parameterTypes![i].isSubtypeOf(item.parameterTypes![i])) {
          return false;
        }
      }
    }
    if (item.returnType != null && returnType != null) {
      if (!item.returnType!.isSubtypeOf(returnType!)) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPathFunctionType &&
          const ListEquality<XPathType>().equals(
            parameterTypes,
            other.parameterTypes,
          ) &&
          returnType == other.returnType;

  @override
  int get hashCode => Object.hash(
    parameterTypes == null
        ? null
        : const ListEquality<XPathType>().hash(
            parameterTypes as List<XPathType>,
          ),
    returnType,
  );
}

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
const xsIDREFS = _XDMType(name: 'xs:IDREFS', parent: xsAnyAtomicType);
const xsENTITY = _XDMType(name: 'xs:ENTITY', parent: xsNCName);
const xsENTITIES = _XDMType(name: 'xs:ENTITIES', parent: xsAnyAtomicType);
const xsNMTOKENS = _XDMType(name: 'xs:NMTOKENS', parent: xsAnyAtomicType);

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
  xsIDREFS,
  xsENTITY,
  xsENTITIES,
  xsNMTOKENS,
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
