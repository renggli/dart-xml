# XPath 3.1 Compliance Roadmap & Implementation Tracker

This document tracks known discrepancies between PetitXml XPath 3.1 implementation and the official W3C QT3 test-suite, ordered by real-world user impact.

---

## Baseline Stats (QT3 Test Suite)

- **Suites**: 369
- **Total Cases**: 22,514
- **Passing**: 18,842 (83.7%)
- **Failures**: 2,911 (12.9%)
- **Errors**: 761 (3.4%)
- **Target Issues (excl. regex & date/number formatting)**: 2,421 (2,009 failures, 412 errors)

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

- [ ] **Status**: Pending
- **User Impact**: High / Frequent
- **QT3 Target**: 65 issues (59 failures, 6 errors)
- **Primary Suites**: `prod-ValueComp`, `prod-GeneralComp.eq`, `prod-GeneralComp.ne`, `prod-GeneralComp.lt`, `prod-GeneralComp.gt`
- **Root Causes**:
  - Value comparisons (`eq`, `ne`, `lt`, `gt`, `le`, `ge`) between disjoint atomic types (e.g. string vs integer, date vs time) return `false` instead of raising dynamic type error `XPTY0004`.
  - Value comparisons with an empty sequence return boolean instead of returning an empty sequence `()`.
  - General comparisons with empty sequences produce unexpected truth values.
- **Implementation Steps**:
  1. In `lib/src/xpath/expressions/operators.dart`, update `ValueComparisonExpression`:
     - If either operand is empty sequence `()`, return `XPathSequence.empty`.
     - Verify both operands are atomic items with comparable types (per XPath 3.1 §3.5.1). If non-comparable, throw `XPathEvaluationException` (`XPTY0004`).
  2. Ensure `GeneralComparisonExpression` atomizes operands and applies standard type promotion rules without swallowing type errors when explicitly mandated.
- **Files**:
  - `lib/src/xpath/expressions/operators.dart`
  - `lib/src/xpath/evaluation/operators.dart`
- **Unit Tests**:
  - `test/xpath/expressions/operators_test.dart`

---

### 3. Numeric Aggregations & Modulo Semantics

- [ ] **Status**: Pending
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

- [ ] **Status**: Pending
- **User Impact**: Medium-High
- **QT3 Target**: 473 issues (459 failures, 14 errors)
- **Primary Suites**: `prod-CastExpr`, `prod-CastableExpr`, `prod-CastExpr.derived`
- **Root Causes**:
  - `CastExpression` and `CastableExpression` lack the W3C §17 type transition matrix. Illegal conversions (e.g. `xs:float` to `xs:anyURI`, `xs:date` to `xs:time`) succeed or return `true`.
  - `castable as` does not raise `FOTY0013` when applied to function items, maps, or arrays.
  - Disallow casting to abstract types `xs:anyAtomicType` and `xs:NOTATION` (`XPST0080`).
- **Implementation Steps**:
  1. Implement a 2D matrix or lookup table representing XPath 3.1 §17 casting rules in `lib/src/xpath/definitions/type.dart` or `lib/src/xpath/evaluation/types.dart`.
  2. In `CastExpression`, enforce source-to-target legality before attempting type conversion, throwing `XPathEvaluationException` (`XPTY0004` / `XPST0080`).
  3. In `CastableExpression`, reject non-atomic types with `FOTY0013` error and evaluate allowed castability via the matrix.
- **Files**:
  - `lib/src/xpath/definitions/type.dart`
  - `lib/src/xpath/expressions/types.dart`
  - `lib/src/xpath/evaluation/types.dart`
- **Unit Tests**:
  - `test/xpath/expressions/types_test.dart`

---

### 5. Date, Time & Duration Operations & IETF Parser

- [ ] **Status**: Pending
- **User Impact**: Medium-High
- **QT3 Target**: 187 issues (111 failures, 76 errors)
- **Primary Suites**: `fn-parse-ietf-date`, `op-duration-equal`, `op-dateTime-equal`, `op-time-equal`, `op-divide-dayTimeDuration`
- **Root Causes**:
  - `fn:parse-ietf-date` is unimplemented.
  - Duration comparisons do not enforce subtype equivalence (`yearMonthDuration` vs `dayTimeDuration` must error).
  - Time-only timezone adjustments lack implicit timezone context fallback.
- **Implementation Steps**:
  1. Implement `fn:parse-ietf-date` in `lib/src/xpath/functions/date_time.dart` supporting RFC 2822 (`Mon, 20 Nov 1995 19:12:08 -0500`), RFC 850, and ANSI C `asctime()`.
  2. Enforce duration comparison compatibility in `lib/src/xpath/functions/duration.dart`.
  3. Correct timezone adjustment calculation in `fn:adjust-time-to-timezone`.
- **Files**:
  - `lib/src/xpath/functions/date_time.dart`
  - `lib/src/xpath/functions/duration.dart`
  - `lib/src/xpath/types/date_time.dart`
  - `lib/src/xpath/types/duration.dart`
- **Unit Tests**:
  - `test/xpath/functions/date_time_test.dart`
  - `test/xpath/functions/duration_test.dart`

---

### 6. JSON Support & Interoperability

