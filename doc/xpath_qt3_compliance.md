# XPath 3.1 Compliance Roadmap & Implementation Tracker

This document tracks known discrepancies between PetitXml XPath 3.1 implementation and the official W3C QT3 test-suite, ordered by real-world user impact.

---

## Baseline Stats (QT3 Test Suite)

- **Suites**: 353
- **Total Cases**: 22,514
- **Passing**: 19,941 (88.6%)
- **Failures**: 1,988 (8.8%)
- **Errors**: 585 (2.6%)

---

## Issue Checklist & Implementation Guide

### 1. XML Node Navigation & Identification

- [x] **Status**: Completed
- **User Impact**: Critical / Daily
- **QT3 Target**: 135 issues (133 failures, 2 errors)
- **Primary Suites**: `prod-AxisStep`, `fn-id`, `fn-idref`, `fn-element-with-id`, `fn-path`, `fn-innermost`, `fn-outermost`
- **Root Causes**:
  - `fn:id`, `fn:idref`, and `fn:element-with-id` lack `xml:id` and DTD ID/IDREF index resolution across document roots.
  - `fn:path` does not generate canonical EQName path notation (`/Q{uri}elem[1]`).
  - `fn:innermost` and `fn:outermost` incorrectly process namespace/attribute nodes and fail document-order filtering.
  - `prod-AxisStep` edge cases with namespace axis and reverse axis indexing.
- **Implementation Steps**:
  1. Add `xml:id` and ID attribute traversal helper in `lib/src/xpath/functions/node.dart` (or `lib/src/xpath/expressions/axis.dart`).
  2. Implement `fn:path` producing canonical XPath 3.1 expressions (`/Q{uri}name[idx]`).
  3. Filter non-node/attribute targets in `fn:innermost` / `fn:outermost` and sort strictly by document order.
  4. Fix reverse axis predicate positional context evaluation.
- **Files**:
  - `lib/src/xpath/functions/node.dart`
  - `lib/src/xpath/expressions/axis.dart`
  - `lib/src/xpath/expressions/step.dart`
- **Unit Tests**:
  - `test/xpath/functions/node_test.dart`
  - `test/xpath/expressions/axis_test.dart`

---

### 2. General & Value Comparison Error Rules

- [x] **Status**: Completed
- **User Impact**: High / Frequent
- **QT3 Target**: 65 issues (59 failures, 6 errors)
- **Primary Suites**: `prod-ValueComp`, `prod-GeneralComp.eq`, `prod-GeneralComp.ne`, `prod-GeneralComp.lt`, `prod-GeneralComp.gt`
- **Root Causes**:
  - Value comparisons (`eq`, `ne`, `lt`, `gt`, `le`, `ge`) between disjoint atomic types (e.g. string vs integer, date vs time) return `false` instead of raising dynamic type error `XPTY0004`.
  - Value comparisons with an empty sequence return boolean instead of returning an empty sequence `()`.
  - General comparisons with empty sequences produce unexpected truth values.
- **Implementation Steps**:
  1. In `lib/src/xpath/operators/comparison.dart`, update `ValueComparisonExpression`:
     - If either operand is empty sequence `()`, return `XPathSequence.empty`.
     - Verify both operands are atomic items with comparable types (per XPath 3.1 §3.5.1). If non-comparable, throw `XPathEvaluationException` (`XPTY0004`).
     - NaN equality: `NaN != NaN`, `NaN eq NaN` is false.
  2. In `lib/src/xpath/operators/general.dart`, ensure `GeneralComparisonExpression` atomizes operands and applies standard type promotion and untypedAtomic coercion without swallowing type errors when explicitly mandated.
  3. Introduce `XPathAtomic`, `XPathNumeric` (`XPathInteger` with `BigInt`, `XPathDecimal`, `XPathDouble`), and `XPathUntypedAtomic`.
- **Files**:
  - `lib/src/xpath/operators/comparison.dart`
  - `lib/src/xpath/operators/general.dart`
  - `lib/src/xpath/xdm/atomic.dart`
  - `lib/src/xpath/xdm/atomic/numeric.dart`
  - `lib/src/xpath/xdm/atomic/string.dart`
- **Unit Tests**:
  - `test/xpath/operators/comparison_test.dart`
  - `test/xpath/operators/general_test.dart`
  - `test/xpath/xdm/atomic/numeric_test.dart`

---

### 3. Numeric Aggregations & Modulo Semantics

