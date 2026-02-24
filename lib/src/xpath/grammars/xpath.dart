import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import '../../xml/entities/null_mapping.dart';
import '../../xml_events/parser.dart';
import '../definitions/cardinality.dart';
import '../definitions/type.dart';
import '../evaluation/expression.dart';
import '../evaluation/operators.dart';
import '../evaluation/types.dart';
import '../expressions/axis.dart';
import '../expressions/constructors.dart';
import '../expressions/function.dart';
import '../expressions/lookup.dart';
import '../expressions/name.dart';
import '../expressions/node.dart';
import '../expressions/operators.dart';
import '../expressions/path.dart';
import '../expressions/predicate.dart';
import '../expressions/range.dart';
import '../expressions/sequence.dart';
import '../expressions/simple_map.dart';
import '../expressions/statement.dart';
import '../expressions/step.dart';
import '../expressions/types.dart';
import '../expressions/variable.dart';
import '../operators/arithmetic.dart' as arithmetic;
import '../operators/comparison.dart' as comparison;
import '../operators/general.dart' as general;
import '../operators/node.dart' as nodes;
import '../types/any.dart';
import '../types/array.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/node.dart';
import '../types/sequence.dart';

// XPath 3.1 Grammar: https://www.w3.org/TR/xpath-31/
class XPathGrammar {
  const XPathGrammar();

