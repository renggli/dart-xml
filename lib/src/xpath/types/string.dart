import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/binary.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';
import 'binary.dart';
import 'boolean.dart';
import 'date_time.dart';
import 'duration.dart';
import 'node.dart';
import 'number.dart';
import 'qname.dart';

/// The XPath string type.
const xsString = _XPathStringType();

class _XPathStringType extends XPathType<String> {
  const _XPathStringType();

  @override
  String get name => 'xs:string';

  @override
  Iterable<String> get aliases => const [
    'xs:normalizedString',
    'xs:token',
    'xs:language',
    'xs:NMTOKEN',
    'xs:NMTOKENS',
    'xs:Name',
    'xs:NCName',
    'xs:ID',
    'xs:IDREF',
    'xs:IDREFS',
    'xs:ENTITY',
    'xs:ENTITIES',
    'xs:anyURI',
    'xs:NOTATION',
  ];

  @override
  bool matches(Object value) => value is String;

  @override
  String cast(Object value) => switch (value) {
    String() => value,
    bool() => xsBoolean.castToString(value),
    num() => xsNumeric.castToString(value),
    XPathBase64Binary() => xsBase64Binary.castToString(value),
    XPathHexBinary() => xsHexBinary.castToString(value),
    XPathYearMonthDuration() => xsYearMonthDuration.castToString(value),
    XPathDayTimeDuration() => xsDayTimeDuration.castToString(value),
    Duration() => xsDuration.castToString(xsDayTimeDuration.cast(value)),
    XPathDateTimeStamp() => xsDateTimeStamp.castToString(value),
    XPathDate() => xsDate.castToString(value),
    XPathTime() => xsTime.castToString(value),
    XPathGYearMonth() => xsGYearMonth.castToString(value),
    XPathGYear() => xsGYear.castToString(value),
    XPathGMonthDay() => xsGMonthDay.castToString(value),
    XPathGMonth() => xsGMonth.castToString(value),
    XPathGDay() => xsGDay.castToString(value),
    DateTime() => xsDateTime.castToString(value),
    XmlName() => xsQName.castToString(value),
    XmlNode() => xsNode.castToString(value),
    XPathSequence() => _castSequence(value),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  String _castSequence(XPathSequence sequence) {
    final iterator = sequence.iterator;
    if (!iterator.moveNext()) return '';
    final item = iterator.current;
    if (!iterator.moveNext()) return cast(item);
    throw XPathEvaluationException.unsupportedCast(this, sequence);
  }
}
