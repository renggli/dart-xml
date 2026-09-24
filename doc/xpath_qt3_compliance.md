# XPath 3.1 Compliance Roadmap & Implementation Tracker

This document tracks known discrepancies between PetitXml XPath 3.1 implementation and the official W3C QT3 test-suite, ordered by real-world user impact and ROI.

---

## Baseline Stats (QT3 Test Suite)

- **Suites**: 353
- **Total Cases**: 22,514
- **Passing**: 19,875 (88.3%)
- **Failures**: 2,049 (9.1%)
- **Errors**: 590 (2.6%)

---

## Issue Checklist & Implementation Guide

### 1. XML Path & Axis Step Edge Cases

- [x] **Status**: Resolved
- **User Impact**: High (core query functionality)
- **Cost to Fix**: ~15k–25k tokens
- **Code Size Increase**: ~100–200 LOC
- **QT3 Target**: 147 issues (130 failures, 17 errors)
- **Primary Suites**: `prod-AxisStep` (49), `fn-outermost` (17), `fn-innermost` (17), `prod-AxisStep.static-typing` (15), `prod-NameTest` (18), `prod-ContextItemExpr` (11), `fn-root` (6), `fn-path` (5)
- **Root Causes**:
  - Positional predicate evaluation on reverse axes (e.g. `ancestor::*[1]` requires reverse-axis indexing prior to document-order sorting).
  - Namespace axis (`namespace::*`) interaction with document order and synthetic node generation.
  - `fn:innermost` and `fn:outermost` document-order handling across disconnected nodes or XML fragment roots.
  - Wildcard namespace prefix matching (`*:local`, `prefix:*`) edge cases under varying static context setups.
- **Implementation Steps**:
  1. Audit predicate evaluation order in `lib/src/xpath/expressions/step.dart` for reverse axes to evaluate position in reverse document order before canonical document-order reordering.
  2. Normalize `fn:innermost` and `fn:outermost` in `lib/src/xpath/functions/node.dart` across disjoint document trees and empty sequences.
  3. Support namespace axis step iteration in `lib/src/xpath/expressions/axis.dart`.
- **Files**:
  - `lib/src/xpath/expressions/step.dart`
  - `lib/src/xpath/expressions/axis.dart`
  - `lib/src/xpath/functions/node.dart`
- **Unit Tests**:
  - `test/xpath/expressions/axis_test.dart`
  - `test/xpath/expressions/step_test.dart`
  - `test/xpath/functions/node_test.dart`

---

### 2. Numeric Semantics, Precision & IEEE Math

- [ ] **Status**: Pending
- **User Impact**: Medium-High (data accuracy and standard compliance)
- **Cost to Fix**: ~15k–20k tokens
- **Code Size Increase**: ~120–200 LOC
- **QT3 Target**: 226 issues (222 failures, 4 errors)
- **Primary Suites**: `fn-round` (56), `fn-round-half-to-even` (23), `op-numeric-divide` (25), `fn-number` (20), `op-numeric-integer-divide` (18), `fn-abs` (15)
- **Root Causes**:
  - Negative zero (`-0.0` vs `0.0`): serialization and arithmetic losing negative zero representation; `Expected -0, but got (0)`.
  - `NaN` comparison in `fn:deep-equal`: two `NaN` floats/doubles must compare equal in `fn:deep-equal` per XPath 3.1 §16.1.1 (standard `eq` returns false).
  - `fn:round` arity-2 rounding to negative precision, tie-breaking towards positive infinity (different from half-to-even), and float overflow to `INF`/`-INF`.
  - Integer division (`idiv`) overflow checks throwing `[err:FOAR0002]` on `BigInt` overflow vs division by zero (`[err:FOAR0001]`).
- **Implementation Steps**:
  1. Preserve `-0.0` across `XPathDouble` and `XPathDecimal`, formatting `-0.0` as `-0` in string values.
  2. Implement `fn:deep-equal` IEEE 754 `NaN` equivalence rule in `lib/src/xpath/functions/sequence.dart`.
  3. Align `fn:round` and `fn:round-half-to-even` in `lib/src/xpath/functions/math.dart` for negative precision scaling and tie rules.
  4. Ensure `op:numeric-integer-divide` correctly distinguishes `FOAR0001` (division by zero) from `FOAR0002` (overflow).
- **Files**:
  - `lib/src/xpath/xdm/atomic/numeric.dart`
  - `lib/src/xpath/functions/math.dart`
  - `lib/src/xpath/functions/sequence.dart`
  - `lib/src/xpath/operators/arithmetic.dart`
- **Unit Tests**:
  - `test/xpath/xdm/atomic/numeric_test.dart`
  - `test/xpath/functions/math_test.dart`
  - `test/xpath/operators/arithmetic_test.dart`

---

### 3. Regular Expressions & String Analysis