- [x] **Status**: Completed
- **User Impact**: High / Frequent
- **QT3 Target**: 169 issues (155 failures, 14 errors)
- **Primary Suites**: `op-numeric-mod`, `fn-min`, `fn-max`, `fn-avg`, `fn-sum`, `fn-number`, `op-numeric-divide`
- **Root Causes**:
  - `op:numeric-mod`: Dart's `%` operator uses truncated integer remainder / Euclidean semantics (`-5 % 3 == 1`), while XPath 3.1 requires IEEE remainder (`-5 mod 3 == -2`).
  - `fn:min` / `fn:max`: When sequence contains `NaN`, result must be `NaN` for float/double; non-comparable items must raise dynamic error; empty sequence returns `()`.
  - `fn:avg` / `fn:sum`: Duration types (`xs:dayTimeDuration`, `xs:yearMonthDuration`) arithmetic not supported.
- **Implementation Steps**:
  1. Update `mod` operator in `lib/src/xpath/expressions/operators.dart` and `evaluation/operators.dart` to compute `a - (a ~/ b) * b` for integers and `a.remainder(b)` for floating-point.
  2. Update `fn:min` / `fn:max` in `lib/src/xpath/functions/math.dart`:
     - Check for `NaN` and propagate according to IEEE rules.
     - Validate item types for comparability, throwing `XPathEvaluationException` if heterogeneous non-numeric items exist.
  3. Add duration aggregation support in `fn:sum` and `fn:avg`.
- **Files**:
  - `lib/src/xpath/functions/math.dart`
  - `lib/src/xpath/functions/sequence.dart`
  - `lib/src/xpath/expressions/operators.dart`
- **Unit Tests**:
  - `test/xpath/functions/math_test.dart`
  - `test/xpath/expressions/operators_test.dart`

---

### 4. Casting Matrix & Cast/Castable Validation

- [x] **Status**: Completed
- **User Impact**: Medium-High
- **Primary Suites**: `prod-CastExpr`, `prod-CastableExpr`, `prod-CastExpr.derived`
- **Addressed**:
  - Full W3C XPath 3.1 §19 casting matrix implemented in `lib/src/xpath/xdm/casting_matrix.dart`.
  - `CastExpression` and `CastableExpression` in `lib/src/xpath/expressions/types.dart` enforce source-to-target transitions and integer subtype bounds.
  - Disallows casting to abstract types `xs:anyAtomicType` and `xs:NOTATION` (`XPST0080`).
  - Rejects function items, maps, and arrays with `FOTY0013`.
- **Files**:
  - `lib/src/xpath/xdm/casting_matrix.dart`
  - `lib/src/xpath/expressions/types.dart`
- **Unit Tests**:
  - `test/xpath/xdm/casting_matrix_test.dart`
  - `test/xpath/expressions/types_test.dart`

---

### 5. Date, Time & Duration Operations & IETF Parser

- [x] **Status**: Completed
- **User Impact**: Medium-High
- **Primary Suites**: `fn-parse-ietf-date`, `op-duration-equal`, `fn-seconds-from-duration`
- **Addressed**:
  - Implemented `fn:parse-ietf-date` in `lib/src/xpath/functions/date_time.dart` conforming to RFC 2822, RFC 850, and asctime formats, returning UTC normalized timestamps (`xs:dateTimeStamp`).
  - Corrected duration normalization in `XPathDuration.tryParse` so overflow seconds/minutes/hours are normalized across days and time components.
  - Aligned duration equality (`eq`/`ne`) between zero-valued `xs:yearMonthDuration` and `xs:dayTimeDuration` per XPath 3.1 specification.
- **Files**:
  - `lib/src/xpath/functions/date_time.dart`
  - `lib/src/xpath/xdm/atomic/duration.dart`
- **Unit Tests**:
  - `test/xpath/functions/date_time_test.dart`

---

### 6. JSON Support & Interoperability

- [x] **Status**: Completed
- **User Impact**: Medium
- **Primary Suites**: `fn-json-to-xml`, `fn-parse-json`, `fn-xml-to-json`, `fn-json-doc`
- **Addressed**:
  - Full options map parsing for `liberal`, `duplicates` (`reject`, `use-first`, `use-last`, `retain`), `escape`, `validate`, and arity-1 `fallback` function with proper error codes (`FOJS0005`, `XPTY0004`).
  - Full custom recursive-descent JSON parser in `lib/src/xpath/functions/json.dart` retaining lexical number representation for XML, tracking Unicode escapes and surrogate pairs, and honoring XML 1.0 character validity.
  - Complete `xml-to-json` serializer with full XDM JSON namespace validation, `escaped` and `escaped-key` attribute handling (`FOJS0006`, `FOJS0007`), duplicate key detection, double formatting per XPath 3.1 §18.2, and solidus escaping per bug 29665.
