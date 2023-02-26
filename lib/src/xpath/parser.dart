import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import '../xml/entities/null_mapping.dart';
import '../xml_events/parser.dart';
import 'resolver.dart';
import 'resolvers/axis.dart';
import 'resolvers/composition.dart';
import 'resolvers/name.dart';
import 'resolvers/predicate.dart';
import 'resolvers/type.dart';

// https://www.w3.org/TR/1999/REC-xpath-19991116
class XPathParser {
  const XPathParser();

  Parser<Resolver> build() => resolve(ref0(path)).end();

  Parser<Resolver> path() => [
        ref0(absolutePath),
        ref0(relativePath),
      ].toChoiceParser().map((path) => SequenceResolver.fromList(path));

  Parser<List<Resolver>> absolutePath() =>
      seq2(char('/'), ref0(relativePath).optionalWith([]))
          .map2((_, path) => [RootAxisResolver(), ...path]);

  Parser<List<Resolver>> relativePath() =>
      ref0(step).plusSeparated(char('/')).map((list) => list.elements);

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
        string('..').map((_) => ParentAxisResolver()),
        char('.').map((_) => SelfAxisResolver()),
      ].toChoiceParser();

  Parser<Resolver> axis() => [
        // Abbreviated Syntax
        char('/').map((_) => DescendantAxisResolver()),
        char('@').map((_) => AttributeAxisResolver()),
        // Full Syntax
        string('ancestor-or-self::').map((_) => AncestorOrSelfAxisResolver()),
        string('ancestor::').map((_) => AncestorAxisResolver()),
        string('attribute::').map((_) => AttributeAxisResolver()),
        string('child::').map((_) => ChildAxisResolver()),
        string('descendant-or-self::')
            .map((_) => DescendantOrSelfAxisResolver()),
        string('descendant::').map((_) => DescendantAxisResolver()),
        string('following-sibling::')
            .map((_) => FollowingSiblingAxisResolver()),
        string('following::').map((_) => FollowingAxisResolver()),
        string('parent::').map((_) => ParentAxisResolver()),
        string('preceding-sibling::')
            .map((_) => PrecedingSiblingAxisResolver()),
        string('preceding::').map((_) => PrecedingAxisResolver()),
        string('self::').map((_) => SelfAxisResolver()),
        // Default
        epsilonWith(ChildAxisResolver()),
      ].toChoiceParser();

  Parser<Resolver> nodeTest() => [
        ref0(typeTest),
        ref0(nameTest),
      ].toChoiceParser();

  Parser<Resolver> typeTest() => [
        string('comment()').map((_) => CommentTypeResolver()),
        string('node()').map((_) => NodeTypeResolver()),
        seq3(string('processing-instruction('), ref0(literalToken).optional(),
                char(')'))
            .map3((_, target, __) => ProcessingTypeResolver(target)),
        string('text()').map((_) => TextTypeResolver()),
      ].toChoiceParser();

  Parser<Resolver> nameTest() => [
        char('*').map((_) => HasNameResolver()),
        ref0(nameToken).map((name) => QualifiedNameResolver(name)),
      ].toChoiceParser();

  Parser<Resolver> predicate() =>
      seq3(char('['), expression(), char(']')).map3((_, expr, __) => expr);

  Parser<Resolver> expression() => [
        ref0(index),
        ref0(inner),
      ].toChoiceParser();

  Parser<Resolver> index() => seq2(char('-').optional(), digit())
      .flatten('index')
      .map((position) => IndexPredicateResolver(int.parse(position)));

  Parser<Resolver> inner() => seq2(
        ref0(path),
        seq2(char('='), ref0(literalToken)).optional(),
      ).map2((path, value) => InnerPredicateResolver(path, value?.second));

  static const eventParser = XmlEventParser(XmlNullEntityMapping());

  Parser<String> nameToken() => eventParser.nameToken();

  Parser<String> literalToken() =>
      eventParser.attributeValue().map2((value, _) => value);
}
