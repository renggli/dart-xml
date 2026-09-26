import '../../xml/utils/name.dart';
import '../../xml/utils/token.dart';
import '../evaluation/namespaces.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import 'atomic.dart';
import 'types.dart';

/// Validation bounds for integer subtypes.
final Map<XPathType, (BigInt min, BigInt max)> integerBounds = {
  xsNonPositiveInteger: (
    BigInt.parse('-99999999999999999999999999999999999999'),
    BigInt.zero,
  ),
  xsNegativeInteger: (
    BigInt.parse('-99999999999999999999999999999999999999'),
    -BigInt.one,
  ),
  xsLong: (
    BigInt.parse('-9223372036854775808'),
    BigInt.parse('9223372036854775807'),
  ),
  xsInt: (BigInt.parse('-2147483648'), BigInt.parse('2147483647')),
  xsShort: (BigInt.parse('-32768'), BigInt.parse('32767')),
  xsByte: (BigInt.parse('-128'), BigInt.parse('127')),
  xsNonNegativeInteger: (
    BigInt.zero,
    BigInt.parse('99999999999999999999999999999999999999'),
  ),
  xsPositiveInteger: (
    BigInt.one,
    BigInt.parse('99999999999999999999999999999999999999'),
  ),
  xsUnsignedLong: (BigInt.zero, BigInt.parse('18446744073709551615')),
  xsUnsignedInt: (BigInt.zero, BigInt.parse('4294967295')),
  xsUnsignedShort: (BigInt.zero, BigInt.parse('65535')),
  xsUnsignedByte: (BigInt.zero, BigInt.parse('255')),
};

/// Returns the primitive base type in the XDM casting matrix for [type].
XPathType primitiveCastingType(XPathType type) {
  if (type == xsNumeric) return xsInteger;
  if (type.isSubtypeOf(xsInteger)) return xsInteger;
  if (type.isSubtypeOf(xsDecimal)) return xsDecimal;
  if (type.isSubtypeOf(xsDouble)) return xsDouble;
  if (type.isSubtypeOf(xsFloat)) return xsFloat;
  if (type.isSubtypeOf(xsString)) return xsString;
  if (type == xsUntypedAtomic) return xsUntypedAtomic;
  if (type == xsBoolean) return xsBoolean;
  if (type == xsDateTimeStamp) return xsDateTimeStamp;
  if (type.isSubtypeOf(xsDateTime)) return xsDateTime;
  if (type == xsDate) return xsDate;
  if (type == xsTime) return xsTime;
  if (type == xsGYearMonth) return xsGYearMonth;
  if (type == xsGYear) return xsGYear;
  if (type == xsGMonthDay) return xsGMonthDay;
  if (type == xsGMonth) return xsGMonth;
  if (type == xsGDay) return xsGDay;
  if (type == xsYearMonthDuration) return xsYearMonthDuration;
  if (type == xsDayTimeDuration) return xsDayTimeDuration;
  if (type.isSubtypeOf(xsDuration)) return xsDuration;
  if (type == xsBase64Binary) return xsBase64Binary;
  if (type == xsHexBinary) return xsHexBinary;
  if (type == xsAnyURI) return xsAnyURI;
  if (type == xsQName) return xsQName;
  if (type == xsNOTATION) return xsNOTATION;
  return type;
}

const _allPrimitiveTargets = <XPathType>[
  xsUntypedAtomic,
  xsString,
  xsFloat,
  xsDouble,
  xsDecimal,
  xsInteger,
  xsDuration,
  xsYearMonthDuration,
  xsDayTimeDuration,
  xsDateTime,
  xsDateTimeStamp,
  xsDate,
  xsTime,
  xsGYearMonth,
  xsGYear,
  xsGMonthDay,
  xsGMonth,
  xsGDay,
  xsBoolean,
  xsBase64Binary,
  xsHexBinary,
  xsAnyURI,
  xsQName,
  xsNOTATION,
];