- [ ] **Status**: Pending
- **User Impact**: High (frequently used for text manipulation & validation)
- **Cost to Fix**: ~35k–50k tokens
- **Code Size Increase**: ~600–900 LOC
- **QT3 Target**: 679 issues (340 failures, 339 errors)
- **Primary Suites**: `fn-matches.re` (570), `fn-replace` (38), `fn-analyze-string` (28), `fn-matches` (23)
- **Root Causes**:
  - W3C XML Schema Regex vs Dart `RegExp`: W3C regex supports Unicode categories (`\p{Is...}`, `\p{L}`, `\p{Nd}`), character class subtraction (`[a-z-[aeiou]]`), and multi-character escape codes not supported by Dart's ECMAScript regex engine, resulting in `[err:FORX0002]`.
  - XPath 3.1 regex flags: flag `q` (literal quote mode) and whitespace suppression in `x` flag mode.
  - `fn:analyze-string`: completely unimplemented (`[err:FOER0000]`); required to produce `<fn:analyze-string-result>` XML elements with `<fn:match>` and `<fn:non-match>` children.
  - Replacement string group handling in `fn:replace` (`$0`, `$1`, `\$`, `\\`).
- **Implementation Steps**:
  1. Build an XML Schema regex pattern preprocessor/transpiler translating `\p{Is...}`, character class subtractions, and flag `q` into Dart-compatible `RegExp` patterns or PetitParser-based matching.
  2. Implement `fn:analyze-string` in `lib/src/xpath/functions/string.dart` returning canonical XML result elements.
  3. Validate regex syntax strictly per W3C specification, raising `[err:FORX0002]` for invalid quantifiers or syntax.
- **Files**:
  - `lib/src/xpath/functions/string.dart`
  - `lib/src/xpath/common/regex.dart` (new)
- **Unit Tests**:
  - `test/xpath/functions/string_test.dart`

---

### 4. Type Casting, Bounds & Float Representation

- [ ] **Status**: Pending
- **User Impact**: Medium (interoperability with schema datatypes)
- **Cost to Fix**: ~15k–20k tokens
- **Code Size Increase**: ~100–180 LOC
- **QT3 Target**: 143 issues (134 failures, 9 errors)
- **Primary Suites**: `prod-CastExpr` (94), `prod-CastableExpr` (35)
- **Root Causes**:
  - `xs:float` canonical string representation: scientific notation required when magnitude is $\ge 10^6$ or $< 10^{-6}$ (e.g. `1.2678968E7`), and 32-bit single precision IEEE rounding.
  - Strict lexical validation when casting from `xs:string` / `xs:untypedAtomic` to numeric types (rejecting whitespace within numbers, invalid signs, or exponents without digits).
  - Abstract/forbidden target types: casting to `xs:NOTATION`, `xs:anySimpleType`, `xs:anyAtomicType` must raise `[err:XPST0080]`.
- **Implementation Steps**:
  1. Separate `XPathFloat` from `XPathDouble` or add float formatting logic that enforces 32-bit precision and W3C scientific notation rules.
  2. Enforce lexical syntax rules in numeric `tryParse` helpers.
  3. Prevent casting to abstract types in `CastExpression` and `CastableExpression`.
- **Files**:
  - `lib/src/xpath/xdm/atomic/numeric.dart`
  - `lib/src/xpath/expressions/types.dart`
  - `lib/src/xpath/xdm/casting_matrix.dart`
- **Unit Tests**:
  - `test/xpath/expressions/types_test.dart`
  - `test/xpath/xdm/casting_matrix_test.dart`

---

### 5. Formatting Functions (`format-number`, `format-dateTime`, `format-integer`)

- [ ] **Status**: Pending
- **User Impact**: Medium (presentation, report generation)
- **Cost to Fix**: ~30k–45k tokens
- **Code Size Increase**: ~500–800 LOC
- **QT3 Target**: 565 issues (558 failures, 7 errors)
- **Primary Suites**: `fn-format-number` (214), `fn-format-date` (121), `fn-format-dateTime` (84), `fn-format-time` (84), `fn-format-integer` (62)
- **Root Causes**:
  - `fn:format-number`: picture string parsing (mandatory `0`, optional `#`, grouping `,`, decimal `.`, percent `%`, per-mille `‰`, min/max digits, exponent `e`/`E`), plus decimal format configurations.
  - `fn:format-dateTime`, `fn:format-date`, `fn:format-time`: picture string variable components (`[Y]`, `[M01]`, `[D]`, `[H]`, `[m]`, `[s]`, `[z]`, `[Z]`), width specifiers, language fallback.
  - `fn:format-integer`: picture format strings (e.g. `001`, `a`, `A`, `i`, `I`, `w`, `W`).
- **Implementation Steps**:
  1. Implement picture string parser for `fn:format-number` with decimal format symbols in `lib/src/xpath/functions/format_number.dart`.
  2. Implement date/time picture parser for `fn:format-date`, `fn:format-time`, `fn:format-dateTime`.
  3. Implement integer formatting with roman numerals and alpha numbering in `fn:format-integer`.
- **Files**:
  - `lib/src/xpath/functions/format_number.dart` (new)
  - `lib/src/xpath/functions/date_time.dart`
