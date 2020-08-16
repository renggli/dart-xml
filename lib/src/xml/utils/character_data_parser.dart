import 'package:petitparser/petitparser.dart';

import '../entities/entity_mapping.dart';

/// Optimized parser to read character data.
class XmlCharacterDataParser extends Parser<String> {
  final XmlEntityMapping _entityMapping;
  final String _stopper;
  final int _stopperCode;
  final int _minLength;

  XmlCharacterDataParser(this._entityMapping, this._stopper, this._minLength)
      : _stopperCode = _stopper.codeUnitAt(0);

  @override
  Result<String> parseOn(Context context) {
    final input = context.buffer;
    final length = input.length;
    final output = StringBuffer();
    var position = context.position;
    var start = position;

    // Scan over the characters as fast as possible.
    while (position < length) {
      final value = input.codeUnitAt(position);
      if (value == _stopperCode) {
        break;
      } else if (value == 38) {
        final index = input.indexOf(';', position + 1);
        if (position + 1 < index) {
          final entity = input.substring(position + 1, index);
          final value = _entityMapping.decodeEntity(entity);
          if (value != null) {
            output.write(input.substring(start, position));
            output.write(value);
            position = index + 1;
            start = position;
          } else {
            position++;
          }
        } else {
          position++;
        }
      } else {
        position++;
      }
    }
    output.write(input.substring(start, position));

    // Check for the minimum length.
    return output.length < _minLength
        ? context.failure('Unable to parse character data.')
        : context.success(output.toString(), position);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final start = position;
    final length = buffer.length;
    while (position < length) {
      final value = buffer.codeUnitAt(position);
      if (value == _stopperCode) {
        break;
      } else {
        position++;
      }
    }
    return position - start < _minLength ? -1 : position;
  }

  @override
  XmlCharacterDataParser copy() =>
      XmlCharacterDataParser(_entityMapping, _stopper, _minLength);

  @override
  bool hasEqualProperties(XmlCharacterDataParser other) =>
      super.hasEqualProperties(other) &&
      _entityMapping == other._entityMapping &&
      _stopper == other._stopper &&
      _minLength == other._minLength;
}