  Parser<XPathExpression> build() => resolve(ref0(xpath)).end();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-XPath
  Parser<XPathExpression> xpath() => ref0(expr);

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
        (list) => list.elements
            .skip(1)
            .fold(
              list.elements.first,
              (left, right) =>
                  BinaryOperatorExpression(general.opOr, left, right),
            ),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AndExpr
  Parser<XPathExpression> andExpr() => ref0(comparisonExpr)
      .plusSeparated(token('and'))
      .map(
        (list) => list.elements
            .skip(1)
            .fold(
              list.elements.first,
              (left, right) =>
                  BinaryOperatorExpression(general.opAnd, left, right),
            ),
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
        return BinaryOperatorExpression(op, left, right);
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
            result = BinaryOperatorExpression(arithmetic.opAdd, result, right);
          } else {
            result = BinaryOperatorExpression(
              arithmetic.opSubtract,
              result,
              right,
            );
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
            result = BinaryOperatorExpression(
              arithmetic.opMultiply,
              result,
              right,
            );
          } else if (op == 'div') {
            result = BinaryOperatorExpression(
              arithmetic.opDivide,
              result,
              right,
            );
          } else if (op == 'idiv') {
            result = BinaryOperatorExpression(
              arithmetic.opNumericIntegerDivide,
              result,
              right,
            );
          } else if (op == 'mod') {
            result = BinaryOperatorExpression(
              arithmetic.opNumericMod,
              result,
              right,
            );
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
          result = BinaryOperatorExpression(nodes.opUnion, result, right);
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
            result = BinaryOperatorExpression(nodes.opIntersect, result, right);
          } else {
            result = BinaryOperatorExpression(nodes.opExcept, result, right);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-InstanceofExpr
  Parser<XPathExpression> instanceofExpr() =>
      seq2(
        ref0(treatExpr),
        seq2(token('instance of'), ref0(sequenceType)).optional(),
      ).map(
        (tuple) => tuple.$2 == null
            ? tuple.$1
            : InstanceofExpression(tuple.$1, tuple.$2!.$2),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TreatExpr
  Parser<XPathExpression> treatExpr() =>
      seq2(
        ref0(castableExpr),
        seq2(token('treat as'), ref0(sequenceType)).optional(),
      ).map(
        (tuple) => tuple.$2 == null
            ? tuple.$1
            : TreatExpression(tuple.$1, tuple.$2!.$2),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CastableExpr
  Parser<XPathExpression> castableExpr() =>
      seq2(
        ref0(castExpr),
        seq2(token('castable as'), ref0(singleType)).optional(),
      ).map(
        (tuple) => tuple.$2 == null
            ? tuple.$1
            : CastableExpression(tuple.$1, tuple.$2!.$2),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CastExpr
  Parser<XPathExpression> castExpr() =>
      seq2(
        ref0(arrowExpr),
        seq2(token('cast as'), ref0(singleType)).optional(),
      ).map(
        (tuple) => tuple.$2 == null
            ? tuple.$1
            : CastExpression(tuple.$1, tuple.$2!.$2),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrowExpr
  Parser<XPathExpression> arrowExpr() =>
      seq2(
        ref0(unaryExpr),
        seq2(
          token('=>'),
          seq2(ref0(arrowFunctionSpecifier), ref0(argumentList)),
        ).star(),
      ).map2((expr, arrows) {
        var result = expr;
        for (final arrow in arrows) {
          final specifier = arrow.$2.$1;
          final arguments = arrow.$2.$2;
          result = ArrowExpression(result, specifier, arguments);
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrowFunctionSpecifier
  Parser<Object> arrowFunctionSpecifier() =>
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
            result = UnaryOperatorExpression(
              arithmetic.opNumericUnaryMinus,
              result,
            );
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ValueExpr
  Parser<XPathExpression> valueExpr() => ref0(simpleMapExpr);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-GeneralComp
  Parser<XPathBinaryOperator> generalComp() => [
    token('!=').constant(general.opGeneralNotEqual),
    token('<=').constant(general.opGeneralLessThanOrEqual),
    token('>=').constant(general.opGeneralGreaterThanOrEqual),
    token('=').constant(general.opGeneralEqual),
    token('<').constant(general.opGeneralLessThan),
    token('>').constant(general.opGeneralGreaterThan),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ValueComp
  Parser<XPathBinaryOperator> valueComp() => [
    token('eq').constant(comparison.opValueEqual),
    token('ne').constant(comparison.opValueNotEqual),
    token('lt').constant(comparison.opValueLessThan),
    token('le').constant(comparison.opValueLessThanOrEqual),
    token('gt').constant(comparison.opValueGreaterThan),
    token('ge').constant(comparison.opValueGreaterThanOrEqual),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-30/#prod-xpath30-NodeComp
  Parser<XPathBinaryOperator> nodeComp() => [
    token('is').constant(nodes.opNodeIs),
    token('<<').constant(nodes.opNodePrecedes),
    token('>>').constant(nodes.opNodeFollows),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SimpleMapExpr
  Parser<XPathExpression> simpleMapExpr() => ref0(pathExpr)
      .plusSeparated(token('!'))
      .map(
        (list) => list.elements.length == 1
            ? list.elements.first
            : SimpleMapExpression(list.elements),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PathExpr
  Parser<XPathExpression> pathExpr() => [
    seq2(token('//'), ref0(relativePathExpr)).map2(
      (_, expr) => PathExpression([
        const RootNodeExpression(),
        const StepExpression(DescendantOrSelfAxis()),
        ...expr,
      ]),
    ),
    seq2(token('/'), ref0(relativePathExpr).optional()).map2(
      (_, expr) => expr == null
          ? const RootNodeExpression()
          : PathExpression([const RootNodeExpression(), ...expr]),
    ),
    ref0(
      relativePathExpr,
    ).map((expr) => expr.length == 1 ? expr.first : PathExpression(expr)),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-RelativePathExpr
  Parser<List<XPathExpression>> relativePathExpr() => ref0(stepExpr)
      .plusSeparated([token('//'), token('/')].toChoiceParser())
      .map((list) {
        final steps = [list.elements.first];
        for (var i = 1; i < list.elements.length; i++) {
          final sep = list.separators[i - 1];
          if (sep == '//') {
            steps.add(const StepExpression(DescendantOrSelfAxis()));
          }
          steps.add(list.elements[i]);
        }
        return steps;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-StepExpr
  Parser<XPathExpression> stepExpr() =>
      [ref0(postfixExpr), ref0(axisStep)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AxisStep
  Parser<StepExpression> axisStep() => [
    seq2(ref0(reverseStep), ref0(predicateList)).map2(
      (step, preds) =>
          StepExpression(step.axis, nodeTest: step.nodeTest, predicates: preds),
    ),
    seq2(ref0(forwardStep), ref0(predicateList)).map2(
      (step, preds) =>
          StepExpression(step.axis, nodeTest: step.nodeTest, predicates: preds),
    ),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ForwardStep
  Parser<StepExpression> forwardStep() =>
      [ref0(forwardAxis), ref0(abbrevForwardStep)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ForwardAxis
  Parser<StepExpression> forwardAxis() => seq2(
    [
      token('child::').constant(const ChildAxis()),
      token('descendant::').constant(const DescendantAxis()),
      token('attribute::').constant(const AttributeAxis()),
      token('self::').constant(const SelfAxis()),
      token('descendant-or-self::').constant(const DescendantOrSelfAxis()),
      token('following-sibling::').constant(const FollowingSiblingAxis()),
      token('following::').constant(const FollowingAxis()),
      token('namespace::').constant(const NamespaceAxis()),
    ].toChoiceParser().cast<Axis>(),
    ref0(nodeTest),
  ).map2((axis, test) => StepExpression(axis, nodeTest: test));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AbbrevForwardStep
  Parser<StepExpression> abbrevForwardStep() => [
    seq2(token('@').optional(), ref0(nodeTest)).map2(
      (attr, test) =>
          attr != null ||
              test is AttributeTypeTest ||
              test is SchemaAttributeTypeTest
          ? StepExpression(const AttributeAxis(), nodeTest: test)
          : StepExpression(const ChildAxis(), nodeTest: test),
    ),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ReverseStep
  Parser<StepExpression> reverseStep() =>
      [ref0(reverseAxis), ref0(abbrevReverseStep)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ReverseAxis
  Parser<StepExpression> reverseAxis() => seq2(
    [
      token('parent::').constant(const ParentAxis()),
      token('ancestor::').constant(const AncestorAxis()),
      token('preceding-sibling::').constant(const PrecedingSiblingAxis()),
      token('preceding::').constant(const PrecedingAxis()),
      token('ancestor-or-self::').constant(const AncestorOrSelfAxis()),
    ].toChoiceParser().cast<Axis>(),
    ref0(nodeTest),
  ).map2((axis, test) => StepExpression(axis, nodeTest: test));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AbbrevReverseStep
  Parser<StepExpression> abbrevReverseStep() => [
    token('..').constant(const StepExpression(ParentAxis())),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NodeTest
  Parser<NodeTest> nodeTest() => [
    ref0(kindTest),
    seq2(
      ref0(nameTest),
      token('(').not(),
    ).map2((name, _) => name ?? const NodeTypeTest()),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NameTest
  Parser<NameTest?> nameTest() => [
    ref0(wildcard),
    ref0(uriQualifiedName).map(_eqNameToNodeTest),
    ref0(qName).map(QualifiedNameTest.new),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Wildcard
  Parser<NameTest?> wildcard() => [
    // *:NCName
    seq3(
      token('*'),
      token(':'),
      ref0(ncName),
    ).map3((_, _, name) => LocalNameTest(name)),
    // braccedURILiteral*
    seq2(
      ref0(bracedUriLiteral),
      token('*'),
    ).map2((uri, _) => NamespaceUriTest(uri)),
    // NCName:*
    seq3(
      ref0(ncName),
      token(':'),
      token('*'),
    ).map3((prefix, _, _) => NamespacePrefixNameTest(prefix)),
    token('*').constant(const NodeNameTest()),
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
          } else if (postfix is List<XPathExpression>) {
            result = FunctionCallExpression(result, postfix);
          } else if (postfix is LookupKey) {
            result = LookupExpression(result, postfix.key);
          }
        }
        return result;
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Lookup
  Parser<LookupKey> lookup() =>
      seq2(token('?'), ref0(keySpecifier)).map2((_, key) => LookupKey(key));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-KeySpecifier
  Parser<XPathExpression?> keySpecifier() => [
    ref0(ncName).map((name) => LiteralExpression(XPathSequence.single(name))),
    ref0(
      integerLiteral,
    ).map((value) => LiteralExpression(XPathSequence.single(value))),
    ref0(parenthesizedExpr),
    token('*').constant(null),
  ].toChoiceParser().cast<XPathExpression?>();

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
  Parser<LiteralExpression> literal() =>
      [ref0(numericLiteral), ref0(stringLiteral)].toChoiceParser().map(
        (literal) => LiteralExpression(XPathSequence.single(literal)),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NumericLiteral
  Parser<num> numericLiteral() => [
    ref0(doubleLiteral),
    ref0(decimalLiteral),
    ref0(integerLiteral),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-IntegerLiteral
  Parser<int> integerLiteral() => trim(digit().plusString()).map(int.parse);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DecimalLiteral
  Parser<double> decimalLiteral() => trim(
    [
      seq2(char('.'), digit().plus()),
      seq3(digit().plus(), char('.'), digit().star()),
    ].toChoiceParser(),
  ).flatten().map(double.parse);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DoubleLiteral
  Parser<double> doubleLiteral() => trim(
    seq4(
      [
        seq2(char('.'), digit().plus()),
        seq2(digit().plus(), seq2(char('.'), digit().star()).optional()),
      ].toChoiceParser(),
      anyOf('eE'),
      anyOf('+-').optional(),
      digit().plus(),
    ),
  ).flatten().map(double.parse);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-StringLiteral
  Parser<String> stringLiteral() => trim(
    [
      ref0(xmlGrammar.attributeValueDoubleQuote),
      ref0(xmlGrammar.attributeValueSingleQuote),
    ].toChoiceParser(),
  ).map((tuple) => tuple.$1);

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
  ).constant(const ContextItemExpression());

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
      token('?').constant(const ArgumentPlaceholderExpression());

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
  ).map2((_, key) => UnaryLookupExpression(key));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NamedFunctionRef
  Parser<XPathExpression> namedFunctionRef() => seq3(
    ref0(eqName),
    token('#'),
    ref0(integerLiteral),
  ).map3((name, _, arity) => NamedFunctionExpression(name));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-InlineFunctionExpr
  Parser<XPathExpression> inlineFunctionExpr() =>
      seq4(
        token('function'),
        seq3(token('('), ref0(paramList).optional(), token(')')),
        ref0(typeDeclaration).optional(),
        ref0(functionBody),
      ).map4(
        (_, params, type, body) =>
            InlineFunctionExpression(params.$2 ?? const [], body),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ParamList
  Parser<List<String>> paramList() =>
      ref0(param).plusSeparated(token(',')).map((list) => list.elements);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-Param
  Parser<String> param() => seq3(
    token('\$'),
    ref0(eqName),
    ref0(typeDeclaration).optional(),
  ).map3((_, name, _) => name);

  // https://www.w3.org/TR/xpath-30/#prod-xpath30-TypeDeclaration
  Parser<XPathType<Object>> typeDeclaration() =>
      seq2(token('as'), ref0(sequenceType)).map2((_, type) => type);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ArrayTest
  Parser<XPathType<Object>> arrayTest() =>
      [ref0(anyArrayTest), ref0(typedArrayTest)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AnyArrayTest
  Parser<XPathType<Object>> anyArrayTest() => seq3(
    token('array'),
    token('('),
    token('*'),
  ).skip(after: token(')')).constant(xsArray);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypedArrayTest
  Parser<XPathType<Object>> typedArrayTest() => seq4(
    token('array'),
    token('('),
    ref0(sequenceType),
    token(')'),
  ).constant(xsArray); // For now treat typed arrays as generic arrays

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ParenthesizedItemType
  Parser<XPathType<Object>> parenthesizedItemType() =>
      ref0(itemType).skip(before: token('('), after: token(')'));

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SingleType
  Parser<XPathType<Object>> singleType() =>
      seq2(ref0(atomicOrUnionType), token('?').optional()).map2(
        (type, opt) => XPathSequenceType(
          type: type,
          cardinality: opt == null
              ? XPathCardinality.exactlyOne
              : XPathCardinality.zeroOrOne,
        ),
      );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypeName
  Parser<String> typeName() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-EQName
  Parser<String> eqName() =>
      [ref0(uriQualifiedName), ref0(qName)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-QName
  Parser<String> qName() => ref0(qualifiedName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-URIQualifiedName
  Parser<String> uriQualifiedName() => seq2(
    ref0(bracedUriLiteral),
    ref0(ncName),
  ).map2((uri, name) => 'Q{$uri}$name');

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SequenceType
  Parser<XPathType<Object>> sequenceType() => <Parser<XPathType<Object>>>[
    token('empty-sequence()').constant(xsEmptySequence),
    seq2(ref0(itemType), ref0(occurrenceIndicator).optional()).map2(
      (type, occurrence) => XPathSequenceType(
        type: type,
        cardinality: occurrence ?? XPathCardinality.exactlyOne,
      ),
    ),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-OccurrenceIndicator
  Parser<XPathCardinality> occurrenceIndicator() => [
    token('?').constant(XPathCardinality.zeroOrOne),
    token('*').constant(XPathCardinality.zeroOrMore),
    token('+').constant(XPathCardinality.oneOrMore),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ItemType
  Parser<XPathType<Object>> itemType() => <Parser<XPathType<Object>>>[
    ref0(kindTest).map(NodeTestType.new),
    token('item()').constant(xsAny),
    ref0(functionTest),
    ref0(mapTest),
    ref0(arrayTest),
    ref0(atomicOrUnionType),
    ref0(parenthesizedItemType),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AtomicOrUnionType
  Parser<XPathType<Object>> atomicOrUnionType() => ref0(eqName).map(
    (name) => standardTypes[name] ?? _unimplemented('AtomicOrUnionType', name),
  );

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-FunctionTest
  Parser<XPathType<Object>> functionTest() =>
      [ref0(anyFunctionTest), ref0(typedFunctionTest)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AnyFunctionTest
  Parser<XPathType<Object>> anyFunctionTest() => seq3(
    token('function'),
    token('('),
    token('*'),
  ).skip(after: token(')')).constant(xsFunction);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypedFunctionTest
  Parser<XPathType<Object>> typedFunctionTest() => seq4(
    token('function'),
    token('('),
    ref0(sequenceType).starSeparated(token(',')),
    token(')'),
  ).seq(seq2(token('as'), ref0(sequenceType))).constant(xsFunction);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-MapTest
  Parser<XPathType<Object>> mapTest() =>
      [ref0(anyMapTest), ref0(typedMapTest)].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AnyMapTest
  Parser<XPathType<Object>> anyMapTest() => seq3(
    token('map'),
    token('('),
    token('*'),
  ).skip(after: token(')')).constant(xsMap);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TypedMapTest
  Parser<XPathType<Object>> typedMapTest() => seq4(
    token('map'),
    token('('),
    seq3(
      ref0(atomicOrUnionType),
      token(','),
      ref0(sequenceType),
    ), // Key type, comma, value type
    token(')'),
  ).constant(xsMap);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-FunctionBody
  Parser<XPathExpression> functionBody() => ref0(enclosedExpr);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-EnclosedExpr
  Parser<XPathExpression> enclosedExpr() =>
      seq3(token('{'), ref0(expr), token('}')).map3((_, expr, _) => expr);

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
  ).constant(const NodeTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-NamespaceNodeTest
  Parser<NodeTest> namespaceNodeTest() => seq3(
    token('namespace-node'),
    token('('),
    token(')'),
  ).constant(const NamespaceNodeTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-DocumentTest
  Parser<NodeTest> documentTest() =>
      seq4(
        token('document-node'),
        token('('),
        [
          ref0(elementTest),
          ref0(schemaElementTest),
        ].toChoiceParser().optional(),
        token(')'),
      ).map4((_, _, arg, _) {
        if (arg == null) return const DocumentTypeTest();
        if (arg is ElementTypeTest) {
          return DocumentTypeTest(rootElementTest: arg);
        }
        _unimplemented('DocumentTest with SchemaElementTest', arg);
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-TextTest
  Parser<NodeTest> textTest() => seq3(
    token('text'),
    token('('),
    token(')'),
  ).constant(const TextTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-CommentTest
  Parser<NodeTest> commentTest() => seq3(
    token('comment'),
    token('('),
    token(')'),
  ).constant(const CommentTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-PITest
  Parser<NodeTest> piTest() => seq4(
    token('processing-instruction'),
    token('('),
    [ref0(ncName), ref0(stringLiteral)].toChoiceParser().optional(),
    token(')'),
  ).map4((_, _, target, _) => ProcessingTypeTest(target: target));

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
      ).map4((_, _, arg, _) {
        if (arg == null) return const AttributeTypeTest();
        if (arg.$2 == null) return AttributeTypeTest(nameTest: arg.$1);
        _unimplemented('AttributeTest with TypeName', arg.$2);
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttribNameOrWildcard
  Parser<NameTest?> attribNameOrWildcard() => <Parser<NameTest?>>[
    ref0(attributeName).map(_eqNameToNodeTest),
    token('*').constant(null),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SchemaAttributeTest
  Parser<NodeTest> schemaAttributeTest() => seq4(
    token('schema-attribute'),
    token('('),
    ref0(attributeDeclaration),
    token(')'),
  ).constant(const SchemaAttributeTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttributeDeclaration
  Parser<NameTest> attributeDeclaration() =>
      ref0(attributeName).map(_eqNameToNodeTest);

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
      ).map4((_, _, arg, _) {
        if (arg == null) return const ElementTypeTest();
        if (arg.$2 == null) return ElementTypeTest(nameTest: arg.$1);
        _unimplemented('ElementTest with TypeName', arg.$2);
      });

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementNameOrWildcard
  Parser<NameTest?> elementNameOrWildcard() => <Parser<NameTest?>>[
    ref0(elementName).map(_eqNameToNodeTest),
    token('*').constant(null),
  ].toChoiceParser();

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-SchemaElementTest
  Parser<NodeTest> schemaElementTest() => seq4(
    token('schema-element'),
    token('('),
    ref0(elementDeclaration),
    token(')'),
  ).constant(const SchemaElementTypeTest());

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementDeclaration
  Parser<NameTest> elementDeclaration() =>
      ref0(elementName).map(_eqNameToNodeTest);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-AttributeName
  Parser<String> attributeName() => ref0(eqName);

  // https://www.w3.org/TR/xpath-31/#doc-xpath31-ElementName
  Parser<String> elementName() => ref0(eqName);

  // Different types of names.
  Parser<String> ncName() => trim(ref0(xmlGrammar.nonColonizedNameToken));
  Parser<String> qualifiedName() => trim(ref0(xmlGrammar.qualifiedNameToken));
  Parser<String> bracedUriLiteral() => trim(
    seq3('Q{'.toParser(), pattern('^{}').starString(), '}'.toParser()),
  ).map3((_, uri, _) => uri);

  // Consumes a token.
  Parser<String> token(String token) => ref1(trim, token.toParser());

  // Trims whitespace/comments.
  Parser<T> trim<T>(Parser<T> parser) => parser.trim(ref0(whitespace));

  // Consumes whitespace and comments.
  Parser<void> whitespace() => [ref0(_space), ref0(_comment)].toChoiceParser();
  Parser<void> _space() => pattern('\u{9}\u{A}\u{D}\u{20}');
  Parser<void> _comment() => seq3(
    '(:'.toParser(),
    [ref0(_comment), ':)'.toParser().neg()].toChoiceParser().star(),
    ':)'.toParser(),
  );
}

Never _unimplemented(String feature, [dynamic arg]) => throw UnimplementedError(
  '$feature${arg != null ? ' ($arg)' : ''} not yet implemented',
);

NameTest _eqNameToNodeTest(String name) {
  if (name.startsWith('Q{')) {
    final start = name.indexOf('{');
    final end = name.indexOf('}');
    return NamespaceUriAndLocalNameTest(
      name.substring(start + 1, end).trim(),
      name.substring(end + 1).trim(),
    );
  }
  return QualifiedNameTest(name);
}

const xmlGrammar = XmlEventParser(XmlNullEntityMapping());

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