/// Allowed casts between primitive/atomic types per W3C XPath 3.1 §19.
/// Key is (sourcePrimitiveType, targetPrimitiveType).
final Set<(XPathType, XPathType)> _allowedPrimitiveCasts = {
  // xs:untypedAtomic can be cast to all primitive types except xs:NOTATION
  for (final target in _allPrimitiveTargets)
    if (target != xsNOTATION) (xsUntypedAtomic, target),

  // xs:string can be cast to all primitive types except xs:NOTATION
  for (final target in _allPrimitiveTargets)
    if (target != xsNOTATION) (xsString, target),

  // xs:float
  (xsFloat, xsFloat),
  (xsFloat, xsDouble),
  (xsFloat, xsDecimal),
  (xsFloat, xsInteger),
  (xsFloat, xsString),
  (xsFloat, xsUntypedAtomic),
  (xsFloat, xsBoolean),

  // xs:double
  (xsDouble, xsFloat),
  (xsDouble, xsDouble),
  (xsDouble, xsDecimal),
  (xsDouble, xsInteger),
  (xsDouble, xsString),
  (xsDouble, xsUntypedAtomic),
  (xsDouble, xsBoolean),

  // xs:decimal
  (xsDecimal, xsFloat),
  (xsDecimal, xsDouble),
  (xsDecimal, xsDecimal),
  (xsDecimal, xsInteger),
  (xsDecimal, xsString),
  (xsDecimal, xsUntypedAtomic),
  (xsDecimal, xsBoolean),

  // xs:integer
  (xsInteger, xsFloat),
  (xsInteger, xsDouble),
  (xsInteger, xsDecimal),
  (xsInteger, xsInteger),
  (xsInteger, xsString),
  (xsInteger, xsUntypedAtomic),
  (xsInteger, xsBoolean),

  // xs:duration
  (xsDuration, xsDuration),
  (xsDuration, xsYearMonthDuration),
  (xsDuration, xsDayTimeDuration),
  (xsDuration, xsString),
  (xsDuration, xsUntypedAtomic),

  // xs:yearMonthDuration
  (xsYearMonthDuration, xsDuration),
  (xsYearMonthDuration, xsYearMonthDuration),
  (xsYearMonthDuration, xsDayTimeDuration),
  (xsYearMonthDuration, xsString),
  (xsYearMonthDuration, xsUntypedAtomic),

  // xs:dayTimeDuration
  (xsDayTimeDuration, xsDuration),
  (xsDayTimeDuration, xsYearMonthDuration),
  (xsDayTimeDuration, xsDayTimeDuration),
  (xsDayTimeDuration, xsString),
  (xsDayTimeDuration, xsUntypedAtomic),

  // xs:dateTime
  (xsDateTime, xsDateTime),
  (xsDateTime, xsDateTimeStamp),
  (xsDateTime, xsDate),
  (xsDateTime, xsTime),
  (xsDateTime, xsGYearMonth),
  (xsDateTime, xsGYear),
  (xsDateTime, xsGMonthDay),
  (xsDateTime, xsGMonth),
  (xsDateTime, xsGDay),
  (xsDateTime, xsString),
  (xsDateTime, xsUntypedAtomic),

  // xs:dateTimeStamp
  (xsDateTimeStamp, xsDateTime),
  (xsDateTimeStamp, xsDateTimeStamp),
  (xsDateTimeStamp, xsDate),
  (xsDateTimeStamp, xsTime),
  (xsDateTimeStamp, xsGYearMonth),
  (xsDateTimeStamp, xsGYear),
  (xsDateTimeStamp, xsGMonthDay),
  (xsDateTimeStamp, xsGMonth),
  (xsDateTimeStamp, xsGDay),
  (xsDateTimeStamp, xsString),
  (xsDateTimeStamp, xsUntypedAtomic),

  // xs:date
  (xsDate, xsDateTime),
  (xsDate, xsDateTimeStamp),
  (xsDate, xsDate),
  (xsDate, xsGYearMonth),
  (xsDate, xsGYear),
  (xsDate, xsGMonthDay),
  (xsDate, xsGMonth),
  (xsDate, xsGDay),
  (xsDate, xsString),
  (xsDate, xsUntypedAtomic),

  // xs:time
  (xsTime, xsTime),
  (xsTime, xsString),
  (xsTime, xsUntypedAtomic),

  // xs:gYearMonth
  (xsGYearMonth, xsGYearMonth),
  (xsGYearMonth, xsString),
  (xsGYearMonth, xsUntypedAtomic),

  // xs:gYear
  (xsGYear, xsGYear),
  (xsGYear, xsString),
  (xsGYear, xsUntypedAtomic),

  // xs:gMonthDay
  (xsGMonthDay, xsGMonthDay),
  (xsGMonthDay, xsString),
  (xsGMonthDay, xsUntypedAtomic),

  // xs:gMonth
  (xsGMonth, xsGMonth),
  (xsGMonth, xsString),
  (xsGMonth, xsUntypedAtomic),

  // xs:gDay
  (xsGDay, xsGDay),
  (xsGDay, xsString),
  (xsGDay, xsUntypedAtomic),

  // xs:boolean
  (xsBoolean, xsBoolean),
  (xsBoolean, xsFloat),
  (xsBoolean, xsDouble),
  (xsBoolean, xsDecimal),
  (xsBoolean, xsInteger),
  (xsBoolean, xsString),
  (xsBoolean, xsUntypedAtomic),

  // xs:base64Binary
  (xsBase64Binary, xsBase64Binary),
  (xsBase64Binary, xsHexBinary),
  (xsBase64Binary, xsString),
  (xsBase64Binary, xsUntypedAtomic),

  // xs:hexBinary
  (xsHexBinary, xsHexBinary),
  (xsHexBinary, xsBase64Binary),
  (xsHexBinary, xsString),
  (xsHexBinary, xsUntypedAtomic),

  // xs:anyURI
  (xsAnyURI, xsAnyURI),
  (xsAnyURI, xsString),
  (xsAnyURI, xsUntypedAtomic),

  // xs:QName
  (xsQName, xsQName),
  (xsQName, xsString),
  (xsQName, xsUntypedAtomic),

  // xs:NOTATION
  (xsNOTATION, xsNOTATION),
  (xsNOTATION, xsString),
  (xsNOTATION, xsUntypedAtomic),
};

