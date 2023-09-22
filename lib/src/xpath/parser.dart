import 'package:petitparser/definition.dart';
import 'package:petitparser/expression.dart';
import 'package:petitparser/parser.dart';

import '../xml/entities/null_mapping.dart';
import '../xml_events/parser.dart';
import 'evaluation/expression.dart';
import 'evaluation/values.dart';
import 'expressions/axis.dart';
import 'expressions/filters.dart';
import 'expressions/function.dart';
import 'expressions/path.dart';
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

  Parser<XPathExpression> start() => [
        ref0(path),
        ref0(expression),
      ].toChoiceParser();

  Parser<XPathExpression> expression() {
    final builder = ExpressionBuilder<XPathExpression>();
    builder
      ..primitive(ref0(literal))
      ..primitive(ref0(variable))
      ..primitive(ref0(function))
      ..primitive(ref0(path));
    builder.group().wrapper(_t('('), _t(')'), (_, expr, __) => expr);
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
        ref0(absolutePath),
        ref0(relativePath),
      ].toChoiceParser().map(SequenceExpression.new);

  Parser<List<XPathExpression>> absolutePath() =>
      seq2(_t('/'), ref0(relativePath).optionalWith([]))
          .map2((_, path) => [RootAxisExpression(), ...path]);

  Parser<List<XPathExpression>> relativePath() => ref0(step)
      .plusSeparated(_t('/'))
      .map((list) => list.elements.map(SequenceExpression.new).toList());

  Parser<List<XPathExpression>> step() => ref0(axisStep);

  Parser<List<XPathExpression>> axisStep() => seq2(
        [
          ref0(reverseStep),
          ref0(forwardStep),
        ].toChoiceParser(),
        ref0(predicate).star(),
      ).map2((step, predicates) => [...step, ...predicates]);

  Parser<List<XPathExpression>> reverseStep() => [
        [ref0(reverseAxis), ref0(nodeTest)].toSequenceParser(),
        ref0(abbrevReverseStep),
      ].toChoiceParser();

  Parser<XPathExpression> reverseAxis() => [
        _t('ancestor-or-self::').map((_) => AncestorOrSelfAxisExpression()),
        _t('ancestor::').map((_) => AncestorAxisExpression()),
        _t('parent::').map((_) => ParentAxisExpression()),
        _t('preceding-sibling::').map((_) => PrecedingSiblingAxisExpression()),
        _t('preceding::').map((_) => PrecedingAxisExpression()),
      ].toChoiceParser();

  Parser<List<XPathExpression>> abbrevReverseStep() => [
        _t('..').map((_) => [ParentAxisExpression()]),
        _t('.').map((_) => [SelfAxisExpression()]),
      ].toChoiceParser();

  Parser<List<XPathExpression>> forwardStep() => [
        [ref0(forwardAxis), ref0(nodeTest)].toSequenceParser(),
        ref0(abbrevForwardStep),
      ].toChoiceParser();

  Parser<XPathExpression> forwardAxis() => [
        _t('attribute::').map((_) => AttributeAxisExpression()),
        _t('child::').map((_) => ChildAxisExpression()),
        _t('descendant-or-self::').map((_) => DescendantOrSelfAxisExpression()),
        _t('descendant::').map((_) => DescendantAxisExpression()),
        _t('following-sibling::').map((_) => FollowingSiblingAxisExpression()),
        _t('following::').map((_) => FollowingAxisExpression()),
        _t('self::').map((_) => SelfAxisExpression()),
      ].toChoiceParser();

  Parser<List<XPathExpression>> abbrevForwardStep() => [
        seq2(_t('/'), ref0(nodeTest))
            .map2((_, test) => [DescendantOrSelfAxisExpression(), test]),
        seq2(_t('@'), ref0(nodeTest))
            .map2((_, test) => [AttributeAxisExpression(), test]),
        ref0(nodeTest).map((test) => [ChildAxisExpression(), test]),
      ].toChoiceParser();

  Parser<XPathExpression> nodeTest() => [
        ref0(kindTest),
        ref0(nameTest),
      ].toChoiceParser();

  Parser<XPathExpression> kindTest() => [
        _t('comment()').map((_) => CommentTypeExpression()),
        _t('node()').map((_) => NodeTypeExpression()),
        seq3(_t('processing-instruction('), ref0(string).optional(), char(')'))
            .map3((_, target, __) => ProcessingTypeExpression(target)),
        _t('text()').map((_) => TextTypeExpression()),
      ].toChoiceParser();

  Parser<XPathExpression> nameTest() => [
        _t('*').map((_) => HasNameExpression()),
        seq2(ref0(name), char('(').not())
            .map2((name, _) => QualifiedNameExpression(name)),
      ].toChoiceParser();

  Parser<XPathExpression> predicate() =>
      seq3(char('['), ref0(expression), char(']'))
          .map3((_, expr, __) => PredicateExpression(expr));

  Parser<XPathExpression> literal() => [
        ref0(numberLiteral),
        ref0(stringLiteral),
      ].toChoiceParser();

  Parser<XPathExpression> numberLiteral() => seq3(
        digit().plus(),
        seq2(char('.'), digit().plus()).optional(),
        seq3(anyOf('eE'), anyOf('+-').optional(), digit().plus()).optional(),
      ).flatten('number').map((value) => XPathNumber(num.parse(value)));

  Parser<XPathExpression> stringLiteral() => ref0(string).map(XPathString.new);

  Parser<String> string() => [
        ref0(eventParser.attributeValueDoubleQuote),
        ref0(eventParser.attributeValueSingleQuote),
      ].toChoiceParser().map2((value, _) => value);

  Parser<XPathExpression> variable() => seq2(char('\$'), ref0(name))
      .trim()
      .map2((_, name) => VariableExpression(name));

  Parser<XPathExpression> function() => seq5(
        ref0(name).trim(),
        _t('('),
        ref0(expression)
            .starSeparated(char(',').trim())
            .map((list) => list.elements),
        _t(',').optional(),
        _t(')'),
      ).map5((name, _, args, __, ___) => _DFE(name, args));

  Parser<String> name() => ref0(eventParser.nameToken);

  static const eventParser = XmlEventParser(XmlNullEntityMapping());
}

Parser<String> _t(String value) => value.toParser().trim();

typedef _SFE = StaticFunctionExpression;
typedef _DFE = DynamicFunctionExpression;