- **Files**:
  - `lib/src/xpath/functions/json.dart`
- **Unit Tests**:
  - `test/xpath/functions/json_test.dart`

---

### 7. XML Serialization (`fn:serialize`)

- [x] **Status**: Completed
- **User Impact**: Medium
- **Primary Suites**: `fn-serialize`
- **Addressed**:
  - Implemented `SerializationParameters` in `lib/src/xpath/functions/serialization.dart` with support for loading from XML elements (`output:serialization-parameters`) and XDM maps (`map(*)`).
  - Validated options (`method`, `indent`, `omit-xml-declaration`, `standalone`, `item-separator`, `version`, `encoding`, `cdata-section-elements`, `suppress-indentation`, `use-character-maps`, `allow-duplicate-names`, etc.) with standard error codes (`SEPM0016`, `SEPM0017`, `SEPM0019`, `SERE0020`, `SERE0022`, `SERE0023`, `SENR0001`, `XPTY0004`, `XQDY0137`).
  - Added full serializer support for all output methods: `xml`, `html` (with HTML5 DOCTYPE and `<meta>` charset insertion), `xhtml`, `text`, `json` (with array/map formatting and character escape handling), and `adaptive` (with boolean `true()`/`false()` notation).
  - Fixed duplicate key enforcement `[err:XQDY0137]` in `MapConstructor`.
- **Files**:
  - `lib/src/xpath/functions/serialization.dart`
  - `lib/src/xpath/functions/accessor.dart`
  - `lib/src/xpath/expressions/constructors.dart`
- **Unit Tests**:
  - `test/xpath/functions/serialization_test.dart`
  - `test/xpath/functions/accessor_test.dart`

---

### 8. SequenceType & `instance of` Matching

- [x] **Status**: Completed
- **User Impact**: Medium-Low
- **QT3 Target**: 87 issues (68 failures, 19 errors) → **all resolved**
- **Primary Suites**: `prod-InstanceofExpr` 273/273, `prod-ArrayTest` 47/47, `prod-MapTest` 44/44, `prod-TreatExpr` 61/61
- **Addressed**:
  - Added `XPathArrayType(memberType)`, `XPathMapType(keyType, valueType)`, and
    `XPathFunctionType({parameterTypes, returnType})` in `lib/src/xpath/xdm/types.dart`
    with correct parent hierarchy (`XPathArrayType → xsArray → xsFunction`,
    `XPathMapType → xsMap → xsFunction`, `XPathFunctionType → xsFunction`).
  - Each type implements `isSubtypeOf` (contra/covariant for functions, covariant for
    arrays/maps), `matchesItem`, `operator==`, `hashCode`, and `name`.
  - `XPathMapType.isSubtypeOf(XPathFunctionType)` handles the XDM map-as-function
    subtype relationship per XPath 3.1 §2.5.5.3.
  - Wired parameterized type grammar: `typedArrayTest`, `typedMapTest`, and
    `typedFunctionTest` now produce typed descriptors instead of wildcards.
  - Added `_resolveAtomicType` helper in `lib/src/xpath/grammars/xpath.dart` that
    rejects unknown or bare unqualified atomic type names with `[err:XPST0051]`.
  - `InlineFunctionExpression` and `_XPathInlineFunction` carry declared param types
    and return type; params are validated at call time (`[err:XPTY0004]`), and the
    declared types participate in `instance of function(T) as R` matching.
  - Added `parameterTypes`/`returnType` to `fnName#1` (param `node()?`, return
    `xs:string`) and `fnFilter#2` (params `item()*` and `function(item()) as
    xs:boolean`, return `item()*`) enabling typed `instance of` checks on built-in
    higher-order functions.
  - `XPathCardinality.isSubtypeOf` models the cardinality lattice required for
    sequence-type subtype checking.
- **Files**:
  - `lib/src/xpath/xdm/types.dart`
  - `lib/src/xpath/xdm/function_item.dart`
  - `lib/src/xpath/expressions/function.dart`
  - `lib/src/xpath/grammars/xpath.dart`
  - `lib/src/xpath/functions/node.dart`
  - `lib/src/xpath/functions/higher_order.dart`
  - `lib/src/xpath/evaluation/cardinality.dart`
- **Unit Tests**:
  - `test/xpath/evaluation/cardinality_test.dart`
  - `test/xpath/expressions/types_test.dart`
  - `test/xpath/xdm/types_test.dart`

---

### 9. Higher-Order Functions & Dynamic Introspection

