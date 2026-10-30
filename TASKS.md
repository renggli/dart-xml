# PetitXml Codebase Review & Actionable Tasks

This document catalogs actionable issues and feature tasks across `package:xml` (`lib/xml.dart`), `package:xml/xml_events.dart` (`lib/xml_events.dart`), and `package:xml/xpath.dart` (`lib/xpath.dart`), organized by category:

1. [Bugs and Edge Cases](#1-bugs-and-edge-cases)
2. [Performance Issues](#2-performance-issues)
3. [Code Style and Readability](#3-code-style-and-readability)
4. [Missing or Broken Documentation](#4-missing-or-broken-documentation)
5. [Simplicity and Cleanness of Public APIs](#5-simplicity-and-cleanness-of-public-apis)
6. [Missing Features](#6-missing-features)
7. [Large Files, Complex Structure, Distributed Responsibility, and Dead Code](#7-large-files-complex-structure-distributed-responsibility-and-dead-code)
8. [Future Work and Later Consideration](#8-future-work-and-later-consideration)

---

## 1. Bugs and Edge Cases

### BUG-1: `XmlDocumentFragment` Serializes as `#document-fragment` (`SER-1`) [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xml/visitors/writer.dart:88-90`, `lib/src/xml/visitors/pretty_writer.dart:40-44`
- **Problem**: `XmlWriter.visitDocumentFragment` writes the literal string `'#document-fragment'` instead of serializing the fragment's child nodes. Calling `fragment.toXmlString()` outputs invalid XML (`#document-fragment`), and `XmlPrettyWriter` lacks a `visitDocumentFragment` override.
- **Fix**: Replace `buffer.write('#document-fragment')` with `writeIterable(node.children)` in `XmlWriter.visitDocumentFragment`, and override `visitDocumentFragment` in `XmlPrettyWriter` to format `node.children` identically to `visitDocument`.

### BUG-2: `XmlAttribute.isNamespaceDeclaration` Misclassifies Prefixed Attributes Named `xmlns` [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xml/nodes/attribute.dart:31-33`
- **Problem**: `XmlAttribute.isNamespaceDeclaration` evaluates `name.prefix == xmlns || name.local == xmlns`. A prefixed attribute whose local name happens to be `xmlns` (e.g. `foo:xmlns="bar"`) has `name.local == 'xmlns'` and is falsely treated as an XML namespace declaration. Consequently, it is excluded from `elementAttributes` and XPath's `attribute::` axis. This also contradicts `XmlHasNamespaces` (`lib/src/xml/mixins/has_namespaces.dart:21-28`), which checks `attribute.name.prefix == ns.xmlns || (attribute.name.local == ns.xmlns && attribute.name.prefix == null)`.
- **Fix**: Change `XmlAttribute.isNamespaceDeclaration` to `name.prefix == xmlns || (name.prefix == null && name.local == xmlns)`.

### BUG-3: `setAttribute` and `removeAttribute` Ignore Documented `'*'` Wildcards and Misparse Prefixed Names [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xml/mixins/has_attributes.dart:64-96`, `lib/src/xml/mixins/has_attributes.dart:136-161`
- **Problem**: The doc comments on `setAttribute` and `removeAttribute` state that both `name` and `namespaceUri` can be the wildcard `'*'` (including examples like `element.setAttribute('*', 'value', namespaceUri: '...')` and `element.removeAttribute('name', namespaceUri: '*')`). However, `setAttribute` uses `createNameLookup` instead of `createNameMatcher`, which compares literal `'=='` against `'*'` and never matches existing attributes. Worse, when no match is found, `setAttribute` creates a new attribute using `XmlName.parts(name, namespaceUri: namespaceUri)`, which fails to split a prefixed `name` (e.g. `'ns:attr'`) into `prefix` and `local`, or creates an attribute literally named `'*'` with `namespaceUri: '*'`.
- **Fix**: Use `createNameMatcher(name, namespaceUri: namespaceUri)` in `setAttribute` (updating all matching attributes when wildcards are used), only append a new attribute when `name != '*'` and `namespaceUri != '*'`, and construct new attribute names with `XmlName.qualified(name, namespaceUri: namespaceUri)`.

### BUG-4: `XmlNodeList` Allows Attaching an Ancestor into Its Own Descendant (Cycle Creation) [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xml/utils/node_list.dart:273-323`
- **Problem**: `_XmlNodeListOperation._validate` checks `element.hasParent` and detaches the node from its current parent during `_expand`, but never checks whether any node in `source` is `target._parent` or an ancestor of `target._parent`. Executing `child.children.add(rootElement)` detaches `rootElement` from `XmlDocument` and attaches it as a child of `child`, creating a cycle in the `parent` chain that causes infinite loops or stack overflows in `root`, `depth`, `ancestors`, `namespaces`, `compareDocumentPosition`, and visitors.
- **Fix**: In `_XmlNodeListOperation._validate`, verify for each node in `source` that neither `target._parent` nor any node in `target._parent.ancestors` is identical to the inserted node, throwing `XmlParentException` if a cycle would be formed.

*(Note on previous BUG-5: Withdrawn; extensive test suite in `test/xml_events/stream_test.dart` verifies that 1-character chunk splits across XML documents containing entities are properly handled because `XmlEventDecoder` produces `XmlRawTextEvent`s and `XmlNormalizeEvents` recombines raw text before resolving `.value`).*

### BUG-5: `XmlPrettyWriter` Corrupts Adjacent `XmlText` Nodes and Fails to Restore `pretty` State on Error [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xml/visitors/pretty_writer.dart:60-64`, `lib/src/xml/visitors/pretty_writer.dart:114-127`
- **Problem**:
  1. `normalizeText` normalizes each `XmlText` node in isolation and joins adjacent `XmlText` nodes with `XmlToken.whitespace` (`' '`). If an element contains two adjacent `XmlText` nodes representing a single word (e.g. `XmlText('Hel')` and `XmlText('lo')`), `normalizeText` inserts a spurious space (`'Hel lo'`).
  2. When `preserveWhitespace!(node)` is `true`, `visitElement` sets `pretty = false; writeIterable(node.children); pretty = true;` without saving the previous `pretty` value or wrapping in `try`/`finally`, and `visitDocument` does not consult `preserveWhitespace`.
- **Fix**: Concatenate adjacent `XmlText` node values before trimming and collapsing whitespace in `normalizeText`, and save/restore `pretty` inside a `try`/`finally` block.

### BUG-6: Inconsistent Namespace Comparison Between `XmlName.==` and `isEqualNode` [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xml/utils/name.dart:111-123`, `lib/src/xml/extensions/comparison.dart:300-304`
- **Problem**: `XmlName.operator ==` compares `local` and `namespaceUri` (ignoring `prefix` when `namespaceUri != null`), whereas `_compareName` in `lib/src/xml/extensions/comparison.dart:300-304` only checks `name1.qualified == name2.qualified` (ignoring `namespaceUri`, with a `// Do we actually have to compare namespace resolution?` comment). Two elements with the same prefix bound to different namespace URIs test equal under `isEqualNode`.
- **Fix**: Compare `name1.qualified == name2.qualified && name1.namespaceUri == name2.namespaceUri` in `_compareName`.

### BUG-7: Unify `xpathGenerate` with Standard XPath `fn:path` Implementation [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/generator.dart:11-79`, `lib/src/xpath/functions/node.dart:420-514`
- **Problem**: `xpathGenerate` duplicates tree-walking and path-formatting logic that already exists in W3C standard `fn:path` (`_evalPath` in `lib/src/xpath/functions/node.dart`). Furthermore, `byId` formats ID lookups using `attribute.toXmlString()` which applies XML entity escaping rather than standard XPath string syntax.
- **Fix**: Replace the custom tree traversal in `xpathGenerate` with the standard XPath `fn:path` (`_evalPath`) logic. Breaking backward compatibility of the generated string format to align with standard XPath 3.1 `fn:path` (e.g., `Q{uri}local[index]`) is explicitly approved.

### BUG-8: `FollowingSiblingAxis` and `PrecedingSiblingAxis` Crash or Return Wrong Nodes on Root, Attribute, and Namespace Nodes [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/expressions/axis.dart:117-125`, `lib/src/xpath/expressions/axis.dart:168-176`
- **Problem**:
  1. Evaluating `following-sibling::*` or `preceding-sibling::*` when the context node has no parent (e.g. `XmlDocument` or a detached node) calls `node.siblings`, which throws `XmlParentException('Node has no parent')` instead of returning an empty sequence `()`.
  2. Per W3C XPath 3.1 §3.3.1.1, when the context node is an `attribute` or `namespace` node, both `following-sibling` and `preceding-sibling` axes must return the empty sequence. Currently, `node.siblings` returns `parent.attributes` for an `XmlAttribute` (treating other attributes as siblings) and `parent.children` for an `XmlNamespace` (where `siblings.indexOf(node)` returns `-1`, causing `FollowingSiblingAxis` to return all element children and `PrecedingSiblingAxis` to throw `RangeError` on `getRange(0, -1)`).
- **Fix**: At the start of `FollowingSiblingAxis.find` and `PrecedingSiblingAxis.find`, return `const []` if `!node.hasParent || node is XmlAttribute || node is XmlNamespace`.

### BUG-9: `PrecedingAxis` and `FollowingAxis` Return Incorrect Nodes for `XmlNamespace` and `XmlAttribute` [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/expressions/axis.dart:101-111`, `lib/src/xpath/expressions/axis.dart:148-162`, `lib/src/xml/extensions/following.dart:30-46`, `lib/src/xml/extensions/preceding.dart:28-46`
- **Problem**: `XmlPrecedingIterator` stops when `identical(_current, _start)`, which is never reached when `_start` is an `XmlNamespace` because namespace nodes are synthesized on the fly and are not in `children` or `attributes`; consequently, `preceding::*` on a namespace node returns the entire document. Similarly, in `XmlFollowingIterator`, when `_start` is an `XmlNamespace`, `parent.children.indexOf(child)` is `-1`, which accidentally works for the first level via `-1 + 1 == 0`, but for `XmlAttribute` in `XmlPrecedingIterator`, attributes are pushed to the stack after children (so popped before children), meaning `preceding::*` on an attribute node fails to include nodes that precede the owner element properly if not normalized.
- **Fix**: In `PrecedingAxis.find`, if `node is XmlAttribute || node is XmlNamespace`, substitute `node.parent` as the starting node (since attributes and namespaces have the same preceding nodes as their parent element). In `FollowingAxis.find`, if `node is XmlNamespace`, yield the parent element's `descendants` followed by `node.parent!.following`.

### BUG-10: Path Operator `/` Fails to Raise `XPTY0018` on Mixed Node and Non-Node Results [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/expressions/path.dart:75-104`, `lib/src/xpath/expressions/path.dart:158-178`
- **Problem**:
  1. Per W3C XPath 3.1 §3.3, if the evaluation of a step in a path expression yields a mix of nodes and non-nodes (atomic values or function items), dynamic error `err:XPTY0018` must be raised. In `_sortAndDeduplicate` (`lib/src/xpath/expressions/path.dart:177`), when `nodes.isNotEmpty && others.isNotEmpty`, it silently returns `XPathSequence([...nodes, ...others])` instead of throwing `XPTY0018`.
  2. `_isOrderPreserved` (`lib/src/xpath/expressions/path.dart:49-58`) returns `true` for `(1, 2)/.` (since `SequenceExpression` is step 0 and `ContextItemExpression` has `isOrderPreserved == true`), bypassing `_throwPathOperatorRequiresNodes` (`XPTY0019`) on the left-hand side of `/`.
- **Fix**: Throw `XPathEvaluationException(XPathErrorCode.XPTY0018, ...)` in `_sortAndDeduplicate` (and in the `isOrderPreserved` fast path) when results contain both `XPathNode` and non-`XPathNode` items, and ensure `_isOrderPreserved` requires step 0 to be a node-producing expression when `steps.length > 1`.

### BUG-11: `XPathNumeric` Violates `==` / `hashCode` Contract Across Numeric Subtypes [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/xdm/atomic/numeric.dart:208`, `lib/src/xpath/xdm/atomic/numeric.dart:474`, `lib/src/xpath/xdm/atomic/numeric.dart:662`, `lib/src/xpath/xdm/functions/map.dart:39-44`, `lib/src/xpath/xdm/functions/map.dart:97`
- **Problem**: `XPathInteger(1) == XPathDecimal(1, 0)` and `XPathInteger(1) == XPathDouble(1.0)` evaluate to `true`, but their `hashCode` getters return `BigInt.one.hashCode`, `Object.hash(BigInt.one, 0)`, and `1.0.hashCode` respectively, violating Dart's `==`/`hashCode` invariant. Consequently, `fnDistinctValues` (`lib/src/xpath/functions/sequence.dart:273-280`), which uses `Set<XPathAtomic>`, fails to deduplicate `1`, `1.0`, and `xs:decimal('1.00')`. In addition, `XPathMap.hashCode` (`lib/src/xpath/xdm/functions/map.dart:97`) is just `entries.length`.
- **Fix**: Compute a unified canonical `hashCode` across `XPathInteger`, `XPathDecimal`, and `XPathDouble` (e.g. normalizing trailing decimal zeros and hashing via `toDouble().hashCode` for values within exact IEEE-754 integer range), and compute `XPathMap.hashCode` from its entries.

### BUG-12: `opDivideDuration` Rounds Divisor to Integer Before Dividing [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/operators/duration.dart:40-62`
- **Problem**: `opDivideDuration` computes `final rounded = divisor.round();` and then `duration ~/ rounded;`. Dividing `xs:dayTimeDuration('PT3H')` by `1.5` rounds `1.5` to `2` and returns `PT1H30M` instead of `PT2H`. Dividing by `0.4` rounds `0.4` to `0` and falsely throws `FOAR0001` (Division by zero).
- **Fix**: Check `divisor == 0.0` for `FOAR0001`, check `divisor.isInfinite` (returning zero duration), and compute `(duration.totalMonths / divisor).round()` for year-month durations and `(duration.inMicroseconds / divisor).round()` for day-time durations.

### BUG-13: `XPathDateTime.tryParseTime` Discards Timezone Offset When Hour is `24` [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/xdm/atomic/date_time.dart:600-602`
- **Problem**: When `tryParseTime` parses `'24:00:00Z'` or `'24:00:00+02:00'`, line 601 returns `const XPathDateTime.time(0, 0, 0, 0, 0, null)`, discarding the parsed `offset`.
- **Fix**: Return `XPathDateTime.time(0, 0, 0, 0, 0, offset)`.

### BUG-14: `fn:deep-equal` Returns `true` for Any Two `XmlDocument` Nodes and Ignores Spec Rules for Children/Attributes [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/functions/sequence.dart:379-403`
- **Problem**:
  1. `_deepEqual` only has special branches for `XmlElement` and `XmlAttribute`; for `XmlDocument`, it falls through to `return na.value == nb.value;` (line 401). Since `XmlDocument.value` is always `null`, `fn:deep-equal($doc1, $doc2)` returns `true` for ANY two XML documents regardless of their contents.
  2. For `XmlElement` and `XmlDocument`, W3C F&O §14.2.1 requires ignoring `XmlComment` and `XmlProcessing` children when comparing child sequences, and comparing attributes by expanded QName `(namespaceUri, localName)` rather than `nb.getAttributeNode(attrA.name.qualified)` (which fails when two elements use different prefixes bound to the same namespace URI).
  3. For `XmlProcessing`, `na.value == nb.value` ignores `na.target == nb.target`.
- **Fix**: Add `XmlDocument` comparison (comparing filtered `XmlElement` and `XmlText` children), filter out `XmlComment` and `XmlProcessing` from element/document child comparisons, compare attributes by `(local, namespaceUri)` excluding `isNamespaceDeclaration`, and compare `target` on `XmlProcessing`.

### BUG-15: `fn:substring` Uses UTF-16 Code Units Instead of Unicode Codepoints and Misrounds Negative Halves [COMPLETED]
- **Status**: Completed
- **Severity**: Critical
- **Location**: `lib/src/xpath/functions/string.dart:152-182`
- **Problem**:
  1. `_evalSubstring` indexes into `sourceString` using `String.length` and `String.substring(s, e)` (UTF-16 code units) instead of Unicode codepoints (`runes`), corrupting strings containing supplementary characters (e.g. emoji `U+1F600`), whereas `fnStringLength` and `fnTranslate` in the same file properly use `.runes`.
  2. Line 168 (`final start = startVal.round()`) uses Dart's `double.round()` (round half away from zero, so `-0.5.round() == -1`), whereas XPath `fn:round` rounds half towards positive infinity (`round(-0.5) == 0`).
  3. When `lenVal == double.negativeInfinity`, line 169 (`lenVal.isFinite`) is `false`, so `end` becomes `double.infinity` and `fn:substring("abc", 1, -INF)` returns `"abc"` instead of `""`.
- **Fix**: Implement W3C round-half-to-positive-infinity (`(v + 0.5).floorToDouble()`), handle non-positive/infinite lengths per W3C F&O §5.4.3, and slice using codepoints (`runes`).

### BUG-16: `fn:contains`, `fn:starts-with`, `fn:ends-with`, `fn:substring-before`, and `fn:substring-after` Mishandle Empty First Argument [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/string.dart:328-334`, `lib/src/xpath/functions/string.dart:357-363`, `lib/src/xpath/functions/string.dart:386-392`, `lib/src/xpath/functions/string.dart:415-422`, `lib/src/xpath/functions/string.dart:445-452`
- **Problem**: Per W3C F&O §5.5, if the value of `$arg1` or `$arg2` is the empty sequence `()`, it is treated as the zero-length string `""`. Currently, `_evalContains(null, "")`, `_evalStartsWith(null, "")`, and `_evalEndsWith(null, "")` check `if (arg1 == null) return XPathSequence.falseSequence;` BEFORE checking if `arg2` is empty, so `contains((), "")` returns `false` instead of `true`. Similarly, `substring-after("abc", ())` returns `""` instead of `"abc"`.
- **Fix**: Normalize both arguments via `final s1 = arg1 ?? ''; final s2 = arg2 ?? '';` at the start of `_evalContains`, `_evalStartsWith`, `_evalEndsWith`, `_evalSubstringBefore`, and `_evalSubstringAfter`.

### BUG-17: `fn:compare` Uses UTF-16 Code Unit Order Instead of Unicode Codepoint Order [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/string.dart:72-77`, `lib/src/xpath/xdm/atomic/string.dart:54`
- **Problem**: `String.compareTo` compares UTF-16 code units, where surrogate pairs (`0xD800..0xDFFF`, representing codepoints `U+10000..U+10FFFF`) sort *before* BMP characters in `U+E000..U+FFFF`. Under the W3C Unicode codepoint collation, codepoints must be compared by rune value (`-1`, `0`, `1`). Also `fn:compare` must return strictly `-1`, `0`, or `1` (whereas `String.compareTo` is only guaranteed to return negative/zero/positive on all Dart platforms).
- **Fix**: Compare strings by iterating their `runes` and returning `r1.compareTo(r2).sign`.

### BUG-18: `fn:normalize-space`, `fn:tokenize`, and `fn:contains-token` Strip Non-XML Unicode Whitespace [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/string.dart:225-227`, `lib/src/xpath/functions/string.dart:628-634`, `lib/src/xpath/functions/string.dart:727-733`
- **Problem**: `_evalNormalizeSpace`, `_evalTokenize`, and `_evalContainsToken` use `String.trim()` and `RegExp(r'\s+')`. In Dart, `.trim()` and `\s` match Unicode whitespace such as `U+00A0` (NO-BREAK SPACE), `U+2000..U+200A`, and `U+FEFF`, whereas XPath 3.1 defines whitespace strictly as `#x20`, `#x9`, `#xA`, and `#xD`.
- **Fix**: Replace `_whitespaceRegExp` with `RegExp(r'[ \t\r\n]+')` and trim only `[ \t\r\n]` at the start and end of strings.

### BUG-19: `fn:analyze-string` Uses `lastIndexOf` Heuristic That Misplaces Repeated or Empty Capture Groups [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/regex.dart:789-803`, `lib/src/xpath/functions/regex.dart:845-910`
- **Problem**: Because Dart's `RegExpMatch` does not expose start/end indices for sub-groups, `_buildMatchChildren` attempts to locate each capturing group's substring inside `parentText` using `lastIndexOf` and `indexOf`. When two sibling groups match identical text or when an empty capturing group precedes trailing text (lines 896-899 flush all remaining `parentText` before emitting `<group nr="..."/>`), the group elements are emitted at the wrong positions. Additionally, `analyzeXPathString` compiles a new `RegExp` on every call instead of using `getCachedXPathRegex`.
- **Fix**: Cache the compiled `RegExp` and group structure, and instrument or match sub-groups deterministically (or advance `cursor` without flushing trailing text before an empty group when no preceding text was consumed).

### BUG-20: `map:merge` Ignores the `$options` (`duplicates`) Parameter [COMPLETED]
- **Status**: Completed
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/map.dart:109-131`
- **Problem**: `_evalMapMerge(XPathSequence maps, XPathMap? options)` accepts `options` from `map:merge($maps, $options)` but never inspects it, always overwriting earlier entries (`use-last`) instead of defaulting to `'use-first'` and supporting `'use-first'`, `'use-last'`, `'combine'`, `'reject'` (`FOJS0003`), and `'use-any'` per W3C F&O §17.1.3.
- **Fix**: Parse the `'duplicates'` key from `options` (defaulting to `'use-first'`), validate allowed values (raising `FOJS0005` on invalid option values), and implement `'use-first'`, `'use-last'`, `'combine'`, and `'reject'`.

### BUG-21: `fn:nilled` and `fn:normalize-unicode` Are Unimplemented Stubs
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/accessor.dart:57-64`, `lib/src/xpath/functions/string.dart:230-251`
- **Problem**:
  1. `_evalNilled` (`accessor.dart:60-62`) has a `// TODO: Implement proper nilled check based on xsi:nil attribute` and always returns `false`.
  2. `fnNormalizeUnicode` (`string.dart:230-251`) ignores its `$normalizationForm` argument and returns the input unchanged without validating the form name (`FOCH0003`).
- **Fix**: In `_evalNilled`, check for `xsi:nil` (`namespaceUri == 'http://www.w3.org/2001/XMLSchema-instance'` and `local == 'nil'`) with trimmed value `'true'` or `'1'`. In `fnNormalizeUnicode`, validate the normalization form (`NFC`, `NFD`, `NFKC`, `NFKD`, `FULLY-NORMALIZED`, or `""`).

### BUG-22: `fn:uri-collection` Drops Relative URIs
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/uri.dart:232-235`, `lib/src/xpath/functions/uri.dart:268-271`
- **Problem**: `_fnUriCollection0` and `_fnUriCollection1` only include a document's URI if `entry.key.contains('://') || entry.key.startsWith('/')`, silently dropping relative document URIs registered in `context.configuration.documents`.
- **Fix**: Return all matching document keys from `context.configuration.documents` (or resolve relative keys against `context.configuration.baseUri`).

### BUG-23: `XmlSubtreeSelectorSink.close` Does Not Clear Stack or Validate Unclosed Elements
- **Severity**: Warning
- **Location**: `lib/src/xml_events/streams/subtree_selector.dart:70-73`
- **Problem**: When an event stream closes prematurely while inside a selected subtree (`stack.isNotEmpty`), `_XmlSubtreeSelectorSink.close` closes `result` without clearing `stack` or throwing an `XmlTagException` (unlike `_XmlNodeDecoderSink.close` and `_XmlWithParentEventsSink.close`).
- **Fix**: Clear `stack` or validate `XmlTagException.checkUnclosedTag` in `_XmlSubtreeSelectorSink.close`.

---

## 2. Performance Issues

### PERF-1: `XmlName.prefix` and `XmlName.local` Recompute `indexOf(':')` and `substring` on Every Access
- **Severity**: Warning
- **Location**: `lib/src/xml/utils/name.dart:86-95`, `lib/src/xml_events/annotations/has_name.dart:14-23`
- **Problem**: `XmlName` stores only `qualified` and `namespaceUri`. Every access to `.local` or `.prefix` executes `qualified.indexOf(':')` and `qualified.substring(...)`, allocating a new substring on the heap. Because `.local`, `.prefix`, `==`, and `hashCode` are called inside tight loops during `findElements`, `getAttribute`, XPath `QualifiedNameTest`, and `AttributeAxis`, this causes heavy string allocation churn. The same repeated `indexOf(':')` + `substring` pattern exists in `XmlHasName` (`lib/src/xml_events/annotations/has_name.dart:14-23`).
- **Fix**: Store the colon offset (or `local` and `prefix` fields directly) on `XmlName`, or pre-split `prefix` and `local` in `XmlName.qualified` and `XmlName.parts`.

### PERF-2: `XPathMap.get` Performs an $O(N)$ Linear Scan on Every Lookup
- **Severity**: Warning
- **Location**: `lib/src/xpath/xdm/functions/map.dart:39-44`, `lib/src/xpath/functions/map.dart:80-86`
- **Problem**: `XPathMap.get` iterates through all `entries.entries` with `sameKey(entry.key, key)` on every map lookup ($O(N)$), and `fnMapRemove` copies the map and runs `entries.removeWhere` for each key ($O(N \cdot M)$).
- **Fix**: Once `XPathAtomic` implements a consistent `hashCode` matching `XPathMap.sameKey` (or by using `HashMap<XPathAtomic, XPathSequence>(equals: XPathMap.sameKey, hashCode: XPathMap.keyHashCode)`), replace the linear loop in `XPathMap.get` with $O(1)$ hash table lookup.

### PERF-3: `XmlPrettyWriter.normalizeAttributes` Copies Attribute List Even When `sortAttributes == null`
- **Severity**: Warning
- **Location**: `lib/src/xml/visitors/pretty_writer.dart:157-164`
- **Problem**: `normalizeAttributes` executes `final result = attributes.toList();` on every element encounter, even when neither `sortAttributes` nor custom attribute indenting is requested. For large documents with thousands of elements, this creates unnecessary intermediate list allocations.
- **Fix**: Only call `attributes.toList()` when `sortAttributes != null`; otherwise iterate `attributes` directly.

### PERF-4: `XmlNodesExtension.nodes` and `XmlFollowingIterator` Create Unnecessary Intermediate Lists
- **Severity**: Warning
- **Location**: `lib/src/xml/extensions/nodes.dart:15-16`, `lib/src/xml/navigation/following.dart:18-20`
- **Problem**:
  1. `XmlNodesExtension.nodes` executes `[this, ...descendants]`, allocating a full `List<XmlNode>` copying every descendant node instead of returning an `Iterable<XmlNode>` via `sync*` or lazy chaining (`Iterable.concat`).
  2. `XmlFollowingIterator` initializes its stack with `[parent]`, allocating single-element lists during traversal steps.
- **Fix**: Return `Iterable<XmlNode>` lazily from `XmlNodesExtension.nodes` (e.g. `sync* { yield this; yield* descendants; }`), and optimize stack management in `XmlFollowingIterator`.

### PERF-5: `XPathContext.copy` Unconditionally Chains `parentContext` Even When No Local Variables Are Added
- **Severity**: Warning
- **Location**: `lib/src/xpath/evaluation/context.dart:140-154`
- **Problem**: `XPathContext.copy` always constructs a new `XPathContext` with `parentContext: this`, even when only `item`, `position`, or `last` changes (without new variable bindings). Long iterative evaluations (e.g. in `for` expressions, `some`/`every`, path steps, or large sequences) construct deep linked chains of `XPathContext` instances that make variable lookups traverse an $O(N)$ chain of ancestor contexts.
- **Fix**: If `variables` is null or empty, reuse the current context's variable map (or flatten parent contexts) rather than creating a deeper `parentContext` chain.

### PERF-6: `fn:innermost` and `fn:outermost` Perform $O(N^2 \cdot D)$ Ancestor Scans
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/sequence.dart:564-585`
- **Problem**: `fnInnermost` and `fnOutermost` evaluate `nodes.where((node) => !nodes.any((other) => other != node && other.descendants.contains(node)))`. For $N$ nodes each with $D$ descendants, this performs $O(N^2 \cdot D)$ identity comparisons and full subtree traversals.
- **Fix**: Collect all node identities into a `Set<XmlNode>`, sort nodes in document order (which is already done by `_sortAndDeduplicate`), and determine containment by checking whether `node.ancestors` intersects the set in $O(N \cdot D_{\text{depth}})$.

### PERF-7: `fn:index-of` Allocates Intermediate `atomize()` List and Boxing
- **Severity**: Warning
- **Location**: `lib/src/xpath/functions/sequence.dart:318-348`
- **Problem**: `_evalIndexOf` calls `seq.atomize().toList()`, materializing the entire atomized sequence into a heap list before scanning, even if searching for the first element in a massive sequence.
- **Fix**: Iterate `seq.atomize()` lazily with an integer counter, yielding matches on the fly into the resulting sequence without intermediate list buffering.

---

## 3. Code Style and Readability

### STYLE-1: Public Library Exports Inside `lib/src/xpath/xdm/atomic.dart` Violate Project Architecture Rules
- **Severity**: Warning
- **Location**: `lib/src/xpath/xdm/atomic.dart:3-13`
- **Problem**: `lib/src/xpath/xdm/atomic.dart` contains 10 `export '...';` directives. Per the project development charter: *"Exports are only allowed in `lib/*.dart`, and never in any files in `lib/src/...`."*
- **Fix**: Remove the barrel exports from `lib/src/xpath/xdm/atomic.dart` and export individual atomic types directly from `lib/xpath.dart`, using direct relative imports across internal `lib/src/xpath/` files.

### STYLE-2: Internal Source Files Import the Root Barrel File `package:xml/xml.dart`
- **Severity**: Warning
- **Location**: `lib/src/xml/nodes/document.dart:6`, `lib/src/xml/nodes/document_fragment.dart:6`, `lib/src/xml/builder/node.dart:3`
- **Problem**: `document.dart`, `document_fragment.dart`, and `builder/node.dart` import `package:xml/xml.dart` directly rather than using relative imports to internal source declarations. This violates the charter (*"Within `lib/`, prefer relative imports over package imports"*), causes circular import dependencies between root barrel files and `src/`, and masks private dependency boundaries.
- **Fix**: Replace `import 'package:xml/xml.dart';` in those files with relative imports (e.g. `import '../builder.dart';`, `import '../entities/entity_mapping.dart';`).

### STYLE-3: Monolithic Repetitive Arithmetic Operator Implementations in `lib/src/xpath/operators/numeric.dart`
- **Severity**: Warning
- **Location**: `lib/src/xpath/operators/numeric.dart:38-74`, `lib/src/xpath/operators/numeric.dart:100-136`, `lib/src/xpath/operators/numeric.dart:160-196`, `lib/src/xpath/operators/numeric.dart:220-256`, `lib/src/xpath/operators/numeric.dart:280-316`
- **Problem**: `opAdd`, `opSubtract`, `opMultiply`, `opDivide`, and `opIntegerDivide` each contain an identical 35-line `switch ((left, right))` pattern matching matrix across `(XPathInteger, XPathInteger)`, `(XPathDecimal, XPathDecimal)`, `(XPathDouble, XPathDouble)`, and their cross-type conversions.
- **Fix**: Extract a unified binary numeric dispatcher helper `_applyNumericOp(XPathNumeric a, XPathNumeric b, ...)` or use type promotion methods on `XPathNumeric` to collapse 150+ lines of duplicated matrix boilerplate into a single DRY structure.

### STYLE-4: `XmlBuilder` Redundant Constructor Signatures
- **Severity**: Warning
- **Location**: `lib/src/xml/builder.dart:65-103`
- **Problem**: `XmlBuilder` defines two factory constructors `XmlBuilder()` and `XmlBuilder.optimized()` with overlapping default parameters (`optimizeNamespaces = false` vs `= true`), leading to cognitive overhead and duplication.
- **Fix**: Provide a single primary constructor with `bool optimizeNamespaces = false` or consolidate initialization defaults.

### STYLE-5: Dead Parser Grammar Production `qualifiedNameToken` in `XmlEventParser`
- **Severity**: Warning
- **Location**: `lib/src/xml_events/parser.dart:109-110`, `lib/src/xml_events/parser.dart:266-271`
- **Problem**: `XmlEventParser` defines `Parser<String> qualifiedNameToken()` which is completely unused inside `XmlEventParser` (all element and attribute parsers call `nameToken()` instead).
- **Fix**: Remove `qualifiedNameToken()` from `XmlEventParser` or migrate external consumers to a dedicated lexical utility.

---

## 4. Missing or Broken Documentation

### DOC-1: Missing Documentation on `xpathGenerate`
- **Severity**: Warning
- **Location**: `lib/src/xpath/generator.dart:11-37`
- **Problem**: `XPathGenerator.xpathGenerate` has minimal documentation and does not document the format of generated expressions, the role of `byId`, or how namespaces and predicate indices are represented.
- **Fix**: Add triple-slash documentation with parameter explanations and example outputs for attributes, elements, and fragments.

### DOC-2: Undocumented Public Classes and Members in DTD and Declarations
- **Severity**: Warning
- **Location**:
  - `lib/src/xml/dtd/external_id.dart:4-38` (`DtdExternalId`, `DtdSystemId`, `DtdPublicId`)
  - `lib/src/xml/nodes/doctype.dart:21-43` (`intId`, `dtdElements`)
  - `lib/src/xml/nodes/declaration.dart:18-35` (`version`, `encoding`, `standalone`)
- **Problem**: DTD external IDs and properties on `XmlDeclaration` and `XmlDoctype` lack doc comments and code examples explaining how to inspect doctype declarations.
- **Fix**: Add comprehensive doc comments with XML code examples to `DtdExternalId`, `XmlDeclaration`, and `XmlDoctype`.

### DOC-3: Incomplete Doc Comments on `XmlEvents` Streaming Converters
- **Severity**: Warning
- **Location**: `lib/src/xml_events/converters/event_decoder.dart:40-75`, `lib/src/xml_events/iterable.dart:10-25`
- **Problem**: `XmlEventDecoder` documentation does not explain that `validateDocument: false` allows parsing fragments or streams of arbitrary XML elements, nor does it document what exceptions (`XmlParserException`, `XmlTagException`, `XmlNamespaceException`) are thrown when validation fails.
- **Fix**: Document validation flags, error behavior, and chunked processing guidelines in `XmlEventDecoder` and `parseEvents`.

### DOC-4: Undocumented Public XDM Members in `lib/xpath.dart`
- **Severity**: Warning
- **Location**:
  - `lib/src/xpath/evaluation/context.dart:9-40` (`XPathContext`)
  - `lib/src/xpath/xdm/functions/array.dart:11-36` (`XPathArray`, `XPathArrayType`)
  - `lib/src/xpath/xdm/functions/function.dart:7-16` (`XPathFunctionCallback`, `XPathFunctionType`)
  - `lib/src/xpath/xdm/functions/map.dart:10-46` (`XPathMap`, `XPathMapType`)
- **Problem**: Public XDM item classes exported from `lib/xpath.dart` have undocumented constructors, fields, and methods, and `XPathContext.configuration` has a spelling typo (`Configuraiton`).
- **Fix**: Fix the typo in `context.dart:24` and add `///` doc comments to all public members of exported XDM classes.

---

## 5. Simplicity and Cleanness of Public APIs

### API-1: Inline Callback/Predicate Typedefs and Export Essential Domain Types (`DtdExternalId`, `XPathContext`)
- **Severity**: Warning
- **Location**: `lib/xml.dart:1-51`, `lib/xpath.dart:1-22`, `lib/src/xml/utils/predicate.dart:4`, `lib/src/xml/builder/builder.dart:481-482`
- **Problem**:
  1. `DtdExternalId` (`lib/src/xml/dtd/external_id.dart:4`) is the type of `XmlDoctype.externalId` and a constructor parameter of `XmlDoctype(...)`, and `XPathContext` (`lib/src/xpath/evaluation/context.dart:9`) is returned by `XPathConfiguration.context()` and passed to custom `XPathFunctionCallback`s, yet neither is exported from `lib/xml.dart` or `lib/xpath.dart`.
  2. `Predicate<T>` (`lib/src/xml/utils/predicate.dart:4`), `Callback`, and `CallbackWithBuilder` (`lib/src/xml/builder/builder.dart:481-482`) are unnecessary typedef aliases for standard Dart function types (`bool Function(T)`, `void Function()`, `void Function(XmlBuilder)`), creating unneeded indirection in public signatures.
- **Fix**:
  - Export `src/xml/dtd/external_id.dart` (`DtdExternalId`) in `lib/xml.dart` (and `lib/xml_events.dart`).
  - Export `src/xpath/evaluation/context.dart` (`XPathContext`) in `lib/xpath.dart`.
  - Inline `void Function()` (replacing `Callback`), `void Function(XmlBuilder builder)` (replacing `CallbackWithBuilder`), and `bool Function(T value)` (replacing `Predicate<T>`) directly into method and constructor signatures across `lib/src/xml/builder/`, `lib/src/xml/visitors/`, `lib/src/xml/nodes/`, and `lib/src/xml_events/streams/subtree_selector.dart`, deprecating the typedefs.

---

## 6. Missing Features

*(Note on previous FEAT-4 `XmlStreamWriter`: Withdrawn; `XmlEventEncoder` in `lib/src/xml_events/converters/event_encoder.dart` and `Stream<List<XmlEvent>>.toXmlString()` already provide streaming chunked encoding directly from XML event streams to `Sink<String>`.)*

### FEAT-1: `XmlStartElementEvent` Attribute Accessors (`STR-6`)
- **Severity**: Feature
- **Location**: `lib/src/xml_events/events/start_element.dart:10-63`
- **Problem**: `XmlStartElementEvent` only exposes `List<XmlEventAttribute> attributes`. Filtering event streams (e.g. inside `selectSubtreeEvents`) requires verbose manual iteration over `event.attributes`.
- **Fix**: Add `getAttribute(String name, {String? namespaceUri})`, `getAttributeNode(String name, {String? namespaceUri})`, and `hasAttribute(String name, {String? namespaceUri})` helper methods/extensions on `XmlStartElementEvent`.

### FEAT-2: Standard Namespace Resolution Helpers (`lookupPrefix` / `lookupNamespaceUri`) (`DOM-7`)
- **Severity**: Feature
- **Location**: `lib/src/xml/mixins/has_namespaces.dart:10-40`
- **Problem**: `XmlHasNamespaces` only exposes `Iterable<XmlNamespace> get namespaces`. Callers and internal XPath functions repeatedly write `.namespaces.where((ns) => ns.prefix == prefix).firstOrNull?.uri`.
- **Fix**: Add `String? lookupPrefix(String namespaceUri)` and `String? lookupNamespaceUri(String? prefix)` on `XmlHasNamespaces`.

### FEAT-3: Respect `xml:space="preserve"` Automatically in `XmlPrettyWriter` (`STD-3`)
- **Severity**: Feature
- **Location**: `lib/src/xml/visitors/pretty_writer.dart:46-99`
- **Problem**: `XmlPrettyWriter` ignores standard `xml:space="preserve"` attributes unless a custom `preserveWhitespace` predicate is manually supplied by the caller.
- **Fix**: Check `xml:space` on elements during `XmlPrettyWriter.visitElement` and automatically preserve whitespace inside subtrees with `xml:space="preserve"` unless overridden by `xml:space="default"`.

### FEAT-4: Byte-Stream Decoding & BOM / Encoding Detection (`ENC-1`)
- **Severity**: Feature
- **Location**: `lib/xml_events.dart`, `lib/src/xml_events/converters/`
- **Problem**: `XmlEventDecoder` only accepts `Stream<String>`. Parsing `Stream<List<int>>` with `utf8.decoder` fails to strip UTF-8/UTF-16/UTF-32 Byte Order Marks (BOM) or sniff the `<?xml ... encoding="..."?>` declaration per W3C XML 1.0 Appendix F.
- **Fix**: Add `XmlByteStreamDecoder` (`StreamTransformerBase<List<int>, String>`) and `Stream<List<int>>.decodeXmlStream(...)` that strips BOMs and resolves the declared encoding.

### FEAT-5: DOM Sibling & Structural Mutation Helpers (`before`, `after`, `wrap`, `unwrap`, `prepend`) (`DOM-1`)
- **Severity**: Feature
- **Location**: `lib/src/xml/extensions/mutator.dart:8-60`
- **Problem**: `XmlMutatorExtension` only provides `remove()` and `replace(XmlNode other)`. Inserting siblings or wrapping/unwrapping elements requires manual index arithmetic on `node.parent!.children`.
- **Fix**: Add `before(XmlNode node)`, `after(XmlNode node)`, `wrap(XmlElement wrapper)`, `unwrap()` on `XmlNode` and `prepend(XmlNode node)` on `XmlElement` in `lib/src/xml/extensions/mutator.dart`.

### FEAT-6: Fast Document ID Lookup (`XmlDocument.getElementById`) (`DOM-2`)
- **Severity**: Feature
- **Location**: `lib/src/xml/nodes/document.dart:16-148`, `lib/src/xpath/functions/node.dart:191-208`
- **Problem**: XPath implements `fn:id` with DTD `ID` and `xml:id` resolution in `lib/src/xpath/functions/node.dart`, but `XmlDocument` in core `package:xml` lacks a `getElementById(String id)` helper.
- **Fix**: Add `XmlElement? getElementById(String id)` on `XmlDocument` (sharing the DTD `ID` / `xml:id` / `id` matching logic with `lib/src/xpath/functions/node.dart`).

### FEAT-7: `XmlBuilder` Namespace Auto-Declaration (`DOM-5`)
- **Severity**: Feature
- **Location**: `lib/src/xml/builder/builder.dart:410-445`
- **Problem**: Passing an undeclared `namespaceUri` to `XmlBuilder.element` or `XmlBuilder.attribute` without a separate `namespace(uri, prefix)` call throws `ArgumentError('Undefined namespace: $uri')`.
- **Fix**: Allow `XmlBuilder` to automatically declare `xmlns="..."` or a generated prefix on the current element when an undeclared `namespaceUri` is provided.

### FEAT-8: Strict XML 1.0 Attribute Uniqueness Validation (`validateAttributes`) (`STD-1`)
- **Severity**: Feature
- **Location**: `lib/src/xml_events/annotations/annotator.dart:24-118`, `lib/src/xml/nodes/document.dart:36-74`
- **Problem**: Duplicate attributes on the same element (e.g. `<user role="guest" role="admin"/>`) are accepted by default, which can enable XML attribute smuggling when downstream systems read a different occurrence than `getAttribute`.
- **Fix**: Add `validateAttributes: bool = false` to `XmlAnnotator`, `XmlEventDecoder`, `parseEvents`, and `XmlDocument.parse` to reject duplicate qualified or expanded `(namespaceUri, localName)` attributes with `XmlParserException` / `XmlTagException`.

### FEAT-9: Namespace Prefix Repairing in `XmlWriter` (`SER-2`)
- **Severity**: Feature
- **Location**: `lib/src/xml/visitors/writer.dart:92-125`
- **Problem**: Programmatically constructed `XmlElement`s or `XmlAttribute`s with `XmlName.parts(local, prefix: ..., namespaceUri: ...)` that lack a corresponding `xmlns:prefix="uri"` attribute serialize without the namespace declaration, producing namespace-ill-formed XML.
- **Fix**: Add an optional `repairNamespaces: bool = false` flag to `XmlWriter` / `toXmlString` that tracks in-scope namespace declarations during serialization and emits missing `xmlns` attributes automatically.

---

## 7. Large Files, Complex Structure, Distributed Responsibility, and Dead Code

### ARCH-1: Dead Code in `XmlEventParser` (`qualifiedNameToken`) and Misplaced Grammar Dependency
- **Severity**: Warning
- **Location**: `lib/src/xml_events/parser.dart:266-284`, `lib/src/xpath/xdm/atomic/qname.dart:44-46`, `lib/src/xpath/grammars/xpath.dart:1084-1085`, `lib/src/xpath/grammars/xpath.dart:1154`
- **Problem**: `XmlEventParser.qualifiedNameToken` (`lib/src/xml_events/parser.dart:266`) is never called by `XmlEventParser` (which uses `nameToken` instead). `XmlEventParser.nonColonizedNameToken` and `qualifiedNameToken` only exist in `XmlEventParser` because `lib/src/xpath/grammars/xpath.dart:1154` and `lib/src/xpath/xdm/atomic/qname.dart:44` instantiate `const XmlEventParser(XmlNullEntityMapping())` just to call `nonColonizedNameToken()` and `qualifiedNameToken()`.
- **Fix**: Move `qualifiedNameToken`, `nonColonizedNameToken`, `nonColonizedStartChar`, and `nonColonizedChar` out of `XmlEventParser` into a dedicated lexical name parser utility (or `lib/src/xml/utils/character_data_parser.dart` / `name.dart`) so XPath does not need to instantiate `XmlEventParser`.

### ARCH-2: Duplicated `childrenNodeTypes` and `attributeNodeTypes` Constants Across DOM Node Files
- **Severity**: Warning
- **Location**: `lib/src/xml/nodes/declaration.dart:61`, `lib/src/xml/nodes/document.dart:150-155`, `lib/src/xml/nodes/document_fragment.dart:91-99`, `lib/src/xml/nodes/element.dart:152-162`
- **Problem**: `childrenNodeTypes` and `attributeNodeTypes` (`Set<XmlNodeType>`) are redefined separately at the bottom of `declaration.dart`, `document.dart`, `document_fragment.dart`, and `element.dart` with overlapping definitions.
- **Fix**: Consolidate the allowed child/attribute `Set<XmlNodeType>` constants in `lib/src/xml/enums/node_type.dart` or `lib/src/xml/mixins/has_children.dart` and `lib/src/xml/mixins/has_attributes.dart`.

### ARCH-3: Oversized Monolithic XPath Files (`json.dart`, `xpath.dart`, `serialization.dart`, `regex.dart`, `numeric.dart`, `date_time.dart`)
- **Severity**: Warning
- **Location**:
  - `lib/src/xpath/functions/json.dart:1-1883` (1,883 lines)
  - `lib/src/xpath/grammars/xpath.dart:1-1185` (1,185 lines)
  - `lib/src/xpath/functions/serialization.dart:1-985` (985 lines)
  - `lib/src/xpath/functions/regex.dart:1-910` (910 lines)
  - `lib/src/xpath/xdm/atomic/numeric.dart:1-793` (793 lines)
  - `lib/src/xpath/xdm/atomic/date_time.dart:1-769` (769 lines)
- **Problem**: Several files in `lib/src/xpath/` combine multiple distinct responsibilities into single 800–1,900 line files:
  - `lib/src/xpath/functions/json.dart` (1,883 lines) contains XPath function definitions, option parsing, a 930-line custom recursive-descent JSON parser (`_JsonParser`), and a 510-line XML-to-JSON serializer (`_XmlToJsonSerializer`), plus its own `_escapeJsonString` that duplicates `_escapeJsonString` in `serialization.dart:925-964`.
  - `lib/src/xpath/functions/serialization.dart` (985 lines) mixes `SerializationParameters` parsing (from both `XPathMap` and `XmlElement`) with 6 distinct output serializers (`xml`, `html`, `xhtml`, `text`, `json`, `adaptive`).
  - `lib/src/xpath/functions/regex.dart` (910 lines) bundles Unicode block tables, two separate PetitParser grammars (`_XPathRegexGroupGrammar` and `XPathRegexTransformGrammar`), backreference validation, `fn:replace` template parsing, and `fn:analyze-string` XML construction.
  - `lib/src/xpath/xdm/atomic/numeric.dart` (793 lines) combines `XPathNumeric`, `XPathInteger`, `XPathDecimal`, `XPathDouble`, and `roundToFloat` in a single file.
- **Fix**:
  - Split `lib/src/xpath/functions/json.dart` into `json.dart` (functions & options), `json_parser.dart` (`_JsonParser`), and `json_serializer.dart` (`_XmlToJsonSerializer`), sharing JSON string escaping with `serialization.dart`.
  - Split `lib/src/xpath/functions/serialization.dart` into `serialization_parameters.dart` and `serialization_writers.dart`.
  - Split `lib/src/xpath/functions/regex.dart` into regex translation grammar vs. `fn:replace` / `fn:analyze-string` evaluation.
  - Split `lib/src/xpath/xdm/atomic/numeric.dart` into `numeric.dart`, `integer.dart`, `decimal.dart`, and `double.dart` (or keep internal parts modular).

### ARCH-4: Distributed QName / EQName Parsing and Validation Logic
- **Severity**: Warning
- **Location**: `lib/src/xml/utils/name.dart:51-72`, `lib/src/xml_events/annotations/has_name.dart:14-23`, `lib/src/xpath/xdm/atomic/qname.dart:44-67`, `lib/src/xpath/functions/qname.dart:112-184`, `lib/src/xpath/grammars/xpath.dart:1142-1185`
- **Problem**: Splitting qualified names (`prefix:local`), parsing `Q{uri}local` EQNames, and validating `NCName`s are re-implemented in five separate places with subtly different behaviors (e.g. `XmlName.parse` supports `Q{uri}local` and looks up `namespaceUris`, `_eqNameToNodeTest` in `xpath.dart` manually slices `Q{...}`, `fnQName` manually splits on `':'` and calls `isValidNCName`, and `XmlHasName` manually calls `indexOf(':')`).
- **Fix**: Centralize `NCName` validation, `Q{uri}local` EQName parsing, and `prefix:local` splitting in `XmlName` (or a shared internal `qname_utils.dart` helper) and reuse it across `xml`, `xml_events`, and `xpath`.

---

## 8. Future Work and Later Consideration

### FUT-1: `fn:format-integer`, `fn:format-number`, and `fn:format-dateTime`/`Date`/`Time` Picture String Support
- **Severity**: Feature
- **Location**: `lib/src/xpath/functions/sequence.dart:106-173`, `lib/src/xpath/functions/date_time.dart:289-377`
- **Problem**: `fnFormatInteger`, `fnFormatNumber`, `fnFormatDateTime`, `fnFormatDate`, and `fnFormatTime` ignore their `$picture` argument completely and simply return `val.stringValue`.
- **Fix**: Implement W3C XPath 3.1 picture string formatting for numbers (`fn:format-integer`, `fn:format-number`) and dates/times (`fn:format-dateTime`, `fn:format-date`, `fn:format-time`).

### FUT-2: Streaming Event Pretty-Printing (`XmlEventEncoder(pretty: true)`) (`STR-4`)
- **Severity**: Feature
- **Location**: `lib/src/xml_events/converters/event_encoder.dart:19-60`
- **Problem**: `XmlEventEncoder` only emits compact unindented XML. Formatting an XML event stream currently requires materializing DOM nodes first.
- **Fix**: Add `pretty`, `indent`, and `newLine` options to `XmlEventEncoder` and `XmlEventEncoderExtension.toXmlString`.

### FUT-3: Source Position Preservation on DOM Nodes (`DOM-6`)
- **Severity**: Feature
- **Location**: `lib/src/xml/nodes/node.dart:10-40`, `lib/src/xml_events/converters/node_decoder.dart:64-156`
- **Problem**: `XmlEvent` tracks source offsets via `XmlHasLocation` (`start`, `stop`), but `XmlNodeDecoder` discards these locations when constructing `XmlNode`s.
- **Fix**: Optionally attach source `(start, stop)` offsets from `XmlEvent`s onto `XmlNode`s (via an `Expando` or `XmlHasLocation`) and expose a `lineAndColumn(String source)` helper using `Token.lineAndColumnOf`.

### FUT-4: Canonical XML Serialization (C14N 1.0 / 1.1 & Exclusive C14N) (`STD-2`)
- **Severity**: Feature
- **Location**: `lib/src/xml/visitors/`
- **Problem**: There is no Canonical XML (W3C C14N) visitor for generating canonical byte streams required by XML Digital Signatures (XML-DSig) and SAML 2.0.
- **Fix**: Implement `XmlCanonicalWriter` supporting C14N 1.0, C14N 1.1, and Exclusive C14N (codepoint-ordered attributes and namespaces, expanded `<tag></tag>` empty elements, normalized `\n` line endings, and attribute value normalization).
