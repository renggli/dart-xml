import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types31/array.dart';
import 'package:xml/src/xpath/types31/boolean.dart';
import 'package:xml/src/xpath/types31/date_time.dart';
import 'package:xml/src/xpath/types31/duration.dart';
import 'package:xml/src/xpath/types31/map.dart';
import 'package:xml/src/xpath/types31/node.dart';
import 'package:xml/src/xpath/types31/number.dart';
import 'package:xml/src/xpath/types31/sequence.dart';
import 'package:xml/src/xpath/types31/string.dart';
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
      expect(XmlCDATA('bar').toXPathString(), 'bar');
      expect(XmlComment('baz').toXPathString(), 'baz');
      expect(XmlProcessing('target', 'qux').toXPathString(), 'qux');
    });
    test('cast from sequence', () {
      expect(XPathSequence.empty.toXPathString(), '');
      expect(XPathSequence.single('abc').toXPathString(), 'abc');
      expect(XPathSequence.single(123).toXPathString(), '123');
      expect(
        () => const XPathSequence(['a', 'b']).toXPathString(),
        throwsA(isA<XPathEvaluationException>()),
      );
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
      expect(XPathSequence.empty.toXPathBoolean(), false);
      expect(XPathSequence.single(node).toXPathBoolean(), true);
      expect(XPathSequence([node, document]).toXPathBoolean(), true);
      expect(const XPathSequence([1]).toXPathBoolean(), true);
      expect(const XPathSequence([0]).toXPathBoolean(), false);
      expect(
        () => const XPathSequence([1, 2]).toXPathBoolean(),
        throwsA(isA<XPathEvaluationException>()),
      );
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
      expect(
        () => XPathSequence.empty.toXPathNumber(),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(XPathSequence.single(123).toXPathNumber(), 123);
      expect(
        () => const XPathSequence([123, 456]).toXPathNumber(),
        throwsA(isA<XPathEvaluationException>()),
      );
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
      expect(
        () => XPathSequence.empty.toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(XPathSequence.single(node).toXPathNode(), node);
      expect(
        () => [node, document].toXPathNode(),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(() => [1].toXPathNode(), throwsA(isA<XPathEvaluationException>()));
    });
  });
  group('array', () {
    test('cast from array', () {
      final array = [1, 2, 3];
      expect(array.toXPathArray(), array);
    });
    test('cast from sequence', () {
      expect(XPathSequence.single([1, 2]).toXPathArray(), [1, 2]);
      expect(
        () => XPathSequence.empty.toXPathArray(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(
        () => 123.toXPathArray(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
  group('date time', () {
    test('cast from date time', () {
      final dateTime = DateTime.now();
      expect(dateTime.toXPathDateTime(), dateTime);
    });
    test('cast from string', () {
      final dateTime = DateTime.parse('2021-01-01T00:00:00.000');
      expect('2021-01-01T00:00:00.000'.toXPathDateTime(), dateTime);
      expect(
        () => 'invalid'.toXPathDateTime(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from sequence', () {
      final dateTime = DateTime.now();
      expect(XPathSequence.single(dateTime).toXPathDateTime(), dateTime);
      expect(
        () => XPathSequence.empty.toXPathDateTime(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(
        () => 123.toXPathDateTime(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
  group('duration', () {
    test('cast from duration', () {
      const duration = Duration(seconds: 1);
      expect(duration.toXPathDuration(), duration);
    });
    test('cast from string', () {
      expect(() => 'P1Y'.toXPathDuration(), throwsA(isA<UnimplementedError>()));
    });
    test('cast from sequence', () {
      const duration = Duration(seconds: 1);
      expect(XPathSequence.single(duration).toXPathDuration(), duration);
      expect(
        () => XPathSequence.empty.toXPathDuration(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(
        () => 123.toXPathDuration(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
  group('map', () {
    test('cast from map', () {
      final map = {'a': 1};
      expect(map.toXPathMap(), map);
    });
    test('cast from sequence', () {
      final map = {'a': 1};
      expect(XPathSequence.single(map).toXPathMap(), map);
      expect(
        () => XPathSequence.empty.toXPathMap(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('cast from other', () {
      expect(() => 123.toXPathMap(), throwsA(isA<XPathEvaluationException>()));
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
      expect(XPathSequence.empty.toXPathSequence(), isEmpty);
      expect('abc'.toXPathSequence(), XPathSequence.single('abc'));
      expect([1, 2].toXPathSequence(), XPathSequence.single([1, 2]));
      expect(
        XPathSequence.trueSequence.toXPathSequence(),
        XPathSequence.trueSequence,
      );
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