- [x] **Status**: Completed
- **User Impact**: Low-Medium
- **QT3 Target**: 156 issues (136 failures, 20 errors)
- **Primary Suites**: `fn-function-lookup` (655/666 passed, 98.3%), `prod-NamedFunctionRef` (540/546 passed, 98.9%), `fn-collection` (26/26 passed, 100.0%), `fn-random-number-generator` (41/41 passed, 100.0%)
- **Implementation Notes**:
  - `fn:function-lookup`:
    - Strict argument type/cardinality validation returning `[err:XPTY0004]` on non-single QName or non-single integer.
    - Negative arity returns empty sequence `()`.
    - Correct namespace resolution: resolves prefix via `context.configuration.namespaceUris` or default function namespace when unqualified, preserving absent namespace (`QName("", "round")` returns empty).
    - Captures context item on arity-0 dynamic function invocation.
  - `fn:function-name`:
    - Returns empty sequence for anonymous/inline functions and arrays/maps per XPath 3.1 §16.1.2.
    - Automatically resolves namespace URI from configuration when inspecting named function items.
  - XML Schema list type constructor functions:
    - Added `xs:IDREFS`, `xs:NMTOKENS`, and `xs:ENTITIES` constructor functions and type descriptors.
  - `fn:resolve-uri` and `fn:static-base-uri`:
    - Return `XPathAnyUri` typed atomic values instead of generic `XPathString`.
  - `fn:random-number-generator`:
    - Implemented with a single `math.Random` instance and an updated map, using deterministic seed initialization (`seed?.hashCode & 0x7FFFFFFF ?? 0`) for full JavaScript compatibility.
  - Collections and Document URI:
    - Added `collections: Map<String, List<XmlNode>>` to `XPathConfiguration` with default collection lookup (`''`).
    - Implemented `fn:collection` and `fn:uri-collection` with `[err:FODC0002]` raised when collection or default collection is not available.
    - Implemented `fn:base-uri` and `fn:document-uri` with `xml:base` attribute resolution and document URI tracking.
- **Files**:
  - `lib/src/xpath/functions/higher_order.dart`
  - `lib/src/xpath/functions/uri.dart`
  - `lib/src/xpath/functions/context.dart`
  - `lib/src/xpath/functions/accessor.dart`
  - `lib/src/xpath/functions/number.dart`
  - `lib/src/xpath/functions/constructors.dart`
  - `lib/src/xpath/evaluation/configuration.dart`
  - `lib/src/xpath/evaluation/functions.dart`
  - `lib/src/xpath/expressions/function.dart`
  - `lib/src/xpath/xdm/types.dart`
  - `bin/qt3/models.dart`
- **Unit Tests**:
  - `test/xpath/functions/higher_order_test.dart`
  - `test/xpath/functions/uri_test.dart`
  - `test/xpath/functions/sequence_test.dart`
  - `test/xpath/expressions/function_test.dart`

---

### 10. Unicode Collation Algorithm (UCA) & Collation URIs

- [ ] **Status**: Pending
- **User Impact**: Low
- **QT3 Target**: 62 issues (62 failures, 0 errors)
- **Primary Suites**: `misc-UCACollation`, `fn-compare`, `fn-contains`, `fn-starts-with`
- **Root Causes**:
  - Collation URIs (`http://www.w3.org/2013/collation/UCA?...`) fallback to codepoint comparison or fail.
- **Implementation Steps**:
  1. Parse collation URIs into strength and case-handling parameters.
  2. Apply collation comparison in string comparison and search functions in `lib/src/xpath/functions/string.dart`.
- **Files**:
  - `lib/src/xpath/functions/string.dart`
- **Unit Tests**:
  - `test/xpath/functions/string_test.dart`

---

### 11. Arbitrary-Precision Integers (`BigInt`) & Number Formatting

- [x] **Status**: Completed
- **User Impact**: Very Low
- **Primary Suites**: `fn-round`, `fn-round-half-to-even`, `op-to`, `prod-Literal`
- **Addressed**:
  - `XPathInteger` uses `BigInt` for arbitrary precision arithmetic and range iteration (`lib/src/xpath/xdm/atomic/numeric.dart`).
  - `XPathDecimal` implements exact decimal representation with `BigInt` unscaled value and scale.
  - `RangeExpression` in `lib/src/xpath/expressions/range.dart` operates on `XPathInteger` with full `BigInt` precision.
  - `XPathDouble` correctly formats special values (`NaN`, `INF`, `-INF`, `0`, and exponential forms).
- **Files**:
  - `lib/src/xpath/xdm/atomic/numeric.dart`
  - `lib/src/xpath/expressions/range.dart`
- **Unit Tests**:
  - `test/xpath/xdm/atomic/numeric_test.dart`
