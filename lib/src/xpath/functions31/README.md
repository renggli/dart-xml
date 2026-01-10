# Functions

XPath Functions and Operators 3.1: <`https://www.w3.org/TR/xpath-functions-31/>`

## 2 Accessors

- `fn:node-name` ✅ in [accessor.dart]
- `fn:nilled` ✅ in [accessor.dart]
- `fn:string` ✅ in [accessor.dart]
- `fn:data` ✅ in [accessor.dart]
- `fn:base-uri` ✅ in [accessor.dart]
- `fn:document-uri` ✅ in [accessor.dart]

## 3 Errors and diagnostics

- `fn:error` ✅ in [error.dart]
- `fn:trace` ✅ in [error.dart]

## 4 Functions and operators on numerics

### 4.2 Arithmetic operators on numeric values

- `op:numeric-add` ✅ in [number.dart]
- `op:numeric-subtract` ✅ in [number.dart]
- `op:numeric-multiply` ✅ in [number.dart]
- `op:numeric-divide` ✅ in [number.dart]
- `op:numeric-integer-divide` ✅ in [number.dart]
- `op:numeric-mod` ✅ in [number.dart]
- `op:numeric-unary-plus` ✅ in [number.dart]
- `op:numeric-unary-minus` ✅ in [number.dart]

### 4.3 Comparison operators on numeric values

- `op:numeric-equal` ✅ in [number.dart]
- `op:numeric-less-than` ✅ in [number.dart]
- `op:numeric-greater-than` ✅ in [number.dart]

### 4.4 Functions on numeric values

- `fn:abs` ✅ in [number.dart]
- `fn:ceiling` ✅ in [number.dart]
- `fn:floor` ✅ in [number.dart]
- `fn:round` ✅ in [number.dart]
- `fn:round-half-to-even` ✅ in [number.dart]

### 4.5 Parsing numbers

- `fn:number` ✅ in [number.dart]

### 4.6 Formatting integers

- `fn:format-integer`

### 4.7 Formatting numbers

- `fn:format-number`

### 4.8 Trigonometric and exponential functions

- `math:pi` ✅ in [number.dart]
- `math:exp` ✅ in [number.dart]
- `math:exp10` ✅ in [number.dart]
- `math:log` ✅ in [number.dart]
- `math:log10` ✅ in [number.dart]
- `math:pow` ✅ in [number.dart]
- `math:sqrt` ✅ in [number.dart]
- `math:sin` ✅ in [number.dart]
- `math:cos` ✅ in [number.dart]
- `math:tan` ✅ in [number.dart]
- `math:asin` ✅ in [number.dart]
- `math:acos` ✅ in [number.dart]
- `math:atan` ✅ in [number.dart]
- `math:atan2` ✅ in [number.dart]

### 4.9 Random Numbers

- `fn:random-number-generator`

## 5 Functions on strings

### 5.2 Functions to assemble and disassemble strings

- `fn:codepoints-to-string`
- `fn:string-to-codepoints`

### 5.3 Comparison of strings

- `fn:compare`
- `fn:codepoint-equal`
- `fn:collation-key`
- `fn:contains-token`

### 5.4 Functions on string values

- `fn:concat` ✅ in [string.dart]
- `fn:string-join` ✅ in [string.dart]
- `fn:substring` ✅ in [string.dart]
- `fn:string-length` ✅ in [string.dart]
- `fn:normalize-space` ✅ in [string.dart]
- `fn:normalize-unicode` ✅ in [string.dart]
- `fn:upper-case` ✅ in [string.dart]
- `fn:lower-case` ✅ in [string.dart]
- `fn:translate` ✅ in [string.dart]

### 5.5 Functions based on substring matching

- `fn:contains` ✅ in [string.dart]
- `fn:starts-with` ✅ in [string.dart]
- `fn:ends-with` ✅ in [string.dart]
- `fn:substring-before` ✅ in [string.dart]
- `fn:substring-after` ✅ in [string.dart]

### 5.6 String functions that use regular expressions

- `fn:matches` ✅ in [string.dart]
- `fn:replace` ✅ in [string.dart]
- `fn:tokenize` ✅ in [string.dart]
- `fn:analyze-string` ✅
- `fn:codepoints-to-string` ✅ in [string.dart]
- `fn:string-to-codepoints` ✅ in [string.dart]
- `fn:compare` ✅ in [string.dart]
- `fn:codepoint-equal` ✅ in [string.dart]
- `fn:contains-token` ✅ in [string.dart]

## 6 Functions that manipulate URIs

