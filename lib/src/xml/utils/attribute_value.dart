/// Normalizes the whitespace characters `\t`, `\n`, and `\r` in a raw
/// attribute value to spaces according to XML 1.0 Section 3.3.3.
///
/// This must be applied after end-of-line normalization (so that `\r\n`
/// becomes a single space) and before decoding entities (so that character
/// references like `&#9;` and `&#10;` are preserved).
String normalizeAttributeValue(String input) {
  final length = input.length;
  var index = 0;
  while (index < length && !_isWhitespace(input.codeUnitAt(index))) {
    index++;
  }
  if (index == length) return input;
  final buffer = StringBuffer();
  var start = 0;
  do {
    if (start < index) {
      buffer.write(input.substring(start, index));
    }
    buffer.write(' ');
    start = ++index;
    while (index < length && !_isWhitespace(input.codeUnitAt(index))) {
      index++;
    }
  } while (index < length);
  if (start < length) {
    buffer.write(input.substring(start));
  }
  return buffer.toString();
}

bool _isWhitespace(int value) =>
    value == 0x09 || value == 0x0A || value == 0x0D;
