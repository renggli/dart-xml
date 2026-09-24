import 'package:petitparser/petitparser.dart';

import '../../../xml/entities/null_mapping.dart';
import '../../../xml/utils/name.dart';
import '../../../xml_events/parser.dart';
import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

/// Represents an xs:QName atomic value.
final class XPathQName extends XPathAtomic {
  const new(this.value);

  @override
  final XmlName value;

  @override
  XPathType get type => xsQName;

  @override
  String get stringValue => value.qualified;

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    XPathErrorCode.FORG0006,
    'EBV not defined for QName values',
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathQName) {
      return value.local == other.value.local &&
          (value.namespaceUri ?? '') == (other.value.namespaceUri ?? '');
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(value.local, value.namespaceUri ?? '');
}

final _ncNameParser = resolve<String>(
  ref0(const XmlEventParser(XmlNullEntityMapping()).nonColonizedNameToken),
).end();

/// Checks whether [s] is a valid XML NCName.
bool isValidNCName(String s) => _ncNameParser.parse(s) is! Failure;

/// Checks whether [s] is a valid lexical QName (either `NCName` or `NCName:NCName`).
bool isValidQName(String s) {
  final colonIndex = s.indexOf(':');
  if (colonIndex == -1) return isValidNCName(s);
  if (s.indexOf(':', colonIndex + 1) != -1) return false;
  return isValidNCName(s.substring(0, colonIndex)) &&
      isValidNCName(s.substring(colonIndex + 1));
}
