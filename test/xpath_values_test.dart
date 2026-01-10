import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/values31/boolean.dart';
import 'package:xml/src/xpath/values31/node.dart';
import 'package:xml/src/xpath/values31/number.dart';
import 'package:xml/src/xpath/values31/sequence.dart';
import 'package:xml/src/xpath/values31/string.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  final node = document.findAllElements('a').single;

  group('string', () {
    test('cast from string', () {
      expect('abc'.toXPathString(), 'abc');
      expect(''.toXPathString(), '');
    });
    test('cast from boolean', () {
      expect(true.toXPathString(), 'true');
      expect(false.toXPathString(), 'false');
    });
    test('cast from number', () {
      expect(123.toXPathString(), '123');
      expect(123.45.toXPathString(), '123.45');
      expect(123.0.toXPathString(), '123');
      expect(0.toXPathString(), '0');
      expect(0.0.toXPathString(), '0');
      expect((-0.0).toXPathString(), '0');
      expect(double.nan.toXPathString(), 'NaN');
      expect(double.infinity.toXPathString(), 'INF');
      expect(double.negativeInfinity.toXPathString(), '-INF');
    });
    test('cast from node', () {
      expect(document.toXPathString(), '123');
      expect(document.rootElement.toXPathString(), '123');
      expect(document.findAllElements('b').first.toXPathString(), '23');
      expect(XmlText('foo').toXPathString(), 'foo');
    });
    test('cast from sequence', () {
      expect(<Object>[].toXPathString(), '');
      expect(['abc'].toXPathString(), 'abc');
      expect([123].toXPathString(), '123');
      expect(
        () => ['a', 'b'].toXPathString(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast to sequence', () {
      expect('abc'.toXPathSequence(), ['abc']);
    });
  });
  group('boolean', () {
    test('cast from boolean', () {
      expect(true.toXPathBoolean(), true);
      expect(false.toXPathBoolean(), false);
    });
    test('cast from number', () {
      expect(1.toXPathBoolean(), true);
      expect(0.toXPathBoolean(), false);
      expect(double.nan.toXPathBoolean(), false);
    });
    test('cast from string', () {
      expect('abc'.toXPathBoolean(), true);
      expect(''.toXPathBoolean(), false);
    });
    test('cast from node', () {
      expect(node.toXPathBoolean(), true);
    });
    test('cast from sequence', () {
      expect(<Object>[].toXPathBoolean(), false);
      expect([node].toXPathBoolean(), true);
      expect([node, document].toXPathBoolean(), true);
      expect([1].toXPathBoolean(), true);
      expect([0].toXPathBoolean(), false);
      expect(
        () => [1, 2].toXPathBoolean(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast to sequence', () {
      expect(true.toXPathSequence(), [true]);
    });
  });
  group('number', () {
    test('cast from number', () {
      expect(123.toXPathNumber(), 123);
      expect(123.45.toXPathNumber(), 123.45);
    });
    test('cast from boolean', () {
      expect(true.toXPathNumber(), 1);
      expect(false.toXPathNumber(), 0);
    });
    test('cast from string', () {
      expect('123'.toXPathNumber(), 123);
      expect('abc'.toXPathNumber(), isNaN);
    });
    test('cast from node', () {
      expect(node.toXPathNumber(), 1);
    });
    test('cast from sequence', () {
      expect(<Object>[].toXPathNumber(), isNaN);
      expect([123].toXPathNumber(), 123);
      expect(
        () => [123, 456].toXPathNumber(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast to sequence', () {
      expect(123.toXPathSequence(), [123]);
    });
  });
  group('node', () {
    test('cast from number', () {
      expect(() => 123.toXPathNode(), throwsA(isA<XPathEvaluationException>()));
      expect(
        () => 123.45.toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from boolean', () {
      expect(
        () => true.toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => false.toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from string', () {
      expect(
        () => 'abc'.toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from node', () {
      expect(node.toXPathNode(), node);
      expect(document.toXPathNode(), document);
    });
    test('cast from sequence', () {
      expect([node].toXPathNode(), node);
      expect(
        () => [node, document].toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(() => [1].toXPathNode(), throwsA(isA<XPathEvaluationException>()));
    });
    test('cast to sequence', () {
      expect(node.toXPathSequence(), [node]);
    });
  });

  group('sequence', () {
    test('emtpy', () {
      expect(XPathSequence.empty, isEmpty);
      expect(XPathSequence.empty.length, 0);
    });
    test('single', () {
      final sequence = XPathSequence.single(123);
      expect(sequence, isNotEmpty);
      expect(sequence.length, 1);
      expect(sequence.first, 123);
    });
    test('range', () {
      final sequence = XPathSequence.range(1, 3);
      expect(sequence, isNotEmpty);
      expect(sequence.length, 3);
      expect(sequence, [1, 2, 3]);
    });
    test('range (single)', () {
      final sequence = XPathSequence.range(1, 1);
      expect(sequence, isNotEmpty);
      expect(sequence.length, 1);
      expect(sequence, [1]);
    });
    test('range (empty)', () {
      final sequence = XPathSequence.range(1, 0);
      expect(sequence, isEmpty);
      expect(sequence.length, 0);
    });
    test('true sequence', () {
      expect(XPathSequence.trueSequence, [true]);
    });
    test('false sequence', () {
      expect(XPathSequence.falseSequence, [false]);
    });
    test('cast to sequence', () {
      expect([1, 2].toXPathSequence(), [1, 2]);
      expect(XPathSequence.empty.toXPathSequence(), isEmpty);
    });
    test('range efficiency', () {
      final range = XPathSequence.range(1, 1000000);
      expect(range.length, 1000000);
      expect(range.first, 1);
      expect(range.last, 1000000);
      expect(range.elementAt(500), 501);
      expect(range.contains(500000), true);
      expect(range.contains(0), false);
      expect(range.contains(1000001), false);
    });
    test('singular efficiency', () {
      final singular = XPathSequence.single('foo');
      expect(singular.length, 1);
      expect(singular.first, 'foo');
      expect(singular.last, 'foo');
      expect(singular.single, 'foo');
      expect(singular.contains('foo'), true);
      expect(singular.contains('bar'), false);
    });
  });
}
