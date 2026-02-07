import 'package:test/test.dart';
import 'package:xml/src/xpath/definitions/cardinality.dart';
import 'package:xml/src/xpath/definitions/function.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/types/any.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r/>');
final context = XPathContext(document);

const function = XPathFunctionDefinition(
  name: 'foo',
  requiredArguments: [XPathArgumentDefinition(name: 'req', type: xsString)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'opt',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  variadicArgument: XPathArgumentDefinition(name: 'var', type: xsAny),
  function: _function,
);

XPathSequence _function(
  XPathContext context,
  String req, [
  String? opt,
  List<Object> rest = const [],
]) => XPathSequence([req, ?opt, ...rest]);

void main() {
  group('XPathArgumentDefinition', () {
    test('accessors', () {
      const argument = XPathArgumentDefinition(
        name: 'arg',
        type: xsString,
        cardinality: XPathCardinality.zeroOrOne,
      );
      expect(argument.name, 'arg');
      expect(argument.type, xsString);
      expect(argument.cardinality, XPathCardinality.zeroOrOne);
    });
    test('convert (exactlyOne)', () {
      const def = XPathArgumentDefinition(
        name: 'arg',
        type: xsString,
        cardinality: XPathCardinality.exactlyOne,
      );
      expect(def.convert(function, const XPathSequence.single('a')), 'a');
      expect(
        () => def.convert(function, XPathSequence.empty),
        throwsA(
          isXPathEvaluationException(
            message:
                'Function "foo" expects exactly one value for argument "arg", but got none.',
          ),
        ),
      );
      expect(
        () => def.convert(function, const XPathSequence(['a', 'b'])),
        throwsA(
          isXPathEvaluationException(
            message:
                'Function "foo" expects exactly one value for argument "arg", but got more than one.',
          ),
        ),
      );
    });
    test('convert (zeroOrOne)', () {
      const def = XPathArgumentDefinition(
        name: 'arg',
        type: xsString,
        cardinality: XPathCardinality.zeroOrOne,
      );
      expect(def.convert(function, const XPathSequence.single('a')), 'a');
      expect(def.convert(function, XPathSequence.empty), isNull);
      expect(
        () => def.convert(function, const XPathSequence(['a', 'b'])),
        throwsA(
          isXPathEvaluationException(
            message:
                'Function "foo" expects zero or one value for argument "arg", but got more than one.',
          ),
        ),
      );
    });
    test('convert (oneOrMore)', () {
      const def = XPathArgumentDefinition(
        name: 'arg',
        type: xsString,
        cardinality: XPathCardinality.oneOrMore,
      );
      expect(def.convert(function, const XPathSequence.single('a')), ['a']);
      expect(def.convert(function, const XPathSequence(['a', 'b'])), [
        'a',
        'b',
      ]);
      expect(
        () => def.convert(function, XPathSequence.empty),
        throwsA(
          isXPathEvaluationException(
            message:
                'Function "foo" expects one or more values for argument "arg", but got none.',
          ),
        ),
      );
    });
    test('convert (zeroOrMore)', () {
      const def = XPathArgumentDefinition(
        name: 'arg',
        type: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      expect(def.convert(function, const XPathSequence.single('a')), ['a']);
      expect(def.convert(function, const XPathSequence(['a', 'b'])), [
        'a',
        'b',
      ]);
      expect(def.convert(function, XPathSequence.empty), isEmpty);
    });
    test('toString', () {
      expect(
        const XPathArgumentDefinition(name: 'arg', type: xsString).toString(),
        '\$arg as xs:string',
      );
      expect(
        const XPathArgumentDefinition(
          name: 'arg',
          type: xsString,
          cardinality: XPathCardinality.zeroOrOne,
        ).toString(),
        '\$arg as xs:string?',
      );
    });
  });
  group('XPathFunctionDefinition', () {
    test('accessors', () {
      expect(function.name, 'foo');
      expect(function.requiredArguments, hasLength(1));
      expect(function.optionalArguments, hasLength(1));
      expect(function.variadicArgument, isNotNull);
      expect(function.function, _function);
    });
    test('call (missing)', () {
      expect(
        () => function(context, const []),
        throwsA(
          isXPathEvaluationException(
            message: 'Function "foo" expects at least 1 arguments, but got 0.',
          ),
        ),
      );
    });
    test('call (required)', () {
      final result = function(context, const [XPathSequence.single('a')]);
      expect(result, const XPathSequence.single('a'));
    });
    test('call (optional)', () {
      final result = function(context, const [
        XPathSequence.single('a'),
        XPathSequence.single('b'),
      ]);
      expect(result, const XPathSequence(['a', 'b']));
    });
    test('call (variadic)', () {
      final result = function(context, const [
        XPathSequence.single('a'),
        XPathSequence.single('b'),
        XPathSequence.single('c'),
        XPathSequence.single('d'),
      ]);
      expect(result, const XPathSequence(['a', 'b', 'c', 'd']));
    });
    test('call (too many arguments)', () {
      final noArgumentFunction = XPathFunctionDefinition(
        name: 'f',
        requiredArguments: const [],
        function: (context) => XPathSequence.empty,
      );
      expect(
        () => noArgumentFunction.call(context, const [
          XPathSequence.single('a'),
          XPathSequence.single('b'),
        ]),
        throwsA(
          isXPathEvaluationException(
            message: 'Function "f" expects at most 0 arguments, but got 2.',
          ),
        ),
      );
    });
    test('toString', () {
      expect(
        function.toString(),
        'foo(\$req as xs:string, \$opt as xs:string?, ...)',
      );
    });
  });
}
