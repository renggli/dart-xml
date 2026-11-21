/// Normalizes XML end-of-line sequences (`\r\n` and standalone `\r`) to `\n`
/// according to XML 1.0 Section 2.11.
String normalizeEndOfLine(String input) {
  var index = input.indexOf('\r');
  if (index < 0) return input;
  final buffer = StringBuffer();
  var start = 0;
  do {
    if (start < index) {
      buffer.write(input.substring(start, index));
    }
    buffer.write('\n');
    start = index + 1;
    if (start < input.length && input.codeUnitAt(start) == 0x0A) {
      start++;
    }
    index = input.indexOf('\r', start);
  } while (index >= 0);
  if (start < input.length) {
    buffer.write(input.substring(start));
  }
  return buffer.toString();
}