/// Checks if [source] can be cast to [target] according to W3C XPath 3.1 §19.
bool canCastType(XPathType source, XPathType target) {
  if (target == xsAnyAtomicType || target == xsNOTATION) return false;
  if (!target.isAtomic) return false;

  final sourcePrimitive = primitiveCastingType(source);
  final targetPrimitive = primitiveCastingType(target);

  return _allowedPrimitiveCasts.contains((sourcePrimitive, targetPrimitive));
}

/// Casts [item] to [targetType], throwing [XPathEvaluationException] if illegal or invalid.
XPathAtomic castAtomic(XPathAtomic item, XPathType targetType) {
  if (targetType == xsAnyAtomicType || targetType == xsNOTATION) {
    throw XPathEvaluationException(
      XPathErrorCode.XPST0080,
      'Cannot cast to abstract type ${targetType.name}',
    );
  }
  if (!targetType.isAtomic) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Target type ${targetType.name} is not an atomic type',
    );
  }

  final sourcePrimitive = primitiveCastingType(item.type);
  final targetPrimitive = primitiveCastingType(targetType);

  if (!_allowedPrimitiveCasts.contains((sourcePrimitive, targetPrimitive))) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot cast ${item.type.name} to ${targetType.name}',
    );
  }

  // Fast path: identical type
  if (item.type == targetType) {
    return item;
  }

  final result = _performCast(item, targetType, targetPrimitive);
  _validateTargetConstraints(result, targetType);
  return result;
}

