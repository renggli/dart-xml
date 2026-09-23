import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/casting_matrix.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

XPathFunctionItem _atomicConstructor(XmlName name, XPathType targetType) =>
    XPathFunctionItem.overloaded(name, {
      0: XPathFunctionItem.fn0(name, (context) => XPathSequence.empty),
      1: XPathFunctionItem.fn1(name, (context, arg) {
        final value = arg.atomize().firstOrNull;
        if (value == null) return XPathSequence.empty;
        if (targetType == xsError) {
          throw XPathEvaluationException('Cannot cast to xs:error');
        }
        return XPathSequence.single(castAtomic(value, targetType));
      }),
    });

/// https://www.w3.org/TR/xpath-functions-31/#func-string
final xsStringConstructor = _atomicConstructor(
  const XmlName.qualified('xs:string'),
  xsString,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
final xsBooleanConstructor = _atomicConstructor(
  const XmlName.qualified('xs:boolean'),
  xsBoolean,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
final xsIntegerConstructor = _atomicConstructor(
  const XmlName.qualified('xs:integer'),
  xsInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-decimal
final xsDecimalConstructor = _atomicConstructor(
  const XmlName.qualified('xs:decimal'),
  xsDecimal,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-double
final xsDoubleConstructor = _atomicConstructor(
  const XmlName.qualified('xs:double'),
  xsDouble,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-float
final xsFloatConstructor = _atomicConstructor(
  const XmlName.qualified('xs:float'),
  xsFloat,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric
final xsNumericConstructor = XPathFunctionItem.overloaded(
  const XmlName.qualified('xs:numeric'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('xs:numeric'),
      (context) => XPathSequence.empty,
    ),
    1: XPathFunctionItem.fn1(const XmlName.qualified('xs:numeric'), (
      context,
      arg,
    ) {
      final value = arg.atomize().firstOrNull;
      if (value == null) return XPathSequence.empty;
      if (value is XPathNumeric) return XPathSequence.single(value);
      return XPathSequence.single(castAtomic(value, xsDouble));
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-byte
final xsByteConstructor = _atomicConstructor(
  const XmlName.qualified('xs:byte'),
  xsByte,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-int
final xsIntConstructor = _atomicConstructor(
  const XmlName.qualified('xs:int'),
  xsInt,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-long
final xsLongConstructor = _atomicConstructor(
  const XmlName.qualified('xs:long'),
  xsLong,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-negativeInteger
final xsNegativeIntegerConstructor = _atomicConstructor(
  const XmlName.qualified('xs:negativeInteger'),
  xsNegativeInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-nonNegativeInteger
final xsNonNegativeIntegerConstructor = _atomicConstructor(
  const XmlName.qualified('xs:nonNegativeInteger'),
  xsNonNegativeInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-nonPositiveInteger
final xsNonPositiveIntegerConstructor = _atomicConstructor(
  const XmlName.qualified('xs:nonPositiveInteger'),
  xsNonPositiveInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-positiveInteger
final xsPositiveIntegerConstructor = _atomicConstructor(
  const XmlName.qualified('xs:positiveInteger'),
  xsPositiveInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-short
final xsShortConstructor = _atomicConstructor(
  const XmlName.qualified('xs:short'),
  xsShort,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedByte
final xsUnsignedByteConstructor = _atomicConstructor(
  const XmlName.qualified('xs:unsignedByte'),
  xsUnsignedByte,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedInt
final xsUnsignedIntConstructor = _atomicConstructor(
  const XmlName.qualified('xs:unsignedInt'),
  xsUnsignedInt,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedLong
final xsUnsignedLongConstructor = _atomicConstructor(
  const XmlName.qualified('xs:unsignedLong'),
  xsUnsignedLong,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedShort
final xsUnsignedShortConstructor = _atomicConstructor(
  const XmlName.qualified('xs:unsignedShort'),
  xsUnsignedShort,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-date
final xsDateConstructor = _atomicConstructor(
  const XmlName.qualified('xs:date'),
  xsDate,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
final xsDateTimeConstructor = _atomicConstructor(
  const XmlName.qualified('xs:dateTime'),
  xsDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTimeStamp
final xsDateTimeStampConstructor = _atomicConstructor(
  const XmlName.qualified('xs:dateTimeStamp'),
  xsDateTimeStamp,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay
final xsGDayConstructor = _atomicConstructor(
  const XmlName.qualified('xs:gDay'),
  xsGDay,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth
final xsGMonthConstructor = _atomicConstructor(
  const XmlName.qualified('xs:gMonth'),
  xsGMonth,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay
final xsGMonthDayConstructor = _atomicConstructor(
  const XmlName.qualified('xs:gMonthDay'),
  xsGMonthDay,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear
final xsGYearConstructor = _atomicConstructor(
  const XmlName.qualified('xs:gYear'),
  xsGYear,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth
final xsGYearMonthConstructor = _atomicConstructor(
  const XmlName.qualified('xs:gYearMonth'),
  xsGYearMonth,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time
final xsTimeConstructor = _atomicConstructor(
  const XmlName.qualified('xs:time'),
  xsTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-duration
final xsDurationConstructor = _atomicConstructor(
  const XmlName.qualified('xs:duration'),
  xsDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration
final xsDayTimeDurationConstructor = _atomicConstructor(
  const XmlName.qualified('xs:dayTimeDuration'),
  xsDayTimeDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration
final xsYearMonthDurationConstructor = _atomicConstructor(
  const XmlName.qualified('xs:yearMonthDuration'),
  xsYearMonthDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary
final xsHexBinaryConstructor = _atomicConstructor(
  const XmlName.qualified('xs:hexBinary'),
  xsHexBinary,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary
final xsBase64BinaryConstructor = _atomicConstructor(
  const XmlName.qualified('xs:base64Binary'),
  xsBase64Binary,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-anyURI
final xsAnyURIConstructor = _atomicConstructor(
  const XmlName.qualified('xs:anyURI'),
  xsAnyURI,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
final xsQNameConstructor = _atomicConstructor(
  const XmlName.qualified('xs:QName'),
  xsQName,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-NOTATION
final xsNOTATIONConstructor = _atomicConstructor(
  const XmlName.qualified('xs:NOTATION'),
  xsNOTATION,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-untypedAtomic
final xsUntypedAtomicConstructor = _atomicConstructor(
  const XmlName.qualified('xs:untypedAtomic'),
  xsUntypedAtomic,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-normalizedString
final xsNormalizedStringConstructor = _atomicConstructor(
  const XmlName.qualified('xs:normalizedString'),
  xsNormalizedString,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-token
final xsTokenConstructor = _atomicConstructor(
  const XmlName.qualified('xs:token'),
  xsToken,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-language
final xsLanguageConstructor = _atomicConstructor(
  const XmlName.qualified('xs:language'),
  xsLanguage,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-NMTOKEN
final xsNMTokenConstructor = _atomicConstructor(
  const XmlName.qualified('xs:NMTOKEN'),
  xsNMToken,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-Name
final xsNameConstructor = _atomicConstructor(
  const XmlName.qualified('xs:Name'),
  xsName,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-NCName
final xsNCNameConstructor = _atomicConstructor(
  const XmlName.qualified('xs:NCName'),
  xsNCName,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-ID
final xsIDConstructor = _atomicConstructor(
  const XmlName.qualified('xs:ID'),
  xsID,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-IDREF
final xsIDREFConstructor = _atomicConstructor(
  const XmlName.qualified('xs:IDREF'),
  xsIDREF,
);

XPathFunctionItem _listConstructor(XmlName name, XPathType itemType) =>
    XPathFunctionItem.overloaded(name, {
      0: XPathFunctionItem.fn0(name, (context) => XPathSequence.empty),
      1: XPathFunctionItem.fn1(name, (context, arg) {
        final value = arg.atomize().firstOrNull;
        if (value == null) return XPathSequence.empty;
        final str = value.stringValue.trim();
        if (str.isEmpty) return XPathSequence.empty;
        final tokens = str.split(RegExp(r'\s+'));
        final items = <XPathAtomic>[];
        for (final token in tokens) {
          items.add(castAtomic(XPathString(token), itemType));
        }
        return XPathSequence(items);
      }),
    });

/// https://www.w3.org/TR/xpath-functions-31/#func-IDREFS
final xsIDREFSConstructor = _listConstructor(
  const XmlName.qualified('xs:IDREFS'),
  xsIDREF,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-NMTOKENS
final xsNMTOKENSConstructor = _listConstructor(
  const XmlName.qualified('xs:NMTOKENS'),
  xsNMToken,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-ENTITY
final xsENTITYConstructor = _atomicConstructor(
  const XmlName.qualified('xs:ENTITY'),
  xsENTITY,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-ENTITIES
final xsENTITIESConstructor = _listConstructor(
  const XmlName.qualified('xs:ENTITIES'),
  xsENTITY,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-error
final xsErrorConstructor = XPathFunctionItem.fn1(
  const XmlName.qualified('xs:error'),
  (context, arg) {
    final value = arg.atomize().firstOrNull;
    if (value == null) return XPathSequence.empty;
    throw XPathEvaluationException('Cannot cast to xs:error');
  },
);
