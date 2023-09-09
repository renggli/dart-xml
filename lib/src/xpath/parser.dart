// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:petitparser/definition.dart';
import 'package:petitparser/expression.dart';
import 'package:petitparser/parser.dart';

import '../xml/entities/null_mapping.dart';
import '../xml_events/parser.dart';
import 'functions/boolean.dart' as boolean_func;
import 'functions/nodes.dart' as nodes_func;
import 'functions/number.dart' as number_func;
import 'functions/string.dart' as string_func;
import 'resolver.dart';
import 'resolvers/axis.dart';
import 'resolvers/composition.dart';
import 'resolvers/name.dart';
import 'resolvers/operators.dart';
import 'resolvers/predicate.dart';
import 'resolvers/type.dart';
import 'values.dart';

// XPath 1.0: https://www.w3.org/TR/1999/REC-xpath-19991116/
// XPath 2.0: https://www.w3.org/TR/xpath20/
// XPath 3.0: https://www.w3.org/TR/xpath-30/
// XPath 3.1: https://www.w3.org/TR/xpath-31/
class XPathParser {
  const XPathParser();

  Parser<Resolver> build() => resolve(ref0(expression)).end();

  Parser<Resolver> expression() {
    final builder = ExpressionBuilder<Resolver>();

    builder
      ..primitive(ref0(literal))
      ..primitive(ref0(variable))
      ..primitive(ref0(function))
      ..primitive(ref0(path));

    builder.group()
      ..wrapper(_t('('), _t(')'), (_, a, __) => a)
      ..prefix(_t('-'), (_, a) => _FR([a], number_func.neg))
      ..prefix(_t('+'), (_, a) => a);

    builder.group()
      ..left(_t('intersect'), (a, _, b) => _FR([a, b], nodes_func.intersect))
      ..left(_t('except'), (a, _, b) => _FR([a, b], nodes_func.intersect));

    builder.group()
      ..left(_t('union'), (a, _, b) => _FR([a, b], nodes_func.union))
      ..left(_t('|'), (a, _, b) => _FR([a, b], nodes_func.union));

    builder.group()
      ..left(_t('*'), (a, _, b) => _FR([a, b], number_func.mul))
      ..left(_t('div'), (a, _, b) => _FR([a, b], number_func.div))
      ..left(_t('idiv'), (a, _, b) => _FR([a, b], number_func.idiv))
      ..left(_t('mod'), (a, _, b) => _FR([a, b], number_func.mod));

    builder.group()
      ..left(_t('+'), (a, _, b) => _FR([a, b], number_func.add))
      ..left(_t('-'), (a, _, b) => _FR([a, b], number_func.sub));

    builder.group()
      ..left(_t('='), (a, _, b) => _FR([a, b], boolean_func.equal))
      ..left(_t('!='), (a, _, b) => _FR([a, b], boolean_func.notEqual))
      ..left(_t('<='), (a, _, b) => _FR([a, b], boolean_func.lessThanOrEqual))
      ..left(_t('<'), (a, _, b) => _FR([a, b], boolean_func.lessThan))
      ..left(
          _t('>='), (a, _, b) => _FR([a, b], boolean_func.greaterThanOrEqual))
      ..left(_t('>'), (a, _, b) => _FR([a, b], boolean_func.greaterThan));

    builder.group()
      ..left(_t('and'), (a, _, b) => _LFR([a, b], boolean_func.and))
      ..left(_t('or'), (a, _, b) => _LFR([a, b], boolean_func.or));
    return builder.build();
  }

  Parser<Resolver> path() => [
        ref0(absolutePath),
        ref0(relativePath),
      ].toChoiceParser().map((path) => SequenceResolver.fromList(path));

  Parser<List<Resolver>> absolutePath() =>
      seq2(_t('/'), ref0(relativePath).optionalWith([]))
          .map2((_, path) => [RootAxisResolver(), ...path]);

  Parser<List<Resolver>> relativePath() =>
      ref0(step).plusSeparated(_t('/')).map((list) => list.elements);

  Parser<Resolver> step() => [
        ref0(fullStep),
        ref0(abbreviatedStep),
      ].toChoiceParser();

  Parser<Resolver> fullStep() => seq3(
        ref0(axis),
        ref0(nodeTest),
        ref0(predicate).star(),
      ).map3((axis, nodeTest, predicates) =>
          SequenceResolver.fromList([axis, nodeTest, ...predicates]));

  Parser<Resolver> abbreviatedStep() => [
        _t('..').map((_) => ParentAxisResolver()),
        _t('.').map((_) => SelfAxisResolver()),
      ].toChoiceParser();