- [ ] **Status**: Pending
- **User Impact**: Medium
- **QT3 Target**: 156 issues (129 failures, 27 errors)
- **Primary Suites**: `fn-json-to-xml`, `fn-parse-json`, `fn-xml-to-json`, `fn-json-doc`
- **Root Causes**:
  - `fn:json-to-xml`: Missing attribute `escaped="true"` for escaped Unicode/control characters; missing XML schema type wrapper attributes.
  - `fn:parse-json`: Missing options map (`duplicates`, `escape`, `fallback`).
  - `fn:xml-to-json`: Slash escaping and key ordering.
- **Implementation Steps**:
  1. Add options map parsing in `fn:parse-json` (`lib/src/xpath/functions/json.dart`).
  2. Ensure `fn:json-to-xml` matches W3C XML representation for JSON (including `escaped="true"` and untyped atomic elements).
  3. Fix character escaping roundtripping in `fn:xml-to-json`.
- **Files**:
  - `lib/src/xpath/functions/json.dart`
- **Unit Tests**:
  - `test/xpath/functions/json_test.dart`

---

### 7. XML Serialization (`fn:serialize`)

- [ ] **Status**: Pending
- **User Impact**: Medium
- **QT3 Target**: 89 issues (59 failures, 30 errors)
- **Primary Suites**: `fn-serialize`
- **Root Causes**:
  - Lacks full serialization parameter map support (`output:serialization-parameters`).
  - Methods `xml`, `xhtml`, `html`, `text`, `json`, `adaptive` not fully dispatched.
  - Parameter options (`omit-xml-declaration`, `indent`, `cdata-section-elements`) not wired to writer.
- **Implementation Steps**:
  1. Implement serialization parameters extraction from element or map options in `lib/src/xpath/functions/node.dart` (or dedicated serialization module).
  2. Wire parameters into `XmlPrettyWriter` or custom serializer for non-XML serialization methods.
- **Files**:
  - `lib/src/xpath/functions/node.dart`
- **Unit Tests**:
  - `test/xpath/functions/node_test.dart`

---

### 8. SequenceType & `instance of` Matching

- [ ] **Status**: Pending
- **User Impact**: Medium-Low
- **QT3 Target**: 87 issues (68 failures, 19 errors)
- **Primary Suites**: `prod-InstanceofExpr`, `prod-ArrayTest`, `prod-MapTest`, `prod-TreatExpr`
- **Root Causes**:
  - Parameterized tests (`array(xs:integer)`, `map(xs:string, xs:integer)`) do not validate item/key/value types.
  - Element and schema element tests (`element(foo, xs:untyped)`) not fully implemented.
- **Implementation Steps**:
  1. Enhance `ArrayType` and `MapType` in `lib/src/xpath/definitions/type.dart` to support nested element type validation.
  2. Implement `element()` and `schema-element()` type tests.
- **Files**:
  - `lib/src/xpath/definitions/type.dart`
  - `lib/src/xpath/expressions/types.dart`
  - `lib/src/xpath/grammars/parser.dart`
- **Unit Tests**:
  - `test/xpath/expressions/types_test.dart`

---

### 9. Higher-Order Functions & Dynamic Introspection

- [ ] **Status**: Pending
- **User Impact**: Low-Medium
- **QT3 Target**: 156 issues (136 failures, 20 errors)
- **Primary Suites**: `fn-function-lookup`, `prod-NamedFunctionRef`, `fn-collection`, `fn-random-number-generator`
- **Root Causes**:
  - `fn:function-name` returns `'dynamic-function'` instead of empty sequence `()` for anonymous functions.
  - `fn:random-number-generator` arity handling and map shape.
  - `fn:collection` missing default fallback.
- **Implementation Steps**:
  1. Return `XPathSequence.empty` for anonymous functions in `fn:function-name`.
  2. Align `fn:random-number-generator` map structure (`number`, `next`, `permute`) with XPath 3.1 specification.
  3. Wire default collection resolver into `XPathConfiguration`.
- **Files**:
  - `lib/src/xpath/functions/higher_order.dart`
  - `lib/src/xpath/evaluation/configuration.dart`
- **Unit Tests**:
  - `test/xpath/functions/higher_order_test.dart`

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
  2. Apply collation comparison in string comparison and search functions.
- **Files**:
  - `lib/src/xpath/functions/string.dart`
  - `lib/src/xpath/evaluation/context.dart`
- **Unit Tests**:
  - `test/xpath/functions/string_test.dart`

---

### 11. Arbitrary-Precision Integers (`BigInt`)

- [ ] **Status**: Pending
- **User Impact**: Very Low
- **QT3 Target**: 129 issues (113 failures, 16 errors)
- **Primary Suites**: `fn-round`, `fn-round-half-to-even`, `op-to`, `prod-Literal`
- **Root Causes**:
  - Dart 64-bit `int` overflow on integers > $2^{63}-1$.
  - Negative zero `-0.0` vs `-0` string formatting.
- **Implementation Steps**:
  1. Support `BigInt` for `xs:integer` when values exceed 64-bit bounds.
  2. Format negative zero floating point values as `"-0"` per XPath serialization rules.
- **Files**:
  - `lib/src/xpath/types/number.dart`
  - `lib/src/xpath/types/integer.dart`
  - `lib/src/xpath/expressions/range.dart`
- **Unit Tests**:
  - `test/xpath/types/number_test.dart`
