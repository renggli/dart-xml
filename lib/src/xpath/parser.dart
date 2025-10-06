import 'package:petitparser/definition.dart';
import 'package:petitparser/expression.dart';
import 'package:petitparser/parser.dart';

import '../xml/entities/null_mapping.dart';
import '../xml_events/parser.dart';
import 'evaluation/expression.dart';
import 'evaluation/values.dart';
import 'expressions/axis.dart';
import 'expressions/function.dart';
import 'expressions/node_test.dart';
import 'expressions/path.dart';
import 'expressions/predicate.dart';
import 'expressions/step.dart';
import 'expressions/variable.dart';
import 'functions/boolean.dart' as boolean;
import 'functions/nodes.dart' as nodes;
import 'functions/number.dart' as number;

// XPath 1.0: https://www.w3.org/TR/1999/REC-xpath-19991116/
// XPath 2.0: https://www.w3.org/TR/xpath20/
// XPath 3.0: https://www.w3.org/TR/xpath-30/
// XPath 3.1: https://www.w3.org/TR/xpath-31/
// https://www.w3.org/TR/xpath-functions-30/
class XPathParser {
  const XPathParser();

  Parser<XPathExpression> build() => resolve(ref0(start).end());

  Parser<XPathExpression> start() =>
      [ref0(path), ref0(expression)].toChoiceParser();

  Parser<XPathExpression> expression() {
    final builder = ExpressionBuilder<XPathExpression>();
    builder
      ..primitive(ref0(literal))
      ..primitive(ref0(variable))
      ..primitive(ref0(function))
      ..primitive(ref0(path));
    builder.group().wrapper(token('('), token(')'), (_, expr, _) => expr);
    builder.group().postfix(ref0(predicate), PredicateExpression.new);
    builder.group()
      ..prefix(token('-'), (t, a) => _SFE(t, number.neg, [a]))
      ..prefix(token('+'), (t, a) => a);
    builder.group()
      ..left(token('intersect'), (a, t, b) => _SFE(t, nodes.intersect, [a, b]))
      ..left(token('except'), (a, t, b) => _SFE(t, nodes.except, [a, b]));
    builder.group()
      ..left(token('union'), (a, t, b) => _SFE(t, nodes.union, [a, b]))
      ..left(token('|'), (a, t, b) => _SFE(t, nodes.union, [a, b]));
    builder.group()
      ..left(token('*'), (a, t, b) => _SFE(t, number.mul, [a, b]))
      ..left(token('div'), (a, t, b) => _SFE(t, number.div, [a, b]))
      ..left(token('idiv'), (a, t, b) => _SFE(t, number.idiv, [a, b]))
      ..left(token('mod'), (a, t, b) => _SFE(t, number.mod, [a, b]));
    builder.group()
      ..left(token('+'), (a, t, b) => _SFE(t, number.add, [a, b]))
      ..left(token('-'), (a, t, b) => _SFE(t, number.sub, [a, b]));
    builder.group()
      ..left(token('='), (a, t, b) => _SFE(t, boolean.equal, [a, b]))
      ..left(token('!='), (a, t, b) => _SFE(t, boolean.notEqual, [a, b]))
      ..left(token('<='), (a, t, b) => _SFE(t, boolean.lessThanOrEqual, [a, b]))
      ..left(token('<'), (a, t, b) => _SFE(t, boolean.lessThan, [a, b]))
      ..left(
        token('>='),
        (a, t, b) => _SFE(t, boolean.greaterThanOrEqual, [a, b]),
      )
      ..left(token('>'), (a, t, b) => _SFE(t, boolean.greaterThan, [a, b]));
    builder.group().left(
      token('and'),
      (a, t, b) => _SFE(t, boolean.and, [a, b]),
    );
    builder.group().left(token('or'), (a, t, b) => _SFE(t, boolean.or, [a, b]));
    return builder.build();
  }

  Parser<XPathExpression> path() => [
    ref0(absolutePath).map((steps) => PathExpression(steps, isAbsolute: true)),
    ref0(relativePath).map((steps) => PathExpression(steps, isAbsolute: false)),
  ].toChoiceParser();

  Parser<List<Step>> absolutePath() => [
    seq2(
      token('//'),
      ref0(relativePath),
    ).map2((_, steps) => [const Step(DescendantOrSelfAxis()), ...steps]),
    seq2(
      token('/'),
      ref0(relativePath).optionalWith([]),
    ).map2((start, steps) => steps),
  ].toChoiceParser();

  Parser<List<Step>> relativePath() => ref0(step)
      .plusSeparated([token('//'), token('/')].toChoiceParser())
      .map((list) {
        final steps = [list.elements.first];
        for (var i = 1; i < list.elements.length; i++) {
          final sep = list.separators[i - 1];
          if (sep == '//') {
            steps.add(const Step(DescendantOrSelfAxis()));
          }
          steps.add(list.elements[i]);
        }
        return steps;
      });

  Parser<Step> step() => [
    ref0(abbrevStep),
    seq3(ref0(axis).optional(), ref0(nodeTest), ref0(predicate).star()).map3(
      (axis, nodeTest, predicates) =>
          Step(axis ?? const ChildAxis(), nodeTest, predicates),
    ),
  ].toChoiceParser();

  Parser<Step> abbrevStep() => [
    token('..').map((_) => const Step(ParentAxis())),
    token('.').map((_) => const Step(SelfAxis())),
  ].toChoiceParser();