- `fn:resolve-uri` ✅ in [uri.dart]
- `fn:encode-for-uri` ✅ in [uri.dart]
- `fn:iri-to-uri` ✅ in [uri.dart]
- `fn:escape-html-uri` ✅ in [uri.dart]

## 7 Functions and operators on Boolean values

### 7.1 Boolean constant functions

- `fn:true` ✅ in [boolean.dart]
- `fn:false` ✅ in [boolean.dart]

### 7.2 Operators on Boolean values

- `op:boolean-equal`
- `op:boolean-less-than`
- `op:boolean-greater-than`

### 7.3 Functions on Boolean values

- `fn:boolean` ✅ in [boolean.dart]
- `fn:not` ✅ in [boolean.dart]

## 8 Functions and operators on durations

### 8.2 Comparison operators on durations

- `op:yearMonthDuration-less-than` ✅ in [duration.dart]
- `op:yearMonthDuration-greater-than` ✅ in [duration.dart]
- `op:dayTimeDuration-less-than` ✅ in [duration.dart]
- `op:dayTimeDuration-greater-than` ✅ in [duration.dart]
- `op:duration-equal` ✅ in [duration.dart]

### 8.3 Component extraction functions on durations

- `fn:years-from-duration` ✅ in [duration.dart]
- `fn:months-from-duration` ✅ in [duration.dart]
- `fn:days-from-duration` ✅ in [duration.dart]
- `fn:hours-from-duration` ✅ in [duration.dart]
- `fn:minutes-from-duration` ✅ in [duration.dart]
- `fn:seconds-from-duration` ✅ in [duration.dart]

### 8.4 Arithmetic operators on durations

- `op:add-yearMonthDurations` ✅ in [duration.dart]
- `op:subtract-yearMonthDurations` ✅ in [duration.dart]
- `op:multiply-yearMonthDuration` ✅ in [duration.dart]
- `op:divide-yearMonthDuration` ✅ in [duration.dart]
- `op:divide-yearMonthDuration-by-yearMonthDuration` ✅ in [duration.dart]
- `op:add-dayTimeDurations` ✅ in [duration.dart]
- `op:subtract-dayTimeDurations` ✅ in [duration.dart]
- `op:multiply-dayTimeDuration` ✅ in [duration.dart]
- `op:divide-dayTimeDuration` ✅ in [duration.dart]
- `op:divide-dayTimeDuration-by-dayTimeDuration` ✅ in [duration.dart]

## 9 Functions and operators on dates and times

### 9.3 Constructing a dateTime

- `fn:dateTime` ✅ in [date_time.dart]

### 9.4 Comparison operators on duration, date and time values

- `op:dateTime-equal` ✅ in [date_time.dart]
- `op:dateTime-less-than` ✅ in [date_time.dart]
- `op:dateTime-greater-than` ✅ in [date_time.dart]
- `op:date-equal` ✅ in [date_time.dart]
- `op:date-less-than` ✅ in [date_time.dart]
- `op:date-greater-than` ✅ in [date_time.dart]
- `op:time-equal` ✅ in [date_time.dart]
- `op:time-less-than` ✅ in [date_time.dart]
- `op:time-greater-than` ✅ in [date_time.dart]
- `op:gYearMonth-equal`
- `op:gYear-equal`
- `op:gMonthDay-equal`
- `op:gMonth-equal`
- `op:gDay-equal`

### 9.5 Component extraction functions on dates and times

- `fn:year-from-dateTime` ✅ in [date_time.dart]
- `fn:month-from-dateTime` ✅ in [date_time.dart]
- `fn:day-from-dateTime` ✅ in [date_time.dart]
- `fn:hours-from-dateTime` ✅ in [date_time.dart]
- `fn:minutes-from-dateTime` ✅ in [date_time.dart]
- `fn:seconds-from-dateTime` ✅ in [date_time.dart]
- `fn:timezone-from-dateTime` ✅ in [date_time.dart]
- `fn:year-from-date` ✅ in [date_time.dart]
- `fn:month-from-date` ✅ in [date_time.dart]
- `fn:day-from-date` ✅ in [date_time.dart]
- `fn:timezone-from-date` ✅ in [date_time.dart]
- `fn:hours-from-time` ✅ in [date_time.dart]
- `fn:minutes-from-time` ✅ in [date_time.dart]
- `fn:seconds-from-time` ✅ in [date_time.dart]
- `fn:timezone-from-time` ✅ in [date_time.dart]

### 9.6 Timezone adjustment functions on dates and time values