XPathAtomic _performCast(
  XPathAtomic item,
  XPathType targetType,
  XPathType targetPrimitive,
) {
  // If target is string or untypedAtomic
  if (targetPrimitive == xsString) {
    var str = item.stringValue;
    if (targetType.isSubtypeOf(xsToken)) {
      str = _collapseWhitespace(str);
    } else if (targetType.isSubtypeOf(xsNormalizedString)) {
      str = _normalizeString(str);
    }
    return XPathString(str, targetType);
  }
  if (targetPrimitive == xsUntypedAtomic) {
    return XPathUntypedAtomic(item.stringValue);
  }

  // Cast from string or untypedAtomic
  if (item is XPathString ||
      item is XPathUntypedAtomic ||
      item is XPathAnyUri) {
    return _castFromString(item.stringValue, targetType, targetPrimitive);
  }

  // Numeric to Numeric / Boolean
  if (item is XPathNumeric) {
    if (targetPrimitive == xsDouble) {
      return XPathDouble(item.toDouble(), targetType);
    }
    if (targetPrimitive == xsFloat) {
      return XPathDouble(roundToFloat(item.toDouble()), targetType);
    }
    if (targetPrimitive == xsDecimal) {
      return item.toDecimal();
    }
    if (targetPrimitive == xsInteger) {
      return XPathInteger(item.toBigInt(), targetType);
    }
    if (targetPrimitive == xsBoolean) {
      return XPathBoolean(item.effectiveBooleanValue);
    }
  }

  // Boolean to Numeric
  if (item is XPathBoolean) {
    if (targetPrimitive == xsDouble || targetPrimitive == xsFloat) {
      return XPathDouble(item.value ? 1.0 : 0.0, targetType);
    }
    if (targetPrimitive == xsDecimal) {
      return XPathDecimal(item.value ? BigInt.one : BigInt.zero, 0);
    }
    if (targetPrimitive == xsInteger) {
      return XPathInteger(item.value ? BigInt.one : BigInt.zero, targetType);
    }
  }

  // Binary conversions
  if (item is XPathBinary) {
    if (targetPrimitive == xsBase64Binary) {
      return XPathBinary(item.value, xsBase64Binary);
    }
    if (targetPrimitive == xsHexBinary) {
      return XPathBinary(item.value, xsHexBinary);
    }
  }

  // Temporal conversions
  if (item is XPathDateTime) {
    if (targetPrimitive == xsDateTimeStamp) {
      if (item.timezoneOffsetMinutes == null) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'xs:dateTimeStamp requires timezone',
        );
      }
    }
    return XPathDateTime.fromParts(
      year: item.year ?? 1970,
      month: item.month ?? 1,
      day: item.day ?? 1,
      hour: item.hour ?? 0,
      minute: item.minute ?? 0,
      second: item.second ?? 0,
      millisecond: item.millisecond,
      microsecond: item.microsecond,
      timezoneOffsetMinutes: item.timezoneOffsetMinutes,
      type: targetPrimitive,
    );
  }

  // Duration conversions
  final duration = item as XPathDuration;
  if (targetPrimitive == xsDuration) {
    return XPathDuration.fromValues(
      duration.totalMonths,
      duration.totalMicroseconds,
      xsDuration,
    );
  }
  if (targetPrimitive == xsYearMonthDuration) {
    return XPathDuration.yearMonth(duration.totalMonths);
  }
  return XPathDuration.dayTime(duration.totalMicroseconds);
}

XPathAtomic _castFromString(
  String text,
  XPathType targetType,
  XPathType targetPrimitive,
) {
  final trimmed = text.trim();
  try {
    if (targetPrimitive == xsBoolean) {
      if (trimmed == 'true' || trimmed == '1') {
        return XPathBoolean.trueInstance;
      }
      if (trimmed == 'false' || trimmed == '0') {
        return XPathBoolean.falseInstance;
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid boolean literal',
      );
    }
    if (targetPrimitive == xsDouble || targetPrimitive == xsFloat) {
      return XPathDouble.parse(trimmed, targetType);
    }
    if (targetPrimitive == xsDecimal) {
      return XPathDecimal.parse(trimmed);
    }
    if (targetPrimitive == xsInteger) {
      return XPathInteger.parse(trimmed, targetType);
    }
    if (targetPrimitive == xsDateTime) {
      final dt = XPathDateTime.tryParse(trimmed);
      if (dt != null) return dt;
      if (_isYearOutOfRange(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FODT0001,
          'Year out of range: $trimmed',
        );
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid xs:dateTime',
      );
    }
    if (targetPrimitive == xsDateTimeStamp) {
      final dt = XPathDateTime.tryParse(trimmed);
      if (dt != null && dt.timezoneOffsetMinutes != null) return dt;
      if (_isYearOutOfRange(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FODT0001,
          'Year out of range: $trimmed',
        );
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid xs:dateTimeStamp',
      );
    }
    if (targetPrimitive == xsDate) {
      final d = XPathDateTime.tryParseDate(trimmed);
      if (d != null) return d;
      if (_isYearOutOfRange(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FODT0001,
          'Year out of range: $trimmed',
        );
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid xs:date',
      );
    }
    if (targetPrimitive == xsTime) {
      return XPathDateTime.tryParseTime(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:time',
          ));
    }
    if (targetPrimitive == xsGYearMonth) {
      final ym = XPathDateTime.tryParseYearMonth(trimmed);
      if (ym != null) return ym;
      if (_isYearOutOfRange(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FODT0001,
          'Year out of range: $trimmed',
        );
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid xs:gYearMonth',
      );
    }
    if (targetPrimitive == xsGYear) {
      final y = XPathDateTime.tryParseYear(trimmed);
      if (y != null) return y;
      if (_isYearOutOfRange(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FODT0001,
          'Year out of range: $trimmed',
        );
      }
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid xs:gYear',
      );
    }
    if (targetPrimitive == xsGMonthDay) {
      return XPathDateTime.tryParseMonthDay(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:gMonthDay',
          ));
    }
    if (targetPrimitive == xsGMonth) {
      return XPathDateTime.tryParseMonth(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:gMonth',
          ));
    }
    if (targetPrimitive == xsGDay) {
      return XPathDateTime.tryParseDay(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:gDay',
          ));
    }
    if (targetPrimitive == xsDuration) {
      return XPathDuration.tryParse(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:duration',
          ));
    }
    if (targetPrimitive == xsYearMonthDuration) {
      return XPathDuration.tryParseYearMonth(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:yearMonthDuration',
          ));
    }
    if (targetPrimitive == xsDayTimeDuration) {
      return XPathDuration.tryParseDayTime(trimmed) ??
          (throw XPathEvaluationException(
            XPathErrorCode.FORG0001,
            'Invalid xs:dayTimeDuration',
          ));
    }
    if (targetPrimitive == xsBase64Binary) {
      return XPathBinary.fromBase64(trimmed);
    }
    if (targetPrimitive == xsHexBinary) {
      return XPathBinary.fromHex(trimmed);
    }
    if (targetPrimitive == xsQName) {
      if (!isValidQName(trimmed)) {
        throw XPathEvaluationException(
          XPathErrorCode.FOCA0002,
          'Invalid lexical QName: "$trimmed"',
        );
      }
      final name = XmlName.fromString(trimmed);
      final uri =
          xpathNamespaceUris[name.prefix] ??
          (name.prefix == 'xml' ? xmlXmlNamespace : null);
      return XPathQName(uri != null ? name.withNamespaceUri(uri) : name);
    }
    return XPathAnyUri(trimmed);
  } catch (e) {
    if (e is XPathEvaluationException) rethrow;
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Invalid literal for ${targetType.name}: "$text"',
    );
  }
}

