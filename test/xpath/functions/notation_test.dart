import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/notation.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('notation', () {
    test('op:NOTATION-equal', () {
      expect(
        opNotationEqual(context, [
          const XPathSequence.single('foo:bar'),
          const XPathSequence.single('foo:bar'),
        ]),
        [true],
      );
    });
  });
}
