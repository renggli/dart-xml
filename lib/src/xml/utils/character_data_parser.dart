import 'package:petitparser/petitparser.dart';

/// Optimized parser to read character data.
class XmlCharacterDataParser extends Parser<String> {
  XmlCharacterDataParser(this._stopper, this._minLength)
      : assert(_stopper.length == 1, 'Invalid stopper character: $_stopper'),
        assert(_minLength >= 0, 'Invalid minimum length: $_minLength');

  final String _stopper;
  final int _minLength;

  @override
  void parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    final index = position < buffer.length
        ? buffer.indexOf(_stopper, position)
        : buffer.length;
    final end = index == -1 ? buffer.length : index;
    if (end - position < _minLength) {
      context.isSuccess = false;
      context.message = 'Unable to parse character data.';
    } else {
      context.isSuccess = true;
      context.position = end;
      context.value = buffer.substring(position, end);
    }
  }

  @override
  XmlCharacterDataParser copy() => XmlCharacterDataParser(_stopper, _minLength);

  @override
  bool hasEqualProperties(XmlCharacterDataParser other) =>
      super.hasEqualProperties(other) &&
      _stopper == other._stopper &&
      _minLength == other._minLength;
}
