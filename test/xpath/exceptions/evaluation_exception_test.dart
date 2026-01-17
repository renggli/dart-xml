import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  group('XPathEvaluationException', () {
    test('checkArgumentCount', () {
      expect(
        () => XPathEvaluationException.checkArgumentCount('foo', [], 1),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Function "foo" expects 1 arguments, but got 0',
          ),
        ),
      );
      expect(
        () => XPathEvaluationException.checkArgumentCount('foo', [], 1, 2),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Function "foo" expects between 1 and 2 arguments, but got 0',
          ),
        ),
      );
      expect(
        () => XPathEvaluationException.checkArgumentCount(
          'foo',
          [],
          1,
          unbounded,
        ),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Function "foo" expects at least 1 arguments, but got 0',
          ),
        ),
      );
      expect(
        () => XPathEvaluationException.checkArgumentCount('foo', ['a'], 1),
        returnsNormally,
      );
    });
    test('extractZeroOrOne', () {
      expect(
        XPathEvaluationException.extractZeroOrOne(
          'foo',
          'arg',
          XPathSequence.empty,
        ),
        isNull,
      );
      expect(
        XPathEvaluationException.extractZeroOrOne(
          'foo',
          'arg',
          const XPathSequence.single('a'),
        ),
        'a',
      );
      expect(
        () => XPathEvaluationException.extractZeroOrOne(
          'foo',
          'arg',
          const XPathSequence(['a', 'b']),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('extractExactlyOne', () {
      expect(
        () => XPathEvaluationException.extractExactlyOne(
          'foo',
          'arg',
          XPathSequence.empty,
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        XPathEvaluationException.extractExactlyOne(
          'foo',
          'arg',
          const XPathSequence.single('a'),
        ),
        'a',
      );
      expect(
        () => XPathEvaluationException.extractExactlyOne(
          'foo',
          'arg',
          const XPathSequence(['a', 'b']),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('extractOneOrMore', () {
      expect(
        () => XPathEvaluationException.extractOneOrMore(
          'foo',
          'arg',
          XPathSequence.empty,
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
      const single = XPathSequence.single('a');
      expect(
        XPathEvaluationException.extractOneOrMore('foo', 'arg', single),
        same(single),
      );
      const multiple = XPathSequence(['a', 'b']);
      expect(
        XPathEvaluationException.extractOneOrMore('foo', 'arg', multiple),
        same(multiple),
      );
    });
    test('checkVariable', () {
      const value = XPathSequence.single('a');
      expect(XPathEvaluationException.checkVariable('var', value), same(value));
      expect(
        () => XPathEvaluationException.checkVariable('var', null),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Undeclared variable "var"',
          ),
        ),
      );
    });
    test('checkFunction', () {
      XPathSequence function(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.empty;
      expect(
        XPathEvaluationException.checkFunction('fun', function),
        same(function),
      );
      expect(
        () => XPathEvaluationException.checkFunction('fun', null),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Undeclared function "fun"',
          ),
        ),
      );
    });
    test('unsupportedCast', () {
      expect(
        () => XPathEvaluationException.unsupportedCast('value', 'Type'),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Unsupported cast from value to Type',
          ),
        ),
      );
    });
    test('invalidMapKey', () {
      expect(
        () => XPathEvaluationException.invalidMapKey(XPathSequence.empty),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            'Invalid map key: ()',
          ),
        ),
      );
    });
    test('toString', () {
      expect(
        XPathEvaluationException('message').toString(),
        'XPathEvaluationException: message',
      );
    });
  });
}