  Parser<Axis> axis() => [
    [
      token('attribute::'),
      token('@'),
    ].toChoiceParser().map((_) => const AttributeAxis()),
    token('child::').map((_) => const ChildAxis()),
    token('descendant-or-self::').map((_) => const DescendantOrSelfAxis()),
    token('descendant::').map((_) => const DescendantAxis()),
    token('following-sibling::').map((_) => const FollowingSiblingAxis()),
    token('following::').map((_) => const FollowingAxis()),
    token('self::').map((_) => const SelfAxis()),
    token('ancestor-or-self::').map((_) => const AncestorOrSelfAxis()),
    token('ancestor::').map((_) => const AncestorAxis()),
    token('parent::').map((_) => const ParentAxis()),
    token('preceding-sibling::').map((_) => const PrecedingSiblingAxis()),
    token('preceding::').map((_) => const PrecedingAxis()),
  ].toChoiceParser();

  Parser<NodeTest> nodeTest() => [
    ref0(kindTest),
    ref0(nameTest),
    failure<NodeTest>(message: 'node test expected'),
  ].toChoiceParser();

  Parser<NodeTest> kindTest() => [
    functionCall(token('attribute')).map((_) => const AttributeTypeNodeTest()),
    functionCall(token('comment')).map((_) => const CommentTypeNodeTest()),
    functionCall(
      token('document-node'),
    ).map((_) => const DocumentTypeNodeTest()),
    functionCall(token('element')).map((_) => const ElementTypeNodeTest()),
    functionCall(token('node')).map((_) => const NodeTypeNodeTest()),
    functionCallWithArguments(
      token('processing-instruction'),
      [ref0(nonColonizedName), ref0(string)].toChoiceParser(),
      max: 1,
    ).map2((_, args) => ProcessingTypeNodeTest(args.firstOrNull)),
    functionCall(token('text')).map((_) => const TextTypeNodeTest()),
  ].toChoiceParser();

  Parser<NodeTest> nameTest() => [
    seq3(
      token('*'),
      token(':'),
      ref0(nonColonizedName),
    ).map3((_, _, localName) => LocalNameNodeTest(localName)),
    token('*').map((_) => const NameNodeTest()),
    seq2(
      ref0(bracedUri),
      token('*'),
    ).map2((namespaceUri, _) => NamespaceUriNodeTest(namespaceUri)),
    seq2(
      ref0(bracedUri),
      ref0(nonColonizedName),
    ).map2(NamespaceUriAndLocalNameNodeTest.new),
    seq3(ref0(nonColonizedName), token(':'), token('*')).map3(
      (namespacePrefix, _, _) => NamespacePrefixNameNodeTest(namespacePrefix),
    ),
    seq2(
      ref0(qualifiedName),
      char('(').not(),
    ).map2((qualifiedName, _) => QualifiedNameNodeTest(qualifiedName)),
  ].toChoiceParser();

  Parser<Predicate> predicate() => seq3(
    token('['),
    ref0(expression),
    token(']'),
  ).map3((_, expr, _) => Predicate(expr));

  Parser<XPathExpression> literal() =>
      [ref0(numberLiteral), ref0(stringLiteral)].toChoiceParser();

  Parser<XPathExpression> numberLiteral() => trim(
    seq3(
      digit().plus(),
      seq2(char('.'), digit().plus()).optional(),
      seq3(anyOf('eE'), anyOf('+-').optional(), digit().plus()).optional(),
    ).flatten(message: 'number'),
  ).map((value) => XPathNumber(num.parse(value)));

  Parser<XPathExpression> stringLiteral() => ref0(string).map(XPathString.new);

  Parser<String> string() => trim(
    [
      ref0(eventParser.attributeValueDoubleQuote),
      ref0(eventParser.attributeValueSingleQuote),
    ].toChoiceParser(),
  ).map2((value, _) => value);

  Parser<XPathExpression> variable() => trim(
    seq2(char('\$'), ref0(qualifiedName)),
  ).map2((_, name) => VariableExpression(name));

  Parser<XPathExpression> function() => functionCallWithArguments(
    ref0(qualifiedName),
    ref0(expression),
  ).map2(_DFE.new);

  Parser<String> bracedUri() => trim(
    seq3('Q{'.toParser(), pattern('^{}').starString(), '}'.toParser()),
  ).map3((_, uri, _) => uri);

  Parser<N> functionCall<N>(Parser<N> name) =>
      seq3(name, token('('), token(')')).map3((name, _, _) => name);
  Parser<(N, List<A>)> functionCallWithArguments<N, A>(
    Parser<N> name,
    Parser<A> arguments, {
    int min = 0,
    int max = unbounded,
  }) => seq4(
    name,
    token('('),
    arguments.repeatSeparated(token(','), min, max),
    token(')'),
  ).map4((name, _, args, _) => (name, args.elements));

  Parser<String> qualifiedName() => trim(ref0(eventParser.qualifiedNameToken));
  Parser<String> nonColonizedName() =>
      trim(ref0(eventParser.nonColonizedNameToken));

  Parser<String> token(String token) => ref1(trim, token.toParser());
  Parser<T> trim<T>(Parser<T> parser) => parser.trim(ref0(whitespace));

  Parser<void> whitespace() => [ref0(_space), ref0(_comment)].toChoiceParser();
  Parser<void> _space() => pattern('\u{9}\u{A}\u{D}\u{20}');
  Parser<void> _comment() => seq3(
    '(:'.toParser(),
    [ref0(_comment), ':)'.toParser().neg()].toChoiceParser().star(),
    ':)'.toParser(),
  );

  static const eventParser = XmlEventParser(XmlNullEntityMapping());
}

typedef _SFE = StaticFunctionExpression;
typedef _DFE = DynamicFunctionExpression;