- `fn:adjust-dateTime-to-timezone`
- `fn:adjust-date-to-timezone`
- `fn:adjust-time-to-timezone`

### 9.7 Arithmetic operators on durations, dates and times

- `op:subtract-dateTimes` ✅ in [date_time.dart]
- `op:subtract-dates` ✅ in [date_time.dart]
- `op:subtract-times` ✅ in [date_time.dart]
- `op:add-yearMonthDuration-to-dateTime` ✅ in [date_time.dart]
- `op:add-dayTimeDuration-to-dateTime` ✅ in [date_time.dart]
- `op:subtract-yearMonthDuration-from-dateTime` ✅ in [date_time.dart]
- `op:subtract-dayTimeDuration-from-dateTime` ✅ in [date_time.dart]
- `op:add-yearMonthDuration-to-date` ✅ in [date_time.dart]
- `op:add-dayTimeDuration-to-date` ✅ in [date_time.dart]
- `op:subtract-yearMonthDuration-from-date` ✅ in [date_time.dart]
- `op:subtract-dayTimeDuration-from-date` ✅ in [date_time.dart]
- `op:add-dayTimeDuration-to-time` ✅ in [date_time.dart]
- `op:subtract-dayTimeDuration-from-time` ✅ in [date_time.dart]

### 9.8 Formatting dates and times

- `fn:format-dateTime`
- `fn:format-date`
- `fn:format-time`

### 9.9 Parsing dates and times

- `fn:parse-ietf-date`

## 10 Functions related to QNames

### 10.1 Functions to create a QName

- `fn:resolve-QName` ✅ in [qname.dart]
- `fn:QName` ✅ in [qname.dart]

### 10.2 Functions and operators related to QNames

- `op:QName-equal` ✅ in [qname.dart]
- `fn:prefix-from-QName` ✅ in [qname.dart]
- `fn:local-name-from-QName` ✅ in [qname.dart]
- `fn:namespace-uri-from-QName` ✅ in [qname.dart]
- `fn:namespace-uri-for-prefix` ✅ in [qname.dart]
- `fn:in-scope-prefixes` ✅ in [qname.dart]

## 11 Operators on base64Binary and hexBinary

### 11.1 Comparisons of base64Binary and hexBinary values

- `op:hexBinary-equal` ✅ in [binary.dart]
- `op:hexBinary-less-than` ✅ in [binary.dart]
- `op:hexBinary-greater-than` ✅ in [binary.dart]
- `op:base64Binary-equal` ✅ in [binary.dart]
- `op:base64Binary-less-than` ✅ in [binary.dart]
- `op:base64Binary-greater-than` ✅ in [binary.dart]

## 12 Operators on NOTATION

- `op:NOTATION-equal` ✅ in [notation.dart]

## 13 Functions and operators on nodes

- `fn:name` ✅ in [node.dart]
- `fn:local-name` ✅ in [node.dart]
- `fn:namespace-uri` ✅ in [node.dart]
- `fn:lang` ✅ in [boolean.dart]
- `fn:root` ✅ in [node.dart]
- `fn:path` ✅ in [node.dart]
- `fn:has-children` ✅ in [node.dart]
- `fn:innermost` ✅ in [node.dart]
- `fn:outermost` ✅ in [node.dart]

## 14 Functions and operators on sequences

### 14.1 General functions and operators on sequences

- `fn:empty` ✅ in [sequence.dart]
- `fn:exists` ✅ in [sequence.dart]
- `fn:head` ✅ in [sequence.dart]
- `fn:tail` ✅ in [sequence.dart]
- `fn:insert-before` ✅ in [sequence.dart]
- `fn:remove` ✅ in [sequence.dart]
- `fn:reverse` ✅ in [sequence.dart]
- `fn:subsequence` ✅ in [sequence.dart]
- `fn:unordered` ✅ in [sequence.dart]

### 14.2 Functions that compare values in sequences

- `fn:distinct-values` ✅ in [sequence.dart]
- `fn:index-of` ✅ in [sequence.dart]
- `fn:deep-equal` ✅ in [sequence.dart]

### 14.3 Functions that test the cardinality of sequences

- `fn:zero-or-one` ✅ in [sequence.dart]
- `fn:one-or-more` ✅ in [sequence.dart]
- `fn:exactly-one` ✅ in [sequence.dart]

### 14.4 Aggregate functions

- `fn:count` ✅ in [sequence.dart]
- `fn:avg` ✅ in [sequence.dart]
- `fn:max` ✅ in [sequence.dart]
- `fn:min` ✅ in [sequence.dart]
- `fn:sum` ✅ in [sequence.dart]