void _validateTargetConstraints(XPathAtomic item, XPathType targetType) {
  if (item is XPathInteger) {
    final bounds = integerBounds[targetType];
    if (bounds != null) {
      if (item.value < bounds.$1 || item.value > bounds.$2) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Integer value ${item.value} out of range for ${targetType.name}',
        );
      }
    }
  } else if (item is XPathString) {
    final str = item.value;
    if (targetType == xsLanguage) {
      if (!_languageRegExp.hasMatch(str)) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Invalid lexical value for xs:language: "$str"',
        );
      }
    } else if (targetType == xsNMToken) {
      if (!_nmTokenRegExp.hasMatch(str)) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Invalid lexical value for xs:NMTOKEN: "$str"',
        );
      }
    } else if (targetType == xsName) {
      if (!_nameRegExp.hasMatch(str)) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Invalid lexical value for xs:Name: "$str"',
        );
      }
    } else if (targetType == xsNCName ||
        targetType == xsID ||
        targetType == xsIDREF ||
        targetType == xsENTITY) {
      if (!_ncNameRegExp.hasMatch(str)) {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Invalid lexical value for ${targetType.name}: "$str"',
        );
      }
    }
  }
}

final _normalizeStringRegexp = RegExp(r'\s');
String _normalizeString(String value) =>
    value.replaceAll(_normalizeStringRegexp, ' ');

final _collapseWhitespaceRegExp = RegExp(r'\s+');
String _collapseWhitespace(String value) =>
    value.trim().replaceAll(_collapseWhitespaceRegExp, ' ');

final _ncNameStartCharPattern = XmlToken.nameStartChars.replaceFirst(':', '');
final _ncNameCharPattern = XmlToken.nameChars.replaceFirst(':', '');

final _languageRegExp = RegExp(r'^[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*$');
final _nmTokenRegExp = RegExp('^[${XmlToken.nameChars}]+\$', unicode: true);
final _nameRegExp = RegExp(
  '^[${XmlToken.nameStartChars}][${XmlToken.nameChars}]*\$',
  unicode: true,
);
final _ncNameRegExp = RegExp(
  '^[$_ncNameStartCharPattern][$_ncNameCharPattern]*\$',
  unicode: true,
);

final _yearPrefixRegExp = RegExp(r'^-?(?<year>\d{4,})');

bool _isYearOutOfRange(String trimmed) {
  final match = _yearPrefixRegExp.firstMatch(trimmed);
  if (match != null) {
    final yrStr = match.group(0)!;
    final yr = int.tryParse(yrStr);
    if (yr == null || yr < -271821 || yr > 275759) {
      return true;
    }
  }
  return false;
}
