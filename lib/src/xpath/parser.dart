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
    builder.group().wrapper(_t('('), _t(')'), (_, expr, _) => expr);
    builder.group()
      ..prefix(_t('-'), (t, a) => _SFE(t, number.neg, [a]))
      ..prefix(_t('+'), (t, a) => a);
    builder.group()
      ..left(_t('intersect'), (a, t, b) => _SFE(t, nodes.intersect, [a, b]))
      ..left(_t('except'), (a, t, b) => _SFE(t, nodes.except, [a, b]));
    builder.group()
      ..left(_t('union'), (a, t, b) => _SFE(t, nodes.union, [a, b]))
      ..left(_t('|'), (a, t, b) => _SFE(t, nodes.union, [a, b]));
    builder.group()
      ..left(_t('*'), (a, t, b) => _SFE(t, number.mul, [a, b]))
      ..left(_t('div'), (a, t, b) => _SFE(t, number.div, [a, b]))
      ..left(_t('idiv'), (a, t, b) => _SFE(t, number.idiv, [a, b]))
      ..left(_t('mod'), (a, t, b) => _SFE(t, number.mod, [a, b]));
    builder.group()
      ..left(_t('+'), (a, t, b) => _SFE(t, number.add, [a, b]))
      ..left(_t('-'), (a, t, b) => _SFE(t, number.sub, [a, b]));
    builder.group()
      ..left(_t('='), (a, t, b) => _SFE(t, boolean.equal, [a, b]))
      ..left(_t('!='), (a, t, b) => _SFE(t, boolean.notEqual, [a, b]))
      ..left(_t('<='), (a, t, b) => _SFE(t, boolean.lessThanOrEqual, [a, b]))
      ..left(_t('<'), (a, t, b) => _SFE(t, boolean.lessThan, [a, b]))
      ..left(_t('>='), (a, t, b) => _SFE(t, boolean.greaterThanOrEqual, [a, b]))
      ..left(_t('>'), (a, t, b) => _SFE(t, boolean.greaterThan, [a, b]));
    builder.group().left(_t('and'), (a, t, b) => _SFE(t, boolean.and, [a, b]));
    builder.group().left(_t('or'), (a, t, b) => _SFE(t, boolean.or, [a, b]));
    return builder.build();
  }

  Parser<XPathExpression> path() => [
    ref0(absolutePath).map((steps) => PathExpression(steps, isAbsolute: true)),
    ref0(relativePath).map((steps) => PathExpression(steps, isAbsolute: false)),
  ].toChoiceParser();

  Parser<List<Step>> absolutePath() => [
    seq2(_t('//'), ref0(relativePath)).map2(
      (_, steps) => [Step.abbrevAxisStep(DescendantOrSelfAxis()), ...steps],
    ),
    seq2(
      _t('/'),
      ref0(relativePath).optionalWith([]),
    ).map2((start, steps) => steps),
  ].toChoiceParser();

  Parser<List<Step>> relativePath() => ref0(step)
      .plusSeparated([_t('//'), _t('/')].toChoiceParser())
      .map((list) {
        final steps = [list.elements.first];
        for (var i = 1; i < list.elements.length; i++) {
          final sep = list.separators[i - 1];
          if (sep == '//') {
            steps.add(Step.abbrevAxisStep(DescendantOrSelfAxis()));
          }
          steps.add(list.elements[i]);
        }
        return steps;
      });

  Parser<Step> step() => [
    ref0(abbrevStep),
    seq3(ref0(axis).optional(), ref0(nodeTest), ref0(predicate).star()).map3(
      (axis, nodeTest, predicates) =>
          Step(axis ?? ChildAxis(), nodeTest, predicates),
    ),
  ].toChoiceParser();

  Parser<Step> abbrevStep() => [
    _t('..').map((_) => Step.abbrevAxisStep(ParentAxis())),
    _t('.').map((_) => Step.abbrevAxisStep(SelfAxis())),
  ].toChoiceParser();

  Parser<Axis> axis() => [
    [_t('attribute::'), _t('@')].toChoiceParser().map((_) => AttributeAxis()),
    _t('child::').map((_) => ChildAxis()),
    _t('descendant-or-self::').map((_) => DescendantOrSelfAxis()),
    _t('descendant::').map((_) => DescendantAxis()),
    _t('following-sibling::').map((_) => FollowingSiblingAxis()),
    _t('following::').map((_) => FollowingAxis()),
    _t('self::').map((_) => SelfAxis()),
    _t('ancestor-or-self::').map((_) => AncestorOrSelfAxis()),
    _t('ancestor::').map((_) => AncestorAxis()),
    _t('parent::').map((_) => ParentAxis()),
    _t('preceding-sibling::').map((_) => PrecedingSiblingAxis()),
    _t('preceding::').map((_) => PrecedingAxis()),
  ].toChoiceParser();

  Parser<NodeTest> nodeTest() =>
      [ref0(kindTest), ref0(nameTest)].toChoiceParser();

  Parser<NodeTest> kindTest() => [
    _t('comment()').map((_) => CommentTypeNodeTest()),
    _t('node()').map((_) => NodeTypeNodeTest()),
    seq3(
      _t('processing-instruction('),
      ref0(string).optional(),
      char(')'),
    ).map3((_, target, _) => ProcessingTypeNodeTest(target)),
    _t('text()').map((_) => TextTypeNodeTest()),
  ].toChoiceParser();

  Parser<NodeTest> nameTest() => [
    _t('*').map((_) => HasNameNodeTest()),
    seq2(
      ref0(name),
      char('(').not(),
    ).map2((name, _) => QualifiedNameNodeTest(name)),
  ].toChoiceParser();

  Parser<Predicate> predicate() => seq3(
    char('['),
    ref0(expression),
    char(']'),
  ).map3((_, expr, _) => Predicate(expr));

  Parser<XPathExpression> literal() =>
      [ref0(numberLiteral), ref0(stringLiteral)].toChoiceParser();

  Parser<XPathExpression> numberLiteral() => seq3(
    digit().plus(),
    seq2(char('.'), digit().plus()).optional(),
    seq3(anyOf('eE'), anyOf('+-').optional(), digit().plus()).optional(),
  ).flatten(message: 'number').map((value) => XPathNumber(num.parse(value)));

  Parser<XPathExpression> stringLiteral() => ref0(string).map(XPathString.new);

  Parser<String> string() => [
    ref0(eventParser.attributeValueDoubleQuote),
    ref0(eventParser.attributeValueSingleQuote),
  ].toChoiceParser().map2((value, _) => value);

  Parser<XPathExpression> variable() => seq2(
    char('\$'),
    ref0(name),
  ).trim().map2((_, name) => VariableExpression(name));

  Parser<XPathExpression> function() => seq5(
    ref0(name).trim(),
    _t('('),
    ref0(
      expression,
    ).starSeparated(char(',').trim()).map((list) => list.elements),
    _t(',').optional(),
    _t(')'),
  ).map5((name, _, args, _, _) => _DFE(name, args));

  Parser<String> name() => ref0(eventParser.nameToken);

  static const eventParser = XmlEventParser(XmlNullEntityMapping());
}

Parser<String> _t(String value) => value.toParser().trim();

typedef _SFE = StaticFunctionExpression;
typedef _DFE = DynamicFunctionExpression;