  Parser<Resolver> axis() => [
        // Abbreviated Syntax
        _t('/').map((_) => DescendantAxisResolver()),
        _t('@').map((_) => AttributeAxisResolver()),
        // Full Syntax
        _t('ancestor-or-self::').map((_) => AncestorOrSelfAxisResolver()),
        _t('ancestor::').map((_) => AncestorAxisResolver()),
        _t('attribute::').map((_) => AttributeAxisResolver()),
        _t('child::').map((_) => ChildAxisResolver()),
        _t('descendant-or-self::').map((_) => DescendantOrSelfAxisResolver()),
        _t('descendant::').map((_) => DescendantAxisResolver()),
        _t('following-sibling::').map((_) => FollowingSiblingAxisResolver()),
        _t('following::').map((_) => FollowingAxisResolver()),
        _t('parent::').map((_) => ParentAxisResolver()),
        _t('preceding-sibling::').map((_) => PrecedingSiblingAxisResolver()),
        _t('preceding::').map((_) => PrecedingAxisResolver()),
        _t('self::').map((_) => SelfAxisResolver()),
        // Default
        epsilonWith(ChildAxisResolver()),
      ].toChoiceParser();

  Parser<Resolver> nodeTest() => [
        ref0(typeTest),
        ref0(nameTest),
      ].toChoiceParser();

  Parser<Resolver> typeTest() => [
        _t('comment()').map((_) => CommentTypeResolver()),
        _t('node()').map((_) => NodeTypeResolver()),
        seq3(_t('processing-instruction('), ref0(string).optional(), char(')'))
            .map3((_, target, __) => ProcessingTypeResolver(target)),
        _t('text()').map((_) => TextTypeResolver()),
      ].toChoiceParser();

  Parser<Resolver> nameTest() => [
        _t('*').map((_) => HasNameResolver()),
        ref0(nameToken).map((name) => QualifiedNameResolver(name)),
      ].toChoiceParser();

  Parser<Resolver> predicate() => seq3(char('['), ref0(expression), char(']'))
      .map3((_, expr, __) => PredicateResolver(expr));

  Parser<Resolver> literal() => [
        ref0(numberLiteral),
        ref0(stringLiteral),
      ].toChoiceParser();

  Parser<Resolver> numberLiteral() => seq3(
        digit().plus(),
        seq2(char('.'), digit().plus()).optional(),
        seq3(anyOf('eE'), anyOf('+-').optional(), digit().plus()).optional(),
      ).flatten('number').map((value) => NumberValue(num.parse(value)));

  Parser<Resolver> stringLiteral() =>
      ref0(string).map((value) => StringValue(value));

  Parser<String> string() => [
        ref0(eventParser.attributeValueDoubleQuote),
        ref0(eventParser.attributeValueSingleQuote),
      ].toChoiceParser().map2((value, _) => value);

  Parser<Resolver> variable() => seq2(char('\$'), ref0(nameToken))
      .map2((_, name) => VariableOperator(name));

  Parser<Resolver> function() => seq4(
        _functionDefinitions.keys
            .map((each) => each.toParser())
            .toChoiceParser()
            .trim(),
        _t('(').trim(),
        ref0(expression)
            .starSeparated(char(',').trim())
            .map((list) => list.elements),
        _t(')').trim(),
      ).map4((name, _, args, __) =>
          FunctionResolver(args, _functionDefinitions[name]!.function));

  Parser<String> nameToken() => ref0(eventParser.nameToken);

  static const eventParser = XmlEventParser(XmlNullEntityMapping());
}

Parser<String> _t(String value) => value.toParser().trim();

typedef _FR = FunctionResolver;
typedef _LFR = LazyFunctionResolver;

const _functionDefinitions = <String, ({Evaluator function, int min, int max})>{
  // Node Set Functions
  'last': (function: nodes_func.last, min: 0, max: 0),
  'position': (function: nodes_func.position, min: 0, max: 0),
  'count': (function: nodes_func.count, min: 1, max: 1),
  'id': (function: nodes_func.id, min: 1, max: 1),
  'local-name': (function: nodes_func.localName, min: 1, max: 1),
  'namespace-uri': (function: nodes_func.namespaceUri, min: 1, max: 1),
  'name': (function: nodes_func.name, min: 1, max: 1),
  // String Functions
  'concat': (function: string_func.concat, min: 2, max: unbounded),
  'starts-with': (function: string_func.startsWith, min: 2, max: 2),
  'contains': (function: string_func.contains, min: 2, max: 2),
  'substring-before': (function: string_func.substringBefore, min: 2, max: 2),
  'substring-after': (function: string_func.substringAfter, min: 2, max: 2),
  'substring': (function: string_func.substring, min: 2, max: 3),
  'string-length': (function: string_func.stringLength, min: 1, max: 1),
  'string': (function: string_func.string, min: 1, max: 1),
  'normalize-space': (function: string_func.normalizeSpace, min: 1, max: 1),
  'translate': (function: string_func.translate, min: 3, max: 3),
  // Boolean Functions
  'boolean': (function: boolean_func.boolean, min: 1, max: 1),
  'not': (function: boolean_func.not, min: 1, max: 1),
  'true': (function: boolean_func.trueValue, min: 0, max: 0),
  'false': (function: boolean_func.falseValue, min: 0, max: 0),
  'lang': (function: boolean_func.lang, min: 1, max: 1),
  // Number Functions
  'number': (function: number_func.number, min: 1, max: 1),
  'sum': (function: number_func.sum, min: 1, max: 1),
  'floor': (function: number_func.floor, min: 1, max: 1),
  'ceiling': (function: number_func.ceiling, min: 1, max: 1),
  'round': (function: number_func.round, min: 1, max: 1),
};
