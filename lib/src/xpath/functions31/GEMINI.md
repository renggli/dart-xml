# XPath Functions

This module implements the XPath 3.1 functions as defined in [XPath Functions and Operators 3.1](https://www.w3.org/TR/xpath-functions-31/).

## Instructions on how to implement functions

1. **Naming Convention**:
    * Reference the W3C spec URL in the method comment.
    * Dart function names should use `camelCase`, i.e. `fnFunctionName` for `fn:function-name`.
2. **Function Signature**:
    * All functions must return `XPathSequence`.
    * The first argument is always `XPathContext context`.
    * The second argument is always `List<XPathSequence> arguments`.
    * For example: `XPathSequence fnFunctionName(XPathContext context, List<XPathSequence> arguments)`.
3. **Argument Extraction**:
    * The first line of each function must call `XPathEvaluationException.checkArgumentCount('fn:function-name', arguments, min, max)` to verify the number of arguments.
      * `min` is referring to the minimum number of arguments required.
      * `max` is referring to the maximum number of arguments supported:
        * If left out, this means the function expects exactly `min` arguments.
        * If `unbounded`, this means the function expects at least `min` arguments.
    * Extract, validate and convert each argument to a final variable using a single Dart statement. Name the variable after the argument name used in the standard.
      * If the argument is missing, assign a default value. Check the presence with `i < arguments.length`.
      * If the argument is present ...
        * First check the cardinality of the `XPathSequence` argument:
          * If the argument is of exactly-one cardinality (`1`) use `XPathEvaluationException.extractExactlyOne('fn:function-name', 'argumentName', arguments[i])`. This function returns a single value that can be directly used.
          * If the argument is of zero-or-one cardinality (`?`) use `XPathEvaluationException.extractZeroOrOne('fn:function-name', 'argumentName', arguments[i])`. This function returns a single value or `null`. Use the `?.` to convert and/or `??` to fall-back to a default value.
          * If the argument is of one-or-more cardinality (`+`) use `XPathEvaluationException.extractOneOrMore('fn:function-name', 'argumentName', arguments[i])`. This function returns `XPathSequence` that can be directly used.
          * If the argument is of zero-or-more cardinality (`*`) directly use `arguments[i]`.
        * If applicable, convert the argument to the desired type:
          * Use `.toXPathString()` to convert to a string.
          * Use `.toXPathNumber()` to convert to a number.
          * etc.
4. **Return Value**:
    * Return `XPathSequence.empty` for empty sequences.
    * Return `XPathSequence.single(value)` for single values.
    * Return `XPathSequence([item1, item2])` for sequences.
5. **Testing**:
    * Add tests to `test/xpath_31_functions_test.dart`.
    * Update the status list in `GEMINI.md` with `✅` and the file name when completed.

## Status of the current implementations

### Accessors

* `fn:node-name` ✅ in [accessor.dart]
* `fn:nilled` ✅ in [accessor.dart]
* `fn:string` ✅ in [accessor.dart]
* `fn:data` ✅ in [accessor.dart]
* `fn:base-uri` ✅ in [accessor.dart]
* `fn:document-uri` ✅ in [accessor.dart]

### Errors and diagnostics

* `fn:error` ✅ in [error.dart]
* `fn:trace` ✅ in [error.dart]

### Functions and operators on numerics

#### Arithmetic operators on numeric values

* `op:numeric-add` ✅ in [number.dart]
* `op:numeric-subtract` ✅ in [number.dart]
* `op:numeric-multiply` ✅ in [number.dart]
* `op:numeric-divide` ✅ in [number.dart]
* `op:numeric-integer-divide` ✅ in [number.dart]
* `op:numeric-mod` ✅ in [number.dart]
* `op:numeric-unary-plus` ✅ in [number.dart]
* `op:numeric-unary-minus` ✅ in [number.dart]

#### Comparison operators on numeric values

* `op:numeric-equal` ✅ in [number.dart]
* `op:numeric-less-than` ✅ in [number.dart]
* `op:numeric-greater-than` ✅ in [number.dart]

#### Functions on numeric values

* `fn:abs` ✅ in [number.dart]
* `fn:ceiling` ✅ in [number.dart]
* `fn:floor` ✅ in [number.dart]
* `fn:round` ✅ in [number.dart]
* `fn:round-half-to-even` ✅ in [number.dart]

#### Parsing numbers

* `fn:number` ✅ in [number.dart]

#### Formatting integers

* `fn:format-integer` ✅ in [number.dart]

#### Formatting numbers

* `fn:format-number` ✅ in [number.dart]

#### Trigonometric and exponential functions

* `math:pi` ✅ in [number.dart]
* `math:exp` ✅ in [number.dart]
* `math:exp10` ✅ in [number.dart]
* `math:log` ✅ in [number.dart]
* `math:log10` ✅ in [number.dart]
* `math:pow` ✅ in [number.dart]
* `math:sqrt` ✅ in [number.dart]
* `math:sin` ✅ in [number.dart]
* `math:cos` ✅ in [number.dart]
* `math:tan` ✅ in [number.dart]
* `math:asin` ✅ in [number.dart]
* `math:acos` ✅ in [number.dart]
* `math:atan` ✅ in [number.dart]
* `math:atan2` ✅ in [number.dart]

#### Random Numbers

* `fn:random-number-generator` ✅ in [number.dart]

### Functions on strings

#### Functions to assemble and disassemble strings

* `fn:codepoints-to-string`
* `fn:string-to-codepoints`

#### Comparison of strings

* `fn:compare`
* `fn:codepoint-equal`
* `fn:collation-key` ✅ in [string.dart]
* `fn:contains-token`

#### Functions on string values

* `fn:concat` ✅ in [string.dart]
* `fn:string-join` ✅ in [string.dart]
* `fn:substring` ✅ in [string.dart]
* `fn:string-length` ✅ in [string.dart]
* `fn:normalize-space` ✅ in [string.dart]
* `fn:normalize-unicode` ✅ in [string.dart]
* `fn:upper-case` ✅ in [string.dart]
* `fn:lower-case` ✅ in [string.dart]
* `fn:translate` ✅ in [string.dart]

#### Functions based on substring matching

* `fn:contains` ✅ in [string.dart]
* `fn:starts-with` ✅ in [string.dart]
* `fn:ends-with` ✅ in [string.dart]
* `fn:substring-before` ✅ in [string.dart]
* `fn:substring-after` ✅ in [string.dart]

#### String functions that use regular expressions

* `fn:matches` ✅ in [string.dart]
* `fn:replace` ✅ in [string.dart]
* `fn:tokenize` ✅ in [string.dart]
* `fn:analyze-string` ✅
* `fn:codepoints-to-string` ✅ in [string.dart]
* `fn:string-to-codepoints` ✅ in [string.dart]
* `fn:compare` ✅ in [string.dart]
* `fn:codepoint-equal` ✅ in [string.dart]
* `fn:contains-token` ✅ in [string.dart]

### Functions that manipulate URIs

* `fn:resolve-uri` ✅ in [uri.dart]
* `fn:encode-for-uri` ✅ in [uri.dart]
* `fn:iri-to-uri` ✅ in [uri.dart]
* `fn:escape-html-uri` ✅ in [uri.dart]

### Functions and operators on Boolean values

#### Boolean constant functions

* `fn:true` ✅ in [boolean.dart]
* `fn:false` ✅ in [boolean.dart]

#### Operators on Boolean values

* `op:boolean-equal`
* `op:boolean-less-than`
* `op:boolean-greater-than`

#### Functions on Boolean values

* `fn:boolean` ✅ in [boolean.dart]
* `fn:not` ✅ in [boolean.dart]

### Functions and operators on durations

#### Comparison operators on durations

* `op:yearMonthDuration-less-than` ✅ in [duration.dart]
* `op:yearMonthDuration-greater-than` ✅ in [duration.dart]
* `op:dayTimeDuration-less-than` ✅ in [duration.dart]
* `op:dayTimeDuration-greater-than` ✅ in [duration.dart]
* `op:duration-equal` ✅ in [duration.dart]

#### Component extraction functions on durations

* `fn:years-from-duration` ✅ in [duration.dart]
* `fn:months-from-duration` ✅ in [duration.dart]
* `fn:days-from-duration` ✅ in [duration.dart]
* `fn:hours-from-duration` ✅ in [duration.dart]
* `fn:minutes-from-duration` ✅ in [duration.dart]
* `fn:seconds-from-duration` ✅ in [duration.dart]

#### Arithmetic operators on durations

* `op:add-yearMonthDurations` ✅ in [duration.dart]
* `op:subtract-yearMonthDurations` ✅ in [duration.dart]
* `op:multiply-yearMonthDuration` ✅ in [duration.dart]
* `op:divide-yearMonthDuration` ✅ in [duration.dart]
* `op:divide-yearMonthDuration-by-yearMonthDuration` ✅ in [duration.dart]
* `op:add-dayTimeDurations` ✅ in [duration.dart]
* `op:subtract-dayTimeDurations` ✅ in [duration.dart]
* `op:multiply-dayTimeDuration` ✅ in [duration.dart]
* `op:divide-dayTimeDuration` ✅ in [duration.dart]
* `op:divide-dayTimeDuration-by-dayTimeDuration` ✅ in [duration.dart]

### Functions and operators on dates and times

#### Constructing a dateTime

* `fn:dateTime` ✅ in [date_time.dart]

#### Comparison operators on duration, date and time values

* `op:dateTime-equal` ✅ in [date_time.dart]
* `op:dateTime-less-than` ✅ in [date_time.dart]
* `op:dateTime-greater-than` ✅ in [date_time.dart]
* `op:date-equal` ✅ in [date_time.dart]
* `op:date-less-than` ✅ in [date_time.dart]
* `op:date-greater-than` ✅ in [date_time.dart]
* `op:time-equal` ✅ in [date_time.dart]
* `op:time-less-than` ✅ in [date_time.dart]
* `op:time-greater-than` ✅ in [date_time.dart]
* `op:gYearMonth-equal`
* `op:gYear-equal`
* `op:gMonthDay-equal`
* `op:gMonth-equal`
* `op:gDay-equal`

#### Component extraction functions on dates and times

* `fn:year-from-dateTime` ✅ in [date_time.dart]
* `fn:month-from-dateTime` ✅ in [date_time.dart]
* `fn:day-from-dateTime` ✅ in [date_time.dart]
* `fn:hours-from-dateTime` ✅ in [date_time.dart]
* `fn:minutes-from-dateTime` ✅ in [date_time.dart]
* `fn:seconds-from-dateTime` ✅ in [date_time.dart]
* `fn:timezone-from-dateTime` ✅ in [date_time.dart]
* `fn:year-from-date` ✅ in [date_time.dart]
* `fn:month-from-date` ✅ in [date_time.dart]
* `fn:day-from-date` ✅ in [date_time.dart]
* `fn:timezone-from-date` ✅ in [date_time.dart]
* `fn:hours-from-time` ✅ in [date_time.dart]
* `fn:minutes-from-time` ✅ in [date_time.dart]
* `fn:seconds-from-time` ✅ in [date_time.dart]
* `fn:timezone-from-time` ✅ in [date_time.dart]

#### Timezone adjustment functions on dates and time values

* `fn:adjust-dateTime-to-timezone` ✅ in [date_time.dart]
* `fn:adjust-date-to-timezone` ✅ in [date_time.dart]
* `fn:adjust-time-to-timezone` ✅ in [date_time.dart]

#### Arithmetic operators on durations, dates and times

* `op:subtract-dateTimes` ✅ in [date_time.dart]
* `op:subtract-dates` ✅ in [date_time.dart]
* `op:subtract-times` ✅ in [date_time.dart]
* `op:add-yearMonthDuration-to-dateTime` ✅ in [date_time.dart]
* `op:add-dayTimeDuration-to-dateTime` ✅ in [date_time.dart]
* `op:subtract-yearMonthDuration-from-dateTime` ✅ in [date_time.dart]
* `op:subtract-dayTimeDuration-from-dateTime` ✅ in [date_time.dart]
* `op:add-yearMonthDuration-to-date` ✅ in [date_time.dart]
* `op:add-dayTimeDuration-to-date` ✅ in [date_time.dart]
* `op:subtract-yearMonthDuration-from-date` ✅ in [date_time.dart]
* `op:subtract-dayTimeDuration-from-date` ✅ in [date_time.dart]
* `op:add-dayTimeDuration-to-time` ✅ in [date_time.dart]
* `op:subtract-dayTimeDuration-from-time` ✅ in [date_time.dart]

#### Formatting dates and times

* `fn:format-dateTime` ✅ in [date_time.dart]
* `fn:format-date` ✅ in [date_time.dart]
* `fn:format-time` ✅ in [date_time.dart]

#### Parsing dates and times

* `fn:parse-ietf-date` ✅ in [date_time.dart]

### Functions related to QNames

#### Functions to create a QName

* `fn:resolve-QName` ✅ in [qname.dart]
* `fn:QName` ✅ in [qname.dart]

#### Functions and operators related to QNames

* `op:QName-equal` ✅ in [qname.dart]
* `fn:prefix-from-QName` ✅ in [qname.dart]
* `fn:local-name-from-QName` ✅ in [qname.dart]
* `fn:namespace-uri-from-QName` ✅ in [qname.dart]
* `fn:namespace-uri-for-prefix` ✅ in [qname.dart]
* `fn:in-scope-prefixes` ✅ in [qname.dart]

### Operators on base64Binary and hexBinary

#### Comparisons of base64Binary and hexBinary values

* `op:hexBinary-equal` ✅ in [binary.dart]
* `op:hexBinary-less-than` ✅ in [binary.dart]
* `op:hexBinary-greater-than` ✅ in [binary.dart]
* `op:base64Binary-equal` ✅ in [binary.dart]
* `op:base64Binary-less-than` ✅ in [binary.dart]
* `op:base64Binary-greater-than` ✅ in [binary.dart]

### Operators on NOTATION

* `op:NOTATION-equal` ✅ in [notation.dart]

### Functions and operators on nodes

* `fn:name` ✅ in [node.dart]
* `fn:local-name` ✅ in [node.dart]
* `fn:namespace-uri` ✅ in [node.dart]
* `fn:lang` ✅ in [boolean.dart]
* `fn:root` ✅ in [node.dart]
* `fn:path` ✅ in [node.dart]
* `fn:has-children` ✅ in [node.dart]
* `fn:innermost` ✅ in [node.dart]
* `fn:outermost` ✅ in [node.dart]
* `op:union` ✅ in [node.dart]
* `op:intersect` ✅ in [node.dart]
* `op:except` ✅ in [node.dart]

### Functions and operators on sequences

#### General functions and operators on sequences

* `fn:empty` ✅ in [sequence.dart]
* `fn:exists` ✅ in [sequence.dart]
* `fn:head` ✅ in [sequence.dart]
* `fn:tail` ✅ in [sequence.dart]
* `fn:insert-before` ✅ in [sequence.dart]
* `fn:remove` ✅ in [sequence.dart]
* `fn:reverse` ✅ in [sequence.dart]
* `fn:subsequence` ✅ in [sequence.dart]
* `fn:unordered` ✅ in [sequence.dart]

#### Functions that compare values in sequences

* `fn:distinct-values` ✅ in [sequence.dart]
* `fn:index-of` ✅ in [sequence.dart]
* `fn:deep-equal` ✅ in [sequence.dart]

#### Functions that test the cardinality of sequences

* `fn:zero-or-one` ✅ in [sequence.dart]
* `fn:one-or-more` ✅ in [sequence.dart]
* `fn:exactly-one` ✅ in [sequence.dart]

#### Aggregate functions

* `fn:count` ✅ in [sequence.dart]
* `fn:avg` ✅ in [sequence.dart]
* `fn:max` ✅ in [sequence.dart]
* `fn:min` ✅ in [sequence.dart]
* `fn:sum` ✅ in [sequence.dart]

#### Functions on node identifiers

* `fn:id` ✅ in [sequence.dart]
* `fn:element-with-id` ✅ in [sequence.dart]
* `fn:idref` ✅ in [sequence.dart]
* `fn:generate-id` ✅ in [sequence.dart]

#### Functions giving access to external information

* `fn:doc` ✅ in [sequence.dart]
* `fn:doc-available` ✅ in [sequence.dart]
* `fn:collection` ✅ in [sequence.dart]
* `fn:uri-collection` ✅ in [sequence.dart]
* `fn:unparsed-text` ✅ in [sequence.dart]
* `fn:unparsed-text-lines` ✅ in [sequence.dart]
* `fn:unparsed-text-available` ✅ in [sequence.dart]
* `fn:environment-variable` ✅ in [sequence.dart]
* `fn:available-environment-variables` ✅ in [sequence.dart]

#### Parsing and serializing

* `fn:parse-xml` ✅ in [sequence.dart]
* `fn:parse-xml-fragment` ✅ in [sequence.dart]  
* `fn:serialize` ✅ in [sequence.dart]

### Context functions

* `fn:position` ✅ in [context.dart]
* `fn:last` ✅ in [context.dart]
* `fn:current-dateTime` ✅ in [context.dart]
* `fn:current-date` ✅ in [context.dart]
* `fn:current-time` ✅ in [context.dart]
* `fn:implicit-timezone` ✅ in [context.dart]
* `fn:default-collation` ✅ in [context.dart]
* `fn:default-language` ✅ in [context.dart]
* `fn:static-base-uri` ✅ in [context.dart]

### Higher-order functions

#### Functions on functions

* `fn:function-lookup`
* `fn:function-name` ✅ in [higher_order.dart]
* `fn:function-arity` ✅ in [higher_order.dart]

#### Basic higher-order functions

* `fn:for-each` ✅ in [higher_order.dart]
* `fn:filter` ✅ in [higher_order.dart]
* `fn:fold-left` ✅ in [higher_order.dart]
* `fn:fold-right` ✅ in [higher_order.dart]
* `fn:for-each-pair` ✅ in [higher_order.dart]
* `fn:sort` ✅ in [higher_order.dart]
* `fn:apply` ✅ in [higher_order.dart]

#### Dynamic Loading

* `fn:load-xquery-module`
* `fn:transform`

### Maps and Arrays

#### Functions that Operate on Maps

* `op:same-key` ✅ in [map.dart]
* `map:merge` ✅ in [map.dart]
* `map:size` ✅ in [map.dart]
* `map:keys` ✅ in [map.dart]
* `map:contains` ✅ in [map.dart]
* `map:get` ✅ in [map.dart]
* `map:find` ✅ in [map.dart]
* `map:put` ✅ in [map.dart]
* `map:entry` ✅ in [map.dart]
* `map:remove` ✅ in [map.dart]
* `map:for-each` ✅ in [map.dart]

#### Functions that Operate on Arrays

* `array:size` ✅ in [array.dart]
* `array:get` ✅ in [array.dart]
* `array:put` ✅ in [array.dart]
* `array:append` ✅ in [array.dart]
* `array:subarray` ✅ in [array.dart]
* `array:remove` ✅ in [array.dart]
* `array:insert-before` ✅ in [array.dart]
* `array:head` ✅ in [array.dart]
* `array:tail` ✅ in [array.dart]
* `array:reverse` ✅ in [array.dart]
* `array:join` ✅ in [array.dart]
* `array:for-each` ✅ in [array.dart]
* `array:filter` ✅ in [array.dart]
* `array:fold-left` ✅ in [array.dart]
* `array:fold-right` ✅ in [array.dart]
* `array:for-each-pair` ✅ in [array.dart]
* `array:sort` ✅ in [array.dart]
* `array:flatten` ✅ in [array.dart]

#### Functions on JSON Data

* `fn:parse-json` ✅ in [json.dart]
* `fn:json-doc` ✅ in [json.dart]
* `fn:json-to-xml` ✅ in [json.dart]
* `fn:xml-to-json` ✅ in [json.dart]