- **Unit Tests**:
  - `test/xpath/functions/format_number_test.dart`
  - `test/xpath/functions/date_time_test.dart`

---

### 6. Function Resolution, EQName & Syntax Validation

- [x] **Status**: Resolved
- **User Impact**: Medium (correct parsing & error reporting)
- **Cost to Fix**: ~10k–15k tokens
- **Code Size Increase**: ~80–150 LOC
- **QT3 Target**: 109 issues (83 failures, 26 errors)
- **Primary Suites**: `prod-NamedFunctionRef` (22), `prod-FunctionCall` (18), `prod-Literal` (17), `fn-QName` (17), `prod-EQName` (10)
- **Root Causes**:
  - Dynamic function invocations where context item is implicitly required.
  - Numeric and string literal syntax validation (e.g. adjacent operators, scientific exponent formatting, invalid character references).
  - Prefix-to-URI resolution in `fn:QName` rejecting invalid NCNames with `[err:FOCA0002]`.
- **Implementation Steps**:
  1. Validate literal tokens and EQName syntax strictly during grammar parsing.
  2. Refine `fn:QName` and `fn:resolve-QName` validation rules and error codes.
  3. Ensure dynamic function item calls correctly inherit or check context items.
- **Files**:
  - `lib/src/xpath/grammars/xpath.dart`
  - `lib/src/xpath/functions/qname.dart`
  - `lib/src/xpath/expressions/function.dart`
- **Unit Tests**:
  - `test/xpath/functions/qname_test.dart`
  - `test/xpath/expressions/function_test.dart`

---

### 7. Unicode Collation Algorithm (UCA) & Collation URIs

- [ ] **Status**: Pending
- **User Impact**: Low (advanced linguistic sorting/comparison)
- **Cost to Fix**: ~20k–30k tokens
- **Code Size Increase**: ~250–400 LOC
- **QT3 Target**: 131 issues (131 failures, 0 errors)
- **Primary Suites**: `misc-UCACollation` (49), `fn-compare` (20), `fn-contains` (15), `fn-collation-key` (13), `fn-starts-with` (10), `fn-ends-with` (9), `fn-substring-before` (8), `fn-substring-after` (7)
- **Root Causes**:
  - Collation URIs (`http://www.w3.org/2013/collation/UCA?...`) fallback to codepoint comparison or fail.
  - Missing support for collation strength (`primary`, `secondary`, `tertiary`), `caseLevel`, and `caseFirst`.
  - `fn:collation-key` unimplemented or returning codepoints.
- **Implementation Steps**:
  1. Parse UCA collation URI parameters (`strength`, `caseLevel`, `caseFirst`).
  2. Apply case-folding and accent-folding comparisons based on collation strength.
  3. Implement `fn:collation-key` generating canonical sort keys.
- **Files**:
  - `lib/src/xpath/functions/string.dart`
- **Unit Tests**:
  - `test/xpath/functions/string_test.dart`

---

### 8. Unparsed Text & Resource Decoding

- [ ] **Status**: Pending
- **User Impact**: Low (external text file ingestion)
- **Cost to Fix**: ~10k–15k tokens
- **Code Size Increase**: ~100–150 LOC
- **QT3 Target**: 45 issues (33 failures, 12 errors)
- **Primary Suites**: `fn-unparsed-text` (19), `fn-unparsed-text-lines` (14), `fn-unparsed-text-available` (12)
- **Root Causes**:
  - Missing automatic encoding detection from byte order marks (BOM) or XML declarations for UTF-16LE, UTF-16BE, ISO-8859-1.
  - Raising correct error codes: `[err:FOUT1170]` (resource not found), `[err:FOUT1190]` (cannot decode octet sequence), `[err:FOUT1200]` (unsupported encoding).
- **Implementation Steps**:
  1. Inspect BOM / leading bytes in `unparsedTextLoader` to determine encoding when not specified.
  2. Map decoding errors to `XPathEvaluationException.fout1190` and missing resources to `fout1170`.
- **Files**:
  - `lib/src/xpath/functions/accessor.dart`
  - `bin/qt3/models.dart`
- **Unit Tests**:
  - `test/xpath/functions/accessor_test.dart`

---

### 9. XSLT 3.0 & Dynamic XQuery Modules (Out of Scope)

- [ ] **Status**: Won't Fix / Out of Scope
- **User Impact**: Negligible (PetitXml is an XPath/XML library, not an XSLT/XQuery compiler)
- **Cost to Fix**: >500k tokens
- **Code Size Increase**: >5,000 LOC
- **QT3 Target**: 119 issues (0 failures, 119 errors)
- **Primary Suites**: `fn-transform` (85), `fn-load-xquery-module` (33)
- **Root Causes**:
  - `fn:transform` invokes an external XSLT 3.0 processor.
  - `fn:load-xquery-module` dynamically loads XQuery 3.1 modules.
  - Both are optional features in the XPath 3.1 specification intended for full XSLT/XQuery engines.
