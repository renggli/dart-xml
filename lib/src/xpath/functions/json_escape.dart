/// Escapes a string for JSON output according to RFC 8259 and XPath 3.1 serialization.
String escapeJsonString(String input, [String encoding = 'utf-8']) {
  final sb = StringBuffer();
  sb.write('"');
  final isIso88591 = encoding.toLowerCase().contains('8859-1');
  for (var i = 0; i < input.length; i++) {
    final code = input.codeUnitAt(i);
    switch (code) {
      case 0x22: // "
        sb.write(r'\"');
      case 0x5C: // \
        sb.write(r'\\');
      case 0x2F: // /
        sb.write(r'\/');
      case 0x08: // \b
        sb.write(r'\b');
      case 0x0C: // \f
        sb.write(r'\f');
      case 0x0A: // \n
        sb.write(r'\n');
      case 0x0D: // \r
        sb.write(r'\r');
      case 0x09: // \t
        sb.write(r'\t');
      default:
        if (code < 0x20 || (code >= 0x7F && code <= 0x9F)) {
          sb.write(
            '\\u${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          );
        } else if (isIso88591 && code > 0xFF) {
          sb.write(
            '\\u${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          );
        } else {
          sb.writeCharCode(code);
        }
    }
  }
  sb.write('"');
  return sb.toString();
}
