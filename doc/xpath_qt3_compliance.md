# XPath 3.1 Compliance Roadmap & Implementation Tracker

This document tracks known discrepancies between PetitXml XPath 3.1 implementation and the official W3C QT3 test-suite, ordered by real-world user impact.

---

## Baseline Stats (QT3 Test Suite)

- **Suites**: 369
- **Total Cases**: 22,514
- **Passing**: 19,197 (85.3%)
- **Failures**: 2,298 (10.2%)
- **Errors**: 1,019 (4.5%)

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

- [ ] **Status**: Pending
- **User Impact**: Medium-Low
- **QT3 Target**: 87 issues (68 failures, 19 errors)
- **Primary Suites**: `prod-InstanceofExpr`, `prod-ArrayTest`, `prod-MapTest`, `prod-TreatExpr`
- **Root Causes**:
  - Parameterized tests (`array(xs:integer)`, `map(xs:string, xs:integer)`) in `lib/src/xpath/grammars/xpath.dart` fall back to generic `xsArray` / `xsMap` without validating member or entry types.
  - Element tests with type specifiers (`element(foo, xs:untyped)`) and `schema-element()` are unimplemented.
- **Implementation Steps**:
  1. Introduce parameterized `XPathArrayType(memberType)` and `XPathMapType(keyType, valueType)` in `lib/src/xpath/xdm/types.dart` and update `XPathType.matchesItem`.
  2. Wire parameterized `array(...)` and `map(...)` parsing in `lib/src/xpath/grammars/xpath.dart`.
  3. Implement typed `element(name, type)` matching in `lib/src/xpath/expressions/node.dart`.
- **Files**:
  - `lib/src/xpath/xdm/types.dart`
  - `lib/src/xpath/expressions/node.dart`
  - `lib/src/xpath/grammars/xpath.dart`
- **Unit Tests**:
  - `test/xpath/expressions/types_test.dart`
  - `test/xpath/xdm/types_test.dart`

---

### 9. Higher-Order Functions & Dynamic Introspection

- [ ] **Status**: Pending
- **User Impact**: Low-Medium
- **QT3 Target**: 156 issues (136 failures, 20 errors)
- **Primary Suites**: `fn-function-lookup`, `prod-NamedFunctionRef`, `fn-collection`, `fn-random-number-generator`
- **Root Causes**:
  - `fn:function-lookup` fails on certain built-in and overloaded functions due to namespace or arity lookup mismatches.
  - `fn:collection` returns empty sequence without fallback to default collection in `XPathConfiguration`.
  - `fn:load-xquery-module` and `fn:transform` throw `UnimplementedError`.
- **Implementation Steps**:
  1. Add default collection resolver support in `XPathConfiguration` and wire into `fn:collection` in `lib/src/xpath/functions/uri.dart`.
  2. Verify all standard functions and user-defined functions can be looked up dynamically via `fn:function-lookup`.
  3. Handle XQuery/XSLT module invocation stubbing or graceful failure.
- **Files**:
  - `lib/src/xpath/functions/higher_order.dart`
  - `lib/src/xpath/functions/uri.dart`
  - `lib/src/xpath/evaluation/configuration.dart`
- **Unit Tests**:
  - `test/xpath/functions/higher_order_test.dart`
  - `test/xpath/functions/uri_test.dart`

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
