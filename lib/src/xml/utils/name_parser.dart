import 'package:petitparser/petitparser.dart';

import '../exceptions/parser_exception.dart';
import 'token.dart';

/// Parser matching a single XML non-colonized start character.
final Parser<String> nonColonizedStartChar = pattern(
  XmlToken.nameStartChars.replaceFirst(XmlToken.namespace, ''),
  unicode: true,
);

/// Parser matching a single XML non-colonized character.
final Parser<String> nonColonizedChar = pattern(
  XmlToken.nameChars.replaceFirst(XmlToken.namespace, ''),
  unicode: true,
);

/// Parser matching an XML non-colonized name (NCName).
final Parser<String> nonColonizedNameToken = seq2(
  nonColonizedStartChar,
  nonColonizedChar.star(),
).flatten(message: 'non-colonized name expected');

/// Parser matching an XML qualified name (QName: `NCName` or `NCName:NCName`).
final Parser<String> qualifiedNameToken = seq2(
  nonColonizedNameToken,
  seq2(char(XmlToken.namespace), nonColonizedNameToken).optional(),
).flatten(message: 'qualified name expected');

final _ncNameParser = nonColonizedNameToken.end();

/// Checks whether [s] is a valid XML NCName.
bool isValidNCName(String s) => _ncNameParser.parse(s) is! Failure;

/// Checks whether [s] is a valid lexical QName (`NCName` or `NCName:NCName`).
bool isValidQName(String s) {
  final colonIndex = s.indexOf(XmlToken.namespace);
  if (colonIndex == -1) return isValidNCName(s);
  if (s.indexOf(XmlToken.namespace, colonIndex + 1) != -1) return false;
  return isValidNCName(s.substring(0, colonIndex)) &&
      isValidNCName(s.substring(colonIndex + 1));
}

/// Splits [qualified] into `(prefix, local)` where `prefix` is `null` if no colon is present.
(String? prefix, String local) splitQualifiedName(String qualified) {
  final colonIndex = qualified.indexOf(XmlToken.namespace);
  if (colonIndex > 0) {
    return (
      qualified.substring(0, colonIndex),
      qualified.substring(colonIndex + 1),
    );
  }
  return (null, qualified);
}

/// Parses an EQName (`Q{uri}local` or `prefix:local` or `local`).
///
/// Returns `(uri, prefix, local)` where `uri` or `prefix` may be `null`.
(String? uri, String? prefix, String local) parseEQNameParts(String eqName) {
  String? uri;
  var name = eqName;
  if (name.startsWith(XmlToken.openQualifiedUrl)) {
    final end = name.indexOf(XmlToken.closeQualifiedUrl);
    if (end == -1) {
      throw XmlParserException('Invalid extended qualified name: $eqName');
    } else if (end > XmlToken.openQualifiedUrl.length) {
      uri = name.substring(XmlToken.openQualifiedUrl.length, end);
    }
    name = name.substring(end + XmlToken.closeQualifiedUrl.length);
  }
  final (prefix, local) = splitQualifiedName(name);
  return (uri, prefix, local);
}
