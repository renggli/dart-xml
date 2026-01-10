# Functions

XPath Functions and Operators 3.1: <https://www.w3.org/TR/xpath-functions-31/>

## 2 Accessors

- fn:node-name
- fn:nilled
- fn:string
- fn:data
- fn:base-uri
- fn:document-uri

## 3 Errors and diagnostics

- fn:error
- fn:trace

## 4 Functions and operators on numerics

### 4.2 Arithmetic operators on numeric values

- op:numeric-add
- op:numeric-subtract
- op:numeric-multiply
- op:numeric-divide
- op:numeric-integer-divide
- op:numeric-mod
- op:numeric-unary-plus
- op:numeric-unary-minus

### 4.3 Comparison operators on numeric values

- op:numeric-equal
- op:numeric-less-than
- op:numeric-greater-than

### 4.4 Functions on numeric values

- fn:abs
- fn:ceiling
- fn:floor
- fn:round
- fn:round-half-to-even

### 4.5 Parsing numbers

- fn:number

### 4.6 Formatting integers

- fn:format-integer

### 4.7 Formatting numbers

- fn:format-number

### 4.8 Trigonometric and exponential functions

- math:pi
- math:exp
- math:exp10
- math:log
- math:log10
- math:pow
- math:sqrt
- math:sin
- math:cos
- math:tan
- math:asin
- math:acos
- math:atan
- math:atan2

### 4.9 Random Numbers

- fn:random-number-generator

## 5 Functions on strings

### 5.2 Functions to assemble and disassemble strings

- fn:codepoints-to-string
- fn:string-to-codepoints

### 5.3 Comparison of strings

- fn:compare
- fn:codepoint-equal
- fn:collation-key
- fn:contains-token

### 5.4 Functions on string values

- fn:concat
- fn:string-join
- fn:substring
- fn:string-length
- fn:normalize-space
- fn:normalize-unicode
- fn:upper-case
- fn:lower-case
- fn:translate

### 5.5 Functions based on substring matching

- fn:contains
- fn:starts-with
- fn:ends-with
- fn:substring-before
- fn:substring-after

### 5.6 String functions that use regular expressions

- fn:matches
- fn:replace
- fn:tokenize
- fn:analyze-string

## 6 Functions that manipulate URIs

- fn:resolve-uri
- fn:encode-for-uri
- fn:iri-to-uri
- fn:escape-html-uri

## 7 Functions and operators on Boolean values

### 7.1 Boolean constant functions

- fn:true
- fn:false

### 7.2 Operators on Boolean values

- op:boolean-equal
- op:boolean-less-than
- op:boolean-greater-than

### 7.3 Functions on Boolean values

- fn:boolean
- fn:not

## 8 Functions and operators on durations

### 8.2 Comparison operators on durations

- op:yearMonthDuration-less-than
- op:yearMonthDuration-greater-than
- op:dayTimeDuration-less-than
- op:dayTimeDuration-greater-than
- op:duration-equal

### 8.3 Component extraction functions on durations

- fn:years-from-duration
- fn:months-from-duration
- fn:days-from-duration
- fn:hours-from-duration
- fn:minutes-from-duration
- fn:seconds-from-duration

### 8.4 Arithmetic operators on durations

- op:add-yearMonthDurations
- op:subtract-yearMonthDurations
- op:multiply-yearMonthDuration
- op:divide-yearMonthDuration
- op:divide-yearMonthDuration-by-yearMonthDuration
- op:add-dayTimeDurations
- op:subtract-dayTimeDurations
- op:multiply-dayTimeDuration
- op:divide-dayTimeDuration
- op:divide-dayTimeDuration-by-dayTimeDuration

## 9 Functions and operators on dates and times

### 9.3 Constructing a dateTime

- fn:dateTime

### 9.4 Comparison operators on duration, date and time values

- op:dateTime-equal
- op:dateTime-less-than
- op:dateTime-greater-than
- op:date-equal
- op:date-less-than
- op:date-greater-than
- op:time-equal
- op:time-less-than
- op:time-greater-than
- op:gYearMonth-equal
- op:gYear-equal
- op:gMonthDay-equal
- op:gMonth-equal
- op:gDay-equal

### 9.5 Component extraction functions on dates and times

- fn:year-from-dateTime
- fn:month-from-dateTime
- fn:day-from-dateTime
- fn:hours-from-dateTime
- fn:minutes-from-dateTime
- fn:seconds-from-dateTime
- fn:timezone-from-dateTime
- fn:year-from-date
- fn:month-from-date
- fn:day-from-date
- fn:timezone-from-date
- fn:hours-from-time
- fn:minutes-from-time
- fn:seconds-from-time
- fn:timezone-from-time

