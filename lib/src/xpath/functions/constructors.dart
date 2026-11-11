import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
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
        return XPathSequence.single(castAtomic(value, targetType));
      }),
    });

/// https://www.w3.org/TR/xpath-functions-31/#func-string
final xsStringConstructor = _atomicConstructor(XmlName('xs:string'), xsString);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
final xsBooleanConstructor = _atomicConstructor(
  XmlName('xs:boolean'),
  xsBoolean,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-integer
final xsIntegerConstructor = _atomicConstructor(
  XmlName('xs:integer'),
  xsInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-decimal
final xsDecimalConstructor = _atomicConstructor(
  XmlName('xs:decimal'),
  xsDecimal,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-double
final xsDoubleConstructor = _atomicConstructor(XmlName('xs:double'), xsDouble);

/// https://www.w3.org/TR/xpath-functions-31/#func-float
final xsFloatConstructor = _atomicConstructor(XmlName('xs:float'), xsFloat);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric
final xsNumericConstructor = XPathFunctionItem.overloaded(
  XmlName('xs:numeric'),
  {
    0: XPathFunctionItem.fn0(
      XmlName('xs:numeric'),
      (context) => XPathSequence.empty,
    ),
    1: XPathFunctionItem.fn1(XmlName('xs:numeric'), (context, arg) {
      final value = arg.atomize().firstOrNull;
      if (value == null) return XPathSequence.empty;
      if (value is XPathNumeric) return XPathSequence.single(value);
      return XPathSequence.single(castAtomic(value, xsDouble));
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-byte
final xsByteConstructor = _atomicConstructor(XmlName('xs:byte'), xsByte);

/// https://www.w3.org/TR/xpath-functions-31/#func-int
final xsIntConstructor = _atomicConstructor(XmlName('xs:int'), xsInt);

/// https://www.w3.org/TR/xpath-functions-31/#func-long
final xsLongConstructor = _atomicConstructor(XmlName('xs:long'), xsLong);

/// https://www.w3.org/TR/xpath-functions-31/#func-negativeInteger
final xsNegativeIntegerConstructor = _atomicConstructor(
  XmlName('xs:negativeInteger'),
  xsNegativeInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-nonNegativeInteger
final xsNonNegativeIntegerConstructor = _atomicConstructor(
  XmlName('xs:nonNegativeInteger'),
  xsNonNegativeInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-nonPositiveInteger
final xsNonPositiveIntegerConstructor = _atomicConstructor(
  XmlName('xs:nonPositiveInteger'),
  xsNonPositiveInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-positiveInteger
final xsPositiveIntegerConstructor = _atomicConstructor(
  XmlName('xs:positiveInteger'),
  xsPositiveInteger,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-short
final xsShortConstructor = _atomicConstructor(XmlName('xs:short'), xsShort);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedByte
final xsUnsignedByteConstructor = _atomicConstructor(
  XmlName('xs:unsignedByte'),
  xsUnsignedByte,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedInt
final xsUnsignedIntConstructor = _atomicConstructor(
  XmlName('xs:unsignedInt'),
  xsUnsignedInt,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedLong
final xsUnsignedLongConstructor = _atomicConstructor(
  XmlName('xs:unsignedLong'),
  xsUnsignedLong,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-unsignedShort
final xsUnsignedShortConstructor = _atomicConstructor(
  XmlName('xs:unsignedShort'),
  xsUnsignedShort,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-date
final xsDateConstructor = _atomicConstructor(XmlName('xs:date'), xsDate);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
final xsDateTimeConstructor = _atomicConstructor(
  XmlName('xs:dateTime'),
  xsDateTime,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTimeStamp
final xsDateTimeStampConstructor = _atomicConstructor(
  XmlName('xs:dateTimeStamp'),
  xsDateTimeStamp,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay
final xsGDayConstructor = _atomicConstructor(XmlName('xs:gDay'), xsGDay);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth
final xsGMonthConstructor = _atomicConstructor(XmlName('xs:gMonth'), xsGMonth);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay
final xsGMonthDayConstructor = _atomicConstructor(
  XmlName('xs:gMonthDay'),
  xsGMonthDay,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear
final xsGYearConstructor = _atomicConstructor(XmlName('xs:gYear'), xsGYear);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth
final xsGYearMonthConstructor = _atomicConstructor(
  XmlName('xs:gYearMonth'),
  xsGYearMonth,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-time
final xsTimeConstructor = _atomicConstructor(XmlName('xs:time'), xsTime);

/// https://www.w3.org/TR/xpath-functions-31/#func-duration
final xsDurationConstructor = _atomicConstructor(
  XmlName('xs:duration'),
  xsDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration
final xsDayTimeDurationConstructor = _atomicConstructor(
  XmlName('xs:dayTimeDuration'),
  xsDayTimeDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration
final xsYearMonthDurationConstructor = _atomicConstructor(
  XmlName('xs:yearMonthDuration'),
  xsYearMonthDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-hexBinary
final xsHexBinaryConstructor = _atomicConstructor(
  XmlName('xs:hexBinary'),
  xsHexBinary,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base64Binary
final xsBase64BinaryConstructor = _atomicConstructor(
  XmlName('xs:base64Binary'),
  xsBase64Binary,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-anyURI
final xsAnyURIConstructor = _atomicConstructor(XmlName('xs:anyURI'), xsAnyURI);

/// https://www.w3.org/TR/xpath-functions-31/#func-QName
final xsQNameConstructor = _atomicConstructor(XmlName('xs:QName'), xsQName);

/// https://www.w3.org/TR/xpath-functions-31/#func-untypedAtomic
final xsUntypedAtomicConstructor = _atomicConstructor(
  XmlName('xs:untypedAtomic'),
  xsUntypedAtomic,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-normalizedString
final xsNormalizedStringConstructor = _atomicConstructor(
  XmlName('xs:normalizedString'),
  xsNormalizedString,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-token
final xsTokenConstructor = _atomicConstructor(XmlName('xs:token'), xsToken);

/// https://www.w3.org/TR/xpath-functions-31/#func-language
final xsLanguageConstructor = _atomicConstructor(
  XmlName('xs:language'),
  xsLanguage,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-NMTOKEN
final xsNMTokenConstructor = _atomicConstructor(
  XmlName('xs:NMTOKEN'),
  xsNMToken,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-Name
final xsNameConstructor = _atomicConstructor(XmlName('xs:Name'), xsName);

/// https://www.w3.org/TR/xpath-functions-31/#func-NCName
final xsNCNameConstructor = _atomicConstructor(XmlName('xs:NCName'), xsNCName);

/// https://www.w3.org/TR/xpath-functions-31/#func-ID
final xsIDConstructor = _atomicConstructor(XmlName('xs:ID'), xsID);

/// https://www.w3.org/TR/xpath-functions-31/#func-IDREF
final xsIDREFConstructor = _atomicConstructor(XmlName('xs:IDREF'), xsIDREF);

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
final xsIDREFSConstructor = _listConstructor(XmlName('xs:IDREFS'), xsIDREF);

/// https://www.w3.org/TR/xpath-functions-31/#func-NMTOKENS
final xsNMTOKENSConstructor = _listConstructor(
  XmlName('xs:NMTOKENS'),
  xsNMToken,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-ENTITY
final xsENTITYConstructor = _atomicConstructor(XmlName('xs:ENTITY'), xsENTITY);

/// https://www.w3.org/TR/xpath-functions-31/#func-ENTITIES
final xsENTITIESConstructor = _listConstructor(
  XmlName('xs:ENTITIES'),
  xsENTITY,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-error
final xsErrorConstructor = XPathFunctionItem.fn1(XmlName('xs:error'), (
  context,
  arg,
) {
  final value = arg.atomize().firstOrNull;
  if (value == null) return XPathSequence.empty;
  throw XPathEvaluationException(
    XPathErrorCode.FORG0001,
    'Cannot cast to xs:error',
  );
});
