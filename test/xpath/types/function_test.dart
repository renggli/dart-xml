import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/array.dart';
import 'package:xml/src/xpath/types/function.dart';
import 'package:xml/src/xpath/types/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r/>');
  final context = XPathContext(document);

  test('cast from function', () {
    XPathSequence myFunction(
      XPathContext context,
      List<XPathSequence> arguments,
    ) => const XPathSequence.single('ok');

    final function = myFunction.toXPathFunction();
    expect(function, myFunction);
    expect(function(context, const <XPathSequence>[]), ['ok']);
  });
  test('cast from XPathArray (array as function)', () {
    const array = XPathArray(['a', 'b', 'c']);
    final function = array.toXPathFunction();
    final result1 = function(context, [const XPathSequence.single(1)]);
    expect(result1, ['a']);
    final result2 = function(context, [const XPathSequence.single(2)]);
    expect(result2, ['b']);
    expect(
      () => function(context, [const XPathSequence.single(4)]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('cast from XPathMap (map as function)', () {
    const map = XPathMap({'key1': 'val1', 'key2': 'val2'});
    final function = map.toXPathFunction();
    final result1 = function(context, [const XPathSequence.single('key1')]);
    expect(result1, ['val1']);
    final result2 = function(context, [const XPathSequence.single('unknown')]);
    expect(result2, isEmpty);
  });
  test('cast from XPathSequence (containing a function)', () {
    XPathSequence myFunction(
      XPathContext context,
      List<XPathSequence> arguments,
    ) => const XPathSequence.single('sequence-ok');

    final sequence = XPathSequence.single(myFunction);
    final function = sequence.toXPathFunction();
    expect(function(context, const <XPathSequence>[]), ['sequence-ok']);
  });
  test('cast from unsupported type', () {
    expect(
      () => 'string'.toXPathFunction(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(
      () => 123.toXPathFunction(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(
      () => XPathSequence.empty.toXPathFunction(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(
      () => const XPathSequence(['a', 'b']).toXPathFunction(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
}
