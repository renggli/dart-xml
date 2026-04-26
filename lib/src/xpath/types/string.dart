import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import 'binary.dart';
import 'boolean.dart';
import 'date_time.dart';
import 'duration.dart';
import 'node.dart';
import 'number.dart';
import 'qname.dart';
import 'sequence.dart';

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
  String cast(Object value) {
    if (value is String) {
      return value;
    } else if (value is bool) {
      return xsBoolean.castToString(value);
    } else if (value is num) {
      return xsNumeric.castToString(value);
    } else if (value is XPathBase64Binary) {
      return xsBase64Binary.castToString(value);
    } else if (value is XPathHexBinary) {
      return xsHexBinary.castToString(value);
    } else if (value is XPathYearMonthDuration) {
      return xsYearMonthDuration.castToString(value);
    } else if (value is XPathDayTimeDuration) {
      return xsDayTimeDuration.castToString(value);
    } else if (value is Duration) {
      return xsDuration.castToString(value);
    } else if (value is XPathDateTimeStamp) {
      return xsDateTimeStamp.castToString(value);
    } else if (value is XPathDate) {
      return xsDate.castToString(value);
    } else if (value is XPathTime) {
      return xsTime.castToString(value);
    } else if (value is XPathGYearMonth) {
      return xsGYearMonth.castToString(value);
    } else if (value is XPathGYear) {
      return xsGYear.castToString(value);
    } else if (value is XPathGMonthDay) {
      return xsGMonthDay.castToString(value);
    } else if (value is XPathGMonth) {
      return xsGMonth.castToString(value);
    } else if (value is XPathGDay) {
      return xsGDay.castToString(value);
    } else if (value is DateTime) {
      return xsDateTime.castToString(value);
    } else if (value is XmlName) {
      return xsQName.castToString(value);
    } else if (value is XmlNode) {
      return xsNode.castToString(value);
    } else if (value is XPathSequence) {
      final iterator = value.iterator;
      if (!iterator.moveNext()) return '';
      final item = iterator.current;
      if (!iterator.moveNext()) return cast(item);
    }
    throw XPathEvaluationException.unsupportedCast(this, value);
  }
}