### 9.6 Timezone adjustment functions on dates and time values

- fn:adjust-dateTime-to-timezone
- fn:adjust-date-to-timezone
- fn:adjust-time-to-timezone

### 9.7 Arithmetic operators on durations, dates and times

- op:subtract-dateTimes
- op:subtract-dates
- op:subtract-times
- op:add-yearMonthDuration-to-dateTime
- op:add-dayTimeDuration-to-dateTime
- op:subtract-yearMonthDuration-from-dateTime
- op:subtract-dayTimeDuration-from-dateTime
- op:add-yearMonthDuration-to-date
- op:add-dayTimeDuration-to-date
- op:subtract-yearMonthDuration-from-date
- op:subtract-dayTimeDuration-from-date
- op:add-dayTimeDuration-to-time
- op:subtract-dayTimeDuration-from-time

### 9.8 Formatting dates and times

- fn:format-dateTime
- fn:format-date
- fn:format-time

### 9.9 Parsing dates and times

- fn:parse-ietf-date

## 10 Functions related to QNames

### 10.1 Functions to create a QName

- fn:resolve-QName
- fn:QName

### 10.2 Functions and operators related to QNames

- op:QName-equal
- fn:prefix-from-QName
- fn:local-name-from-QName
- fn:namespace-uri-from-QName
- fn:namespace-uri-for-prefix
- fn:in-scope-prefixes

## 11 Operators on base64Binary and hexBinary

### 11.1 Comparisons of base64Binary and hexBinary values

- op:hexBinary-equal
- op:hexBinary-less-than
- op:hexBinary-greater-than
- op:base64Binary-equal
- op:base64Binary-less-than
- op:base64Binary-greater-than

## 12 Operators on NOTATION

- op:NOTATION-equal

## 13 Functions and operators on nodes

- fn:name
- fn:local-name
- fn:namespace-uri
- fn:lang
- fn:root
- fn:path
- fn:has-children
- fn:innermost
- fn:outermost

## 14 Functions and operators on sequences

### 14.1 General functions and operators on sequences

- fn:empty
- fn:exists
- fn:head
- fn:tail
- fn:insert-before
- fn:remove
- fn:reverse
- fn:subsequence
- fn:unordered

### 14.2 Functions that compare values in sequences

- fn:distinct-values
- fn:index-of
- fn:deep-equal

### 14.3 Functions that test the cardinality of sequences

- fn:zero-or-one
- fn:one-or-more
- fn:exactly-one

### 14.4 Aggregate functions

- fn:count
- fn:avg
- fn:max
- fn:min
- fn:sum

### 14.5 Functions on node identifiers

- fn:id
- fn:element-with-id
- fn:idref
- fn:generate-id

### 14.6 Functions giving access to external information

- fn:doc
- fn:doc-available
- fn:collection
- fn:uri-collection
- fn:unparsed-text
- fn:unparsed-text-lines
- fn:unparsed-text-available
- fn:environment-variable
- fn:available-environment-variables

### 14.7 Parsing and serializing

- fn:parse-xml
- fn:parse-xml-fragment
- fn:serialize

## 15 Context functions

- fn:position
- fn:last
- fn:current-dateTime
- fn:current-date
- fn:current-time
- fn:implicit-timezone
- fn:default-collation
- fn:default-language
- fn:static-base-uri

## 16 Higher-order functions

### 16.1 Functions on functions

- fn:function-lookup
- fn:function-name
- fn:function-arity

### 16.2 Basic higher-order functions

- fn:for-each
- fn:filter
- fn:fold-left
- fn:fold-right
- fn:for-each-pair
- fn:sort
- fn:apply

### 16.3 Dynamic Loading

- fn:load-xquery-module
- fn:transform

## 17 Maps and Arrays

### 17.1 Functions that Operate on Maps

- op:same-key
- map:merge
- map:size
- map:keys
- map:contains
- map:get
- map:find
- map:put
- map:entry
- map:remove
- map:for-each

### 17.3 Functions that Operate on Arrays

- array:size
- array:get
- array:put
- array:append
- array:subarray
- array:remove
- array:insert-before
- array:head
- array:tail
- array:reverse
- array:join
- array:for-each
- array:filter
- array:fold-left
- array:fold-right
- array:for-each-pair
- array:sort
- array:flatten

### 17.5 Functions on JSON Data

- fn:parse-json
- fn:json-doc
- fn:json-to-xml
- fn:xml-to-json