### 14.5 Functions on node identifiers

- `fn:id` ✅ in [sequence.dart]
- `fn:element-with-id` ✅ in [sequence.dart]
- `fn:idref` ✅ in [sequence.dart]
- `fn:generate-id` ✅ in [sequence.dart]

### 14.6 Functions giving access to external information

- `fn:doc` ✅ in [sequence.dart]
- `fn:doc-available` ✅ in [sequence.dart]
- `fn:collection` ✅ in [sequence.dart]
- `fn:uri-collection` ✅ in [sequence.dart]
- `fn:unparsed-text` ✅ in [sequence.dart]
- `fn:unparsed-text-lines` ✅ in [sequence.dart]
- `fn:unparsed-text-available` ✅ in [sequence.dart]
- `fn:environment-variable` ✅ in [sequence.dart]
- `fn:available-environment-variables` ✅ in [sequence.dart]

### 14.7 Parsing and serializing

- `fn:parse-xml` ✅ in [sequence.dart]
- `fn:parse-xml-fragment` ✅ in [sequence.dart]  
- `fn:serialize` ✅ in [sequence.dart]

## 15 Context functions

- `fn:position` ✅ in [context.dart]
- `fn:last` ✅ in [context.dart]
- `fn:current-dateTime` ✅ in [context.dart]
- `fn:current-date` ✅ in [context.dart]
- `fn:current-time` ✅ in [context.dart]
- `fn:implicit-timezone` ✅ in [context.dart]
- `fn:default-collation` ✅ in [context.dart]
- `fn:default-language` ✅ in [context.dart]
- `fn:static-base-uri` ✅ in [context.dart]

## 16 Higher-order functions

### 16.1 Functions on functions

- `fn:function-lookup`
- `fn:function-name`
- `fn:function-arity`

### 16.2 Basic higher-order functions

- `fn:for-each` ✅ in [higher_order.dart]
- `fn:filter` ✅ in [higher_order.dart]
- `fn:fold-left` ✅ in [higher_order.dart]
- `fn:fold-right` ✅ in [higher_order.dart]
- `fn:for-each-pair` ✅ in [higher_order.dart]
- `fn:sort` ✅ in [higher_order.dart]
- `fn:apply` ✅ in [higher_order.dart]

### 16.3 Dynamic Loading

- `fn:load-xquery-module`
- `fn:transform`

## 17 Maps and Arrays

### 17.1 Functions that Operate on Maps

- `op:same-key` ✅ in [maps_arrays.dart]
- `map:merge` ✅ in [maps_arrays.dart]
- `map:size` ✅ in [maps_arrays.dart]
- `map:keys` ✅ in [maps_arrays.dart]
- `map:contains` ✅ in [maps_arrays.dart]
- `map:get` ✅ in [maps_arrays.dart]
- `map:find` ✅ in [maps_arrays.dart]
- `map:put` ✅ in [maps_arrays.dart]
- `map:entry` ✅ in [maps_arrays.dart]
- `map:remove` ✅ in [maps_arrays.dart]
- `map:for-each` ✅ in [maps_arrays.dart]

### 17.3 Functions that Operate on Arrays

- `array:size` ✅ in [maps_arrays.dart]
- `array:get` ✅ in [maps_arrays.dart]
- `array:put` ✅ in [maps_arrays.dart]
- `array:append` ✅ in [maps_arrays.dart]
- `array:subarray` ✅ in [maps_arrays.dart]
- `array:remove` ✅ in [maps_arrays.dart]
- `array:insert-before` ✅ in [maps_arrays.dart]
- `array:head` ✅ in [maps_arrays.dart]
- `array:tail` ✅ in [maps_arrays.dart]
- `array:reverse` ✅ in [maps_arrays.dart]
- `array:join` ✅ in [maps_arrays.dart]
- `array:for-each` ✅ in [maps_arrays.dart]
- `array:filter` ✅ in [maps_arrays.dart]
- `array:fold-left` ✅ in [maps_arrays.dart]
- `array:fold-right` ✅ in [maps_arrays.dart]
- `array:for-each-pair` ✅ in [maps_arrays.dart]
- `array:sort` ✅ in [maps_arrays.dart]
- `array:flatten` ✅ in [maps_arrays.dart]

### 17.5 Functions on JSON Data

- `fn:parse-json` ✅ in [json.dart]
- `fn:json-doc` ✅ in [json.dart]
- `fn:json-to-xml` ✅ in [json.dart]
- `fn:xml-to-json` ✅ in [json.dart]
