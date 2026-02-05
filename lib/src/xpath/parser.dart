import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import '../xml/entities/null_mapping.dart';
import '../xml_events/parser.dart';
import 'evaluation/expression.dart';
import 'evaluation/functions.dart';
import 'expressions/axis.dart';
import 'expressions/constructors.dart';
import 'expressions/function.dart';
import 'expressions/node_test.dart';
import 'expressions/path.dart';
import 'expressions/predicate.dart';
import 'expressions/range.dart';
import 'expressions/sequence.dart';
import 'expressions/statement.dart';
import 'expressions/step.dart';
import 'expressions/string_concat.dart';
import 'expressions/variable.dart';
import 'functions/general.dart' as general;
import 'functions/node.dart' as nodes;
import 'functions/number.dart' as number;
import 'functions/value_comparison.dart' as value_comparison;
import 'types/sequence.dart';
import 'types/string.dart';

// XPath 3.1 Grammar: https://www.w3.org/TR/xpath-31
class XPathParser {
  const XPathParser();

  Parser<XPathExpression> build() => resolve(ref0(xpath));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-XPath
  Parser<XPathExpression> xpath() => ref0(expr).end();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Expr
  Parser<XPathExpression> expr() => ref0(exprSingle)
      .plusSeparated(token(','))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : SequenceExpression(list.elements),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ExprSingle
  Parser<XPathExpression> exprSingle() => [
    ref0(forExpr),
    ref0(letExpr),
    ref0(quantifiedExpr),
    ref0(ifExpr),
    ref0(orExpr),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ForExpr
  Parser<XPathExpression> forExpr() => seq3(
    ref0(simpleForClause),
    token('return'),
    ref0(exprSingle),
  ).map3((bindings, _, body) => ForExpression(bindings, body));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleForClause
  Parser<List<XPathBinding>> simpleForClause() => seq2(
    token('for'),
    ref0(simpleForBinding).plusSeparated(token(',')),
  ).map2((_, list) => list.elements);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleForBinding
  Parser<XPathBinding> simpleForBinding() => seq3(
    ref0(varName),
    token('in'),
    ref0(exprSingle),
  ).map3((name, _, expression) => (name: name, expression: expression));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-LetExpr
  Parser<XPathExpression> letExpr() => seq3(
    ref0(simpleLetClause),
    token('return'),
    ref0(exprSingle),
  ).map3((bindings, _, body) => LetExpression(bindings, body));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleLetClause
  Parser<List<XPathBinding>> simpleLetClause() => seq2(
    token('let'),
    ref0(simpleLetBinding).plusSeparated(token(',')),
  ).map2((_, list) => list.elements);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleLetBinding
  Parser<XPathBinding> simpleLetBinding() => seq3(
    ref0(varName),
    token(':='),
    ref0(exprSingle),
  ).map3((name, _, expression) => (name: name, expression: expression));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-QuantifiedExpr
  Parser<XPathExpression> quantifiedExpr() =>
      seq4(
        [
          token('some').constant(SomeExpression.new),
          token('every').constant(EveryExpression.new),
        ].toChoiceParser(),
        ref0(simpleForBinding).plusSeparated(token(',')),
        token('satisfies'),
        ref0(exprSingle),
      ).map4(
        (quantifier, bindings, _, body) => quantifier(bindings.elements, body),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-IfExpr
  Parser<XPathExpression> ifExpr() =>
      seq6(
        token('if'),
        ref0(expr).skip(before: token('('), after: token(')')),
        token('then'),
        ref0(exprSingle),
        token('else'),
        ref0(exprSingle),
      ).map6(
        (_, cond, _, trueExpr, _, falseExpr) =>
            IfExpression(cond, trueExpr, falseExpr),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-OrExpr
  Parser<XPathExpression> orExpr() => ref0(andExpr)
      .plusSeparated(token('or'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : StaticFunctionExpression(general.opOr, list.elements),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AndExpr
  Parser<XPathExpression> andExpr() => ref0(comparisonExpr)
      .plusSeparated(token('and'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : StaticFunctionExpression(general.opAnd, list.elements),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ComparisonExpr
  Parser<XPathExpression> comparisonExpr() =>
      seq2(
        ref0(stringConcatExpr),
        seq2(
          [ref0(valueComp), ref0(nodeComp), ref0(generalComp)].toChoiceParser(),
          ref0(stringConcatExpr),
        ).optional(),
      ).map2((left, optional) {
        if (optional == null) return left;
        final op = optional.$1;
        final right = optional.$2;
        return StaticFunctionExpression(op, [left, right]);
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-StringConcatExpr
  Parser<XPathExpression> stringConcatExpr() => ref0(rangeExpr)
      .plusSeparated(token('||'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : StringConcatExpression(list.elements),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-RangeExpr
  Parser<XPathExpression> rangeExpr() =>
      seq2(
        ref0(additiveExpr),
        seq2(token('to'), ref0(additiveExpr)).optional(),
      ).map2(
        (left, optional) =>
            optional == null ? left : RangeExpression(left, optional.$2),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AdditiveExpr
  Parser<XPathExpression> additiveExpr() => ref0(multiplicativeExpr)
      .plusSeparated([token('+'), token('-')].toChoiceParser())
      .map((list) {
        var result = list.elements.first;
        for (var i = 1; i < list.elements.length; i++) {
          final op = list.separators[i - 1];
          final right = list.elements[i];
          if (op == '+') {
            result = StaticFunctionExpression(number.opNumericAdd, [
              result,
              right,
            ]);
          } else {
            result = StaticFunctionExpression(number.opNumericSubtract, [
              result,
              right,
            ]);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-MultiplicativeExpr
  Parser<XPathExpression> multiplicativeExpr() => ref0(unionExpr)
      .plusSeparated(
        [
          token('*'),
          token('div'),
          token('idiv'),
          token('mod'),
        ].toChoiceParser(),
      )
      .map((list) {
        var result = list.elements.first;
        for (var i = 1; i < list.elements.length; i++) {
          final op = list.separators[i - 1];
          final right = list.elements[i];
          if (op == '*') {
            result = StaticFunctionExpression(number.opNumericMultiply, [
              result,
              right,
            ]);
          } else if (op == 'div') {
            result = StaticFunctionExpression(number.opNumericDivide, [
              result,
              right,
            ]);
          } else if (op == 'idiv') {
            result = StaticFunctionExpression(number.opNumericIntegerDivide, [
              result,
              right,
            ]);
          } else if (op == 'mod') {
            result = StaticFunctionExpression(number.opNumericMod, [
              result,
              right,
            ]);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-UnionExpr
  Parser<XPathExpression> unionExpr() => ref0(intersectExceptExpr)
      .plusSeparated([token('union'), token('|')].toChoiceParser())
      .map((list) {
        var result = list.elements.first;
        for (var i = 1; i < list.elements.length; i++) {
          final right = list.elements[i];
          result = StaticFunctionExpression(nodes.opUnion, [result, right]);
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-IntersectExceptExpr
  Parser<XPathExpression> intersectExceptExpr() => ref0(instanceofExpr)
      .plusSeparated([token('intersect'), token('except')].toChoiceParser())
      .map((list) {
        var result = list.elements.first;
        for (var i = 1; i < list.elements.length; i++) {
          final op = list.separators[i - 1];
          final right = list.elements[i];
          if (op == 'intersect') {
            result = StaticFunctionExpression(nodes.opIntersect, [
              result,
              right,
            ]);
          } else {
            result = StaticFunctionExpression(nodes.opExcept, [result, right]);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-InstanceofExpr
  Parser<XPathExpression> instanceofExpr() => ref0(treatExpr)
      .plusSeparated(token('instance of'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : _unimplemented('InstanceofExpr'),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TreatExpr
  Parser<XPathExpression> treatExpr() => seq2(
    ref0(castableExpr),
    seq2(token('treat as'), ref0(sequenceType)).optional(),
  ).map((tuple) => tuple.$2 == null ? tuple.$1 : _unimplemented('TreatExpr'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CastableExpr
  Parser<XPathExpression> castableExpr() =>
      seq2(
        ref0(castExpr),
        seq2(token('castable as'), ref0(singleType)).optional(),
      ).map(
        (tuple) => tuple.$2 == null ? tuple.$1 : _unimplemented('CastableExpr'),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CastExpr
  Parser<XPathExpression> castExpr() => seq2(
    ref0(arrowExpr),
    seq2(token('cast as'), ref0(singleType)).optional(),
  ).map((tuple) => tuple.$2 == null ? tuple.$1 : _unimplemented('CastExpr'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrowExpr
  Parser<XPathExpression> arrowExpr() => seq2(
    ref0(unaryExpr),
    seq2(
      token('=>'),
      seq2(ref0(arrowFunctionSpecifier), ref0(argumentList)),
    ).star(),
  ).map2((expr, arrows) => arrows.isEmpty ? expr : _unimplemented('ArrowExpr'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrowFunctionSpecifier
  Parser<void> arrowFunctionSpecifier() =>
      [ref0(eqName), ref0(varRef), ref0(parenthesizedExpr)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-UnaryExpr
  Parser<XPathExpression> unaryExpr() =>
      seq2(
        [token('-'), token('+')].toChoiceParser().star(),
        ref0(valueExpr),
      ).map2((ops, value) {
        var result = value;
        for (final op in ops.reversed) {
          if (op == '-') {
            result = StaticFunctionExpression(number.opNumericUnaryMinus, [
              result,
            ]);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ValueExpr
  Parser<XPathExpression> valueExpr() => ref0(simpleMapExpr);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-GeneralComp
  Parser<XPathFunction> generalComp() => [
    token('!=').map((_) => general.opGeneralNotEqual),
    token('<=').map((_) => general.opGeneralLessThanOrEqual),
    token('>=').map((_) => general.opGeneralGreaterThanOrEqual),
    token('=').map((_) => general.opGeneralEqual),
    token('<').map((_) => general.opGeneralLessThan),
    token('>').map((_) => general.opGeneralGreaterThan),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ValueComp
  Parser<XPathFunction> valueComp() => [
    token('eq').map((_) => value_comparison.opValueEqual),
    token('ne').map((_) => value_comparison.opValueNotEqual),
    token('lt').map((_) => value_comparison.opValueLessThan),
    token('le').map((_) => value_comparison.opValueLessThanOrEqual),
    token('gt').map((_) => value_comparison.opValueGreaterThan),
    token('ge').map((_) => value_comparison.opValueGreaterThanOrEqual),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-30/#prod-xpath30-NodeComp
  Parser<XPathFunction> nodeComp() => [
    token('is'),
    token('<<'),
    token('>>'),
  ].toChoiceParser().map((op) => _unimplemented('NodeComp', op));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleMapExpr
  Parser<XPathExpression> simpleMapExpr() => ref0(pathExpr)
      .plusSeparated(token('!'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : _unimplemented('SimpleMapExpr'),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PathExpr
  Parser<XPathExpression> pathExpr() => [
    seq2(token('//'), ref0(relativePathExpr)).map2(
      (s, e) => PathExpression([
        const Step(DescendantOrSelfAxis()),
        ...e,
      ], isAbsolute: true),
    ),
    seq2(token('/'), ref0(relativePathExpr).optional()).map2((s, e) {
      if (e == null) {
        // Root node
        // Assuming empty relative path implies returning root
        return PathExpression([], isAbsolute: true);
      }
      return PathExpression(e, isAbsolute: true);
    }),
    ref0(relativePathExpr).map((e) {
      if (e.length == 1 && e.first is ExpressionStep) {
        return (e.first as ExpressionStep).expression;
      }
      return PathExpression(e, isAbsolute: false);
    }),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-RelativePathExpr
  Parser<List<Step>> relativePathExpr() => ref0(stepExpr)
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

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-StepExpr
  Parser<Step> stepExpr() => [
    ref0(postfixExpr).map(ExpressionStep.new),
    ref0(axisStep),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AxisStep
  Parser<Step> axisStep() => [
    seq2(
      ref0(reverseStep),
      ref0(predicateList),
    ).map2((step, preds) => Step(step.axis, step.nodeTest, preds)),
    seq2(
      ref0(forwardStep),
      ref0(predicateList),
    ).map2((step, preds) => Step(step.axis, step.nodeTest, preds)),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ForwardStep
  Parser<Step> forwardStep() => [
    seq2(ref0(forwardAxis), ref0(nodeTest)).map2(Step.new),
    ref0(abbrevForwardStep),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ForwardAxis
  Parser<Axis> forwardAxis() => [
    token('child::').constant(const ChildAxis()),
    token('descendant::').constant(const DescendantAxis()),
    token('attribute::').constant(const AttributeAxis()),
    token('self::').constant(const SelfAxis()),
    token('descendant-or-self::').constant(const DescendantOrSelfAxis()),
    token('following-sibling::').constant(const FollowingSiblingAxis()),
    token('following::').constant(const FollowingAxis()),
    token('namespace::').map((_) => _unimplemented('NamespaceAxis')),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AbbrevForwardStep
  Parser<Step> abbrevForwardStep() =>
      seq2(token('@').optional(), ref0(nodeTest)).map2((attr, test) {
        if (attr != null) {
          return Step(const AttributeAxis(), test);
        } else {
          return Step(const ChildAxis(), test);
        }
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ReverseStep
  Parser<Step> reverseStep() => [
    seq2(ref0(reverseAxis), ref0(nodeTest)).map2(Step.new),
    ref0(abbrevReverseStep),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ReverseAxis
  Parser<Axis> reverseAxis() => [
    token('parent::').constant(const ParentAxis()),
    token('ancestor::').constant(const AncestorAxis()),
    token('preceding-sibling::').constant(const PrecedingSiblingAxis()),
    token('preceding::').constant(const PrecedingAxis()),
    token('ancestor-or-self::').constant(const AncestorOrSelfAxis()),
  ].toChoiceParser().cast<Axis>();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AbbrevReverseStep
  Parser<Step> abbrevReverseStep() =>
      token('..').constant(const Step(ParentAxis(), NodeTypeNodeTest()));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NodeTest
  Parser<NodeTest> nodeTest() => [
    ref0(kindTest),
    seq2(ref0(nameTest), token('(').not()).map2((n, _) => n),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NameTest
  Parser<NodeTest> nameTest() => [
    ref0(wildcard),
    ref0(uriQualifiedName).map((name) {
      final start = name.indexOf('{');
      final end = name.indexOf('}');
      return NamespaceUriAndLocalNameNodeTest(
        name.substring(start + 1, end),
        name.substring(end + 1),
      );
    }),
    ref0(qName).map(QualifiedNameNodeTest.new),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Wildcard
  Parser<NodeTest> wildcard() => [
    // *:NCName
    seq3(
      token('*'),
      token(':'),
      ref0(ncName),
    ).map3((_, _, name) => LocalNameNodeTest(name)),
    // braccedURILiteral*
    seq2(
      ref0(bracedUriLiteral),
      token('*'),
    ).map2((uri, _) => NamespaceUriNodeTest(uri)),
    // NCName:*
    seq3(
      ref0(ncName),
      token(':'),
      token('*'),
    ).map3((prefix, _, _) => NamespacePrefixNameNodeTest(prefix)),
    token('*').constant(const NameNodeTest()),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PostfixExpr
  Parser<XPathExpression> postfixExpr() =>
      seq2(
        ref0(primaryExpr),
        [
          ref0(predicate),
          ref0(argumentList),
          ref0(lookup),
        ].toChoiceParser().star(),
      ).map2((primary, postfixes) {
        var result = primary;
        for (final postfix in postfixes) {
          if (postfix is Predicate) {
            result = PredicateExpression(result, postfix);
          } else {
            return _unimplemented('Postfix', postfix);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Lookup
  Parser<XPathExpression> lookup() =>
      seq2(token('?'), ref0(keySpecifier)).map((_) => _unimplemented('Lookup'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-KeySpecifier
  Parser<void> keySpecifier() => [
    ref0(ncName),
    ref0(integerLiteral),
    ref0(parenthesizedExpr),
    token('*'),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArgumentList
  Parser<List<XPathExpression>> argumentList() => ref0(argument)
      .starSeparated(token(','))
      .skip(before: token('('), after: token(')'))
      .map((value) => value.elements);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PredicateList
  Parser<List<Predicate>> predicateList() => ref0(predicate).star();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Predicate
  Parser<Predicate> predicate() =>
      ref0(expr).skip(before: token('['), after: token(']')).map(Predicate.new);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PrimaryExpr
  Parser<XPathExpression> primaryExpr() => [
    ref0(literal),
    ref0(varRef),
    ref0(parenthesizedExpr),
    ref0(contextItemExpr),
    ref0(functionCall),
    ref0(functionItemExpr),
    ref0(mapConstructor),
    ref0(arrayConstructor),
    ref0(unaryLookup),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Literal
  Parser<LiteralExpression> literal() => [
    ref0(numericLiteral),
    ref0(stringLiteral),
  ].toChoiceParser().map(LiteralExpression.new);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NumericLiteral
  Parser<XPathSequence> numericLiteral() => [
    ref0(doubleLiteral),
    ref0(decimalLiteral),
    ref0(integerLiteral),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-IntegerLiteral
  Parser<XPathSequence> integerLiteral() =>
      trim(digit().plusString()).map((s) => XPathSequence.single(int.parse(s)));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DecimalLiteral
  Parser<XPathSequence> decimalLiteral() => trim(
    [
      seq2(char('.'), digit().plus()),
      seq3(digit().plus(), char('.'), digit().star()),
    ].toChoiceParser(),
  ).flatten().map((s) => XPathSequence.single(double.parse(s)));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DoubleLiteral
  Parser<XPathSequence> doubleLiteral() => trim(
    seq4(
      [
        seq2(char('.'), digit().plus()),
        seq2(digit().plus(), seq2(char('.'), digit().star()).optional()),
      ].toChoiceParser(),
      anyOf('eE'),
      anyOf('+-').optional(),
      digit().plus(),
    ),
  ).flatten().map((s) => XPathSequence.single(double.parse(s)));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-StringLiteral
  Parser<XPathSequence> stringLiteral() => trim(
    [
      ref0(eventParser.attributeValueDoubleQuote),
      ref0(eventParser.attributeValueSingleQuote),
    ].toChoiceParser(),
  ).map((tuple) => XPathSequence.single(tuple.$1));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-VarRef
  Parser<XPathExpression> varRef() => ref0(varName).map(VariableExpression.new);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-VarName
  Parser<String> varName() => trim(ref0(eqName).skip(before: char('\$')));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ParenthesizedExpr
  Parser<XPathExpression> parenthesizedExpr() => ref0(expr)
      .optional()
      .skip(before: token('('), after: token(')'))
      .map((expr) => expr ?? const SequenceExpression([]));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ContextItemExpr
  Parser<XPathExpression> contextItemExpr() => trim(
    seq2(char('.'), char('.').not()),
  ).map((_) => const ContextItemExpression());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-FunctionCall
  Parser<XPathExpression> functionCall() => seq2(
    ref0(eqName).where((name) => !_reservedFunctionNames.contains(name)),
    ref0(argumentList),
  ).map2(DynamicFunctionExpression.new);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Argument
  Parser<XPathExpression> argument() =>
      [ref0(exprSingle), ref0(argumentPlaceholder)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArgumentPlaceholder
  Parser<XPathExpression> argumentPlaceholder() =>
      token('?').map((_) => _unimplemented('ArgumentPlaceholder'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-FunctionItemExpr
  Parser<XPathExpression> functionItemExpr() =>
      [ref0(namedFunctionRef), ref0(inlineFunctionExpr)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-MapConstructor
  Parser<XPathExpression> mapConstructor() => seq4(
    token('map'),
    token('{'),
    ref0(mapConstructorEntry).starSeparated(token(',')),
    token('}'),
  ).map4((_, _, entries, _) => MapConstructor(entries.elements));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-MapConstructorEntry
  Parser<MapEntry<XPathExpression, XPathExpression>> mapConstructorEntry() =>
      seq3(
        ref0(exprSingle),
        token(':'),
        ref0(exprSingle),
      ).map3((key, _, value) => MapEntry(key, value));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrayConstructor
  Parser<XPathExpression> arrayConstructor() => [
    ref0(squareArrayConstructor),
    ref0(curlyArrayConstructor),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SquareArrayConstructor
  Parser<XPathExpression> squareArrayConstructor() => ref0(exprSingle)
      .plusSeparated(token(','))
      .map(
        (list) => SquareArrayConstructor(list.elements.cast<XPathExpression>()),
      )
      .optional()
      .skip(before: token('['), after: token(']'))
      .map((expr) => expr ?? const SquareArrayConstructor([]));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CurlyArrayConstructor
  Parser<XPathExpression> curlyArrayConstructor() =>
      seq4(token('array'), token('{'), ref0(expr).optional(), token('}')).map4(
        (_, _, expr, _) =>
            CurlyArrayConstructor(expr ?? const SequenceExpression([])),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-UnaryLookup
  Parser<XPathExpression> unaryLookup() => seq2(
    token('?'),
    ref0(keySpecifier),
  ).map((_) => _unimplemented('UnaryLookup'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NamedFunctionRef
  Parser<XPathExpression> namedFunctionRef() => seq3(
    ref0(eqName),
    token('#'),
    ref0(integerLiteral),
  ).map((_) => _unimplemented('NamedFunctionRef'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-InlineFunctionExpr
  Parser<XPathExpression> inlineFunctionExpr() => seq4(
    token('function'),
    seq3(token('('), ref0(paramList).optional(), token(')')),
    ref0(typeDeclaration).optional(),
    ref0(functionBody),
  ).map((_) => _unimplemented('InlineFunctionExpr'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ParamList
  Parser<void> paramList() => ref0(param).plusSeparated(token(','));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Param
  Parser<void> param() =>
      seq3(token('\$'), ref0(eqName), ref0(typeDeclaration).optional());

  // https://www.w3.org/TR/xpath-30/#prod-xpath30-TypeDeclaration
  Parser<void> typeDeclaration() => seq2(token('as'), ref0(sequenceType));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SequenceType
  Parser<void> functionBody() => ref0(enclosedExpr);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-EnclosedExpr
  Parser<void> enclosedExpr() => seq3(token('{'), ref0(expr), token('}'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-KindTest
  Parser<NodeTest> kindTest() => [
    ref0(documentTest),
    ref0(elementTest),
    ref0(attributeTest),
    ref0(schemaElementTest),
    ref0(schemaAttributeTest),
    ref0(piTest),
    ref0(commentTest),
    ref0(textTest),
    ref0(namespaceNodeTest),
    ref0(anyKindTest),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AnyKindTest
  Parser<NodeTest> anyKindTest() => seq3(
    token('node'),
    token('('),
    token(')'),
  ).constant(const NodeTypeNodeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DocumentTest
  Parser<NodeTest> documentTest() => seq4(
    token('document-node'),
    token('('),
    [ref0(elementTest), ref0(schemaElementTest)].toChoiceParser().optional(),
    token(')'),
  ).constant(const DocumentTypeNodeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TextTest
  Parser<NodeTest> textTest() => seq3(
    token('text'),
    token('('),
    token(')'),
  ).constant(const TextTypeNodeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CommentTest
  Parser<NodeTest> commentTest() => seq3(
    token('comment'),
    token('('),
    token(')'),
  ).constant(const CommentTypeNodeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NamespaceNodeTest
  Parser<NodeTest> namespaceNodeTest() => seq3(
    token('namespace-node'),
    token('('),
    token(')'),
  ).map((_) => _unimplemented('NamespaceNodeTest'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PITest
  Parser<NodeTest> piTest() =>
      seq4(
        token('processing-instruction'),
        token('('),
        [
          ref0(ncName).map(XPathSequence.single),
          ref0(stringLiteral),
        ].toChoiceParser().optional(),
        token(')'),
      ).map4(
        (_, _, arg, _) =>
            ProcessingTypeNodeTest(arg?.firstOrNull?.toXPathString()),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttributeTest
  Parser<NodeTest> attributeTest() =>
      seq4(
        token('attribute'),
        token('('),
        seq2(
          ref0(attribNameOrWildcard),
          seq2(token(','), ref0(typeName)).optional(),
        ).optional(),
        token(')'),
      ).map4(
        (_, _, arg, _) => arg == null
            ? const AttributeTypeNodeTest()
            : _unimplemented('AttributeTest'),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttribNameOrWildcard
  Parser<void> attribNameOrWildcard() =>
      [ref0(attributeName), token('*')].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SchemaAttributeTest
  Parser<NodeTest> schemaAttributeTest() => seq4(
    token('schema-attribute'),
    token('('),
    ref0(attributeDeclaration),
    token(')'),
  ).map4((_, _, arg, _) => _unimplemented('SchemaAttributeTest'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttributeDeclaration
  Parser<void> attributeDeclaration() => ref0(attributeName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementTest
  Parser<NodeTest> elementTest() =>
      seq4(
        token('element'),
        token('('),
        seq2(
          ref0(elementNameOrWildcard),
          seq2(token(','), ref0(typeName)).optional(),
        ).optional(),
        token(')'),
      ).map4(
        (_, _, arg, _) => arg == null
            ? const ElementTypeNodeTest()
            : _unimplemented('ElementTest'),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementNameOrWildcard
  Parser<void> elementNameOrWildcard() =>
      [ref0(elementName), token('*')].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SchemaElementTest
  Parser<NodeTest> schemaElementTest() => seq4(
    token('schema-element'),
    token('('),
    ref0(elementDeclaration),
    token(')'),
  ).map4((_, _, arg, _) => _unimplemented('SchemaElementTest'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementDeclaration
  Parser<void> elementDeclaration() => ref0(elementName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttributeName
  Parser<String> attributeName() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementName
  Parser<String> elementName() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypeName
  Parser<String> typeName() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-FunctionTest
  Parser<void> functionTest() =>
      [ref0(anyFunctionTest), ref0(typedFunctionTest)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AnyFunctionTest
  Parser<void> anyFunctionTest() => token('function(*)');

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypedFunctionTest
  Parser<void> typedFunctionTest() => seq4(
    token('function('),
    ref0(sequenceType).plusSeparated(token(',')).optional(),
    token(')'),
    seq2(token('as'), ref0(sequenceType)),
  );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ParenthesizedItemType
  Parser<void> parenthesizedItemType() =>
      seq3(token('('), ref0(itemType), token(')'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-EQName
  Parser<String> eqName() =>
      [ref0(qName), ref0(uriQualifiedName)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-QName
  Parser<String> qName() => ref0(qualifiedName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-URIQualifiedName
  Parser<String> uriQualifiedName() => seq2(
    ref0(bracedUriLiteral),
    ref0(ncName),
  ).map2((uri, name) => 'Q{$uri}$name');

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SequenceType
  Parser<void> sequenceType() => [
    token('empty-sequence()'),
    seq2(ref0(itemType), ref0(occurrenceIndicator).optional()),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-OccurrenceIndicator
  Parser<String> occurrenceIndicator() =>
      [token('?'), token('*'), token('+')].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ItemType
  Parser<void> itemType() => [
    ref0(kindTest),
    token('item()'),
    ref0(functionTest),
    ref0(atomicOrUnionType),
    ref0(parenthesizedItemType),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AtomicOrUnionType
  Parser<String> atomicOrUnionType() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SingleType
  Parser<void> singleType() => seq2(ref0(typeName), token('?').optional());

  // Helper
  Parser<String> ncName() => trim(ref0(eventParser.nonColonizedNameToken));
  Parser<String> qualifiedName() => trim(ref0(eventParser.qualifiedNameToken));
  Parser<String> bracedUriLiteral() => trim(
    seq3('Q{'.toParser(), pattern('^{}').starString(), '}'.toParser()),
  ).map3((_, uri, _) => uri);

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

Never _unimplemented(String feature, [dynamic arg]) => throw UnimplementedError(
  '$feature${arg != null ? ' ($arg)' : ''} not yet implemented',
);

const _reservedFunctionNames = {
  'attribute',
  'comment',
  'document-node',
  'element',
  'empty-sequence',
  'function',
  'if',
  'item',
  'map',
  'namespace-node',
  'node',
  'processing-instruction',
  'schema-attribute',
  'schema-element',
  'switch',
  'text',
  'typeswitch',
};
