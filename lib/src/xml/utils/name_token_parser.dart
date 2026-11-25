import 'dart:typed_data';

import 'package:petitparser/petitparser.dart';

import 'token.dart';

/// Optimized parser to read an XML name.
///
/// Equivalent to `seq2(nameStartChar, nameChar.star()).flatten(message)`,
/// where `nameStartChar` and `nameChar` match [XmlToken.nameStartChars] and
/// [XmlToken.nameChars]. ASCII characters are classified with a lookup table
/// derived from these patterns, all other characters (including surrogate
/// pairs) are delegated to the unicode-aware pattern parsers.
class XmlNameTokenParser extends Parser<String> {
  new(this._message);

  final String _message;

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    final end = fastParseOn(buffer, position);
    return end < 0
        ? context.failure(_message)
        : context.success(buffer.substring(position, end), end);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final length = buffer.length;
    if (position >= length) return -1;
    final first = buffer.codeUnitAt(position);
    if (first < _asciiLimit) {
      if (_asciiTable[first] & _startFlag == 0) return -1;
      position++;
    } else {
      position = _nameStartChar.fastParseOn(buffer, position);
      if (position < 0) return -1;
    }
    while (position < length) {
      final next = buffer.codeUnitAt(position);
      if (next < _asciiLimit) {
        if (_asciiTable[next] & _charFlag == 0) break;
        position++;
      } else {
        final end = _nameChar.fastParseOn(buffer, position);
        if (end < 0) break;
        position = end;
      }
    }
    return position;
  }

  @override
  XmlNameTokenParser copy() => XmlNameTokenParser(_message);

  @override
  bool hasEqualProperties(XmlNameTokenParser other) =>
      super.hasEqualProperties(other) && _message == other._message;
}

const _asciiLimit = 0x80;
const _startFlag = 1;
const _charFlag = 2;

final _nameStartChar = pattern(XmlToken.nameStartChars, unicode: true);
final _nameChar = pattern(XmlToken.nameChars, unicode: true);

/// Classification of the ASCII characters, derived from [_nameStartChar] and
/// [_nameChar] so that the two never diverge.
final _asciiTable = () {
  final table = Uint8List(_asciiLimit);
  for (var code = 0; code < _asciiLimit; code++) {
    final char = String.fromCharCode(code);
    if (_nameStartChar.accept(char)) table[code] |= _startFlag;
    if (_nameChar.accept(char)) table[code] |= _charFlag;
  }
  return table;
}();
