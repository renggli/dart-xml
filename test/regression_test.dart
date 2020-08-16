import 'package:test/test.dart';

import 'assertions.dart';

void main() {
  test('https://github.com/renggli/dart-xml/issues/38', () {
    const input = '<?xml?><InstantaneousDemand><DeviceMacId>'
        '0xd8d5b9000000b3e8</DeviceMacId><MeterMacId>0x00135003007c27b4'
        '</MeterMacId><TimeStamp>0x2244aeb3</TimeStamp><Demand>0x0006c1'
        '</Demand><Multiplier>0x00000001</Multiplier><Divisor>0x000003e8'
        '</Divisor><DigitsRight>0x03</DigitsRight><DigitsLeft>0x0f'
        '</DigitsLeft><SuppressLeadingZero>Y</SuppressLeadingZero>'
        '</InstantaneousDemand>';
    assertDocumentParseInvariants(input);
  });
}
