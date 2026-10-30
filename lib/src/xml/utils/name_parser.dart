import 'package:petitparser/petitparser.dart';

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
