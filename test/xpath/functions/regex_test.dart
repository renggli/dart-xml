import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/regex.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

void main() {
  group('validateXPathRegexFlags', () {
    test('valid flags', () {
      check(() => validateXPathRegexFlags(null)).returnsNormally();
      check(() => validateXPathRegexFlags('')).returnsNormally();
      check(() => validateXPathRegexFlags('smixq')).returnsNormally();
      check(() => validateXPathRegexFlags('i')).returnsNormally();
    });

    test('invalid flag', () {
      check(() => validateXPathRegexFlags('z'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.FORX0001,
              message: 'Invalid regex flag: z',
            ),
          );
    });

    test('duplicate flag', () {
      check(() => validateXPathRegexFlags('ii'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.FORX0001,
              message: 'Duplicate regular expression flag: i',
            ),
          );
    });
  });

  group('compileXPathRegex', () {
    test('compiles with all flags', () {
      check(compileXPathRegex('abc', 'i').isCaseSensitive).isFalse();
      check(compileXPathRegex('^abc', 'm').isMultiLine).isTrue();
      check(compileXPathRegex('.*', 's').isDotAll).isTrue();
      check(compileXPathRegex('a.b', 'q').pattern).equals('a\\.b');
      check(compileXPathRegex(' a b ', 'x').pattern).equals('ab');
    });

    test('cached regex returns same instance', () {
      final reg1 = getCachedXPathRegex('abc', 'i');
      final reg2 = getCachedXPathRegex('abc', 'i');
      check(identical(reg1, reg2)).isTrue();
    });

    test('throws for invalid pattern syntax', () {
      check(() => compileXPathRegex(')-(', null))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('throws for invalid range quantifier order', () {
      check(() => compileXPathRegex('a{5,2}', null))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });
  });

  group('translateXPathRegex', () {
    test('translates branches and pieces', () {
      check(translateXPathRegex('a|b|c')).equals('a|b|c');
      check(translateXPathRegex('ab+c*d?')).equals('ab+c*d?');
      check(translateXPathRegex('a*?b+?c??')).equals('a*?b+?c??');
      check(translateXPathRegex('a{2}b{2,}c{2,4}d{2}?e{2,}?f{2,4}?'))
          .equals('a{2}b{2,}c{2,4}d{2}?e{2,}?f{2,4}?');
    });

    test('translates quantified anchors', () {
      check(translateXPathRegex('^?')).equals('(?:^)?');
      check(translateXPathRegex(r'$+')).equals(r'(?:$)+');
    });

    test('translates wildcard and anchors', () {
      check(translateXPathRegex(r'^.+$')).equals(r'^.+$');
    });

    test('translates groups', () {
      check(translateXPathRegex('(abc)')).equals('(abc)');
      check(translateXPathRegex('(?:abc)')).equals('(?:abc)');
      check(translateXPathRegex('(a(b(c)))')).equals('(a(b(c)))');
    });

    test('translates escapes', () {
      check(translateXPathRegex(r'\ ')).equals(r'\x20');
      check(translateXPathRegex(r'\-')).equals(r'\x2D');
      check(translateXPathRegex(r'\:')).equals(':');
      check(translateXPathRegex(r'\#')).equals('#');
      check(translateXPathRegex(r'\n\r\t')).equals(r'\n\r\t');
      check(translateXPathRegex(r'\i')).equals(r'[\p{L}_:]');
      check(translateXPathRegex(r'\I')).equals(r'[^\p{L}_:]');
      check(translateXPathRegex(r'\c')).equals(r'[\p{L}\p{N}.\-_:\p{M}]');
      check(translateXPathRegex(r'\C')).equals(r'[^\p{L}\p{N}.\-_:\p{M}]');
      check(translateXPathRegex(r'\d\D\s\S\w\W')).equals(r'\d\D\s\S\w\W');
      check(translateXPathRegex(r'\\')).equals(r'\\');
      check(translateXPathRegex(r'\(\)\[\]\{\}\^\$\|\.\?\*\+'))
          .equals(r'\(\)\[\]\{\}\^\$\|\.\?\*\+');
    });

    test('translates backreferences', () {
      check(translateXPathRegex(r'(a)\1')).equals(r'(a)\1');
      check(translateXPathRegex(r'^(#)abc\11$')).equals(r'^(#)abc\1(?:)1$');
      check(translateXPathRegex(r'(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)\10'))
          .equals(r'(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)\10');
      check(translateXPathRegex(r'(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)\101'))
          .equals(r'(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)\10(?:)1');
      check(translateXPathRegex(r'(?:a)(b)\1')).equals(r'(?:a)(b)\1');
      check(() => translateXPathRegex(r'\1'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex(r'((a)\1)'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('translates unicode property escapes', () {
      check(translateXPathRegex(r'\p{IsBasicLatin}')).equals(r'[\u{0}-\u{7f}]');
      check(translateXPathRegex(r'\P{IsBasicLatin}'))
          .equals(r'[^\u{0}-\u{7f}]');
      check(translateXPathRegex(r'\p{L}')).equals(r'\p{L}');
      check(translateXPathRegex(r'\P{Nd}')).equals(r'\P{Nd}');
      check(() => translateXPathRegex(r'\p{IsInvalidBlock}'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex(r'\p{InvalidCategory}'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex(r'\p{}'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('translates character classes', () {
      check(translateXPathRegex('[abc]')).equals('[abc]');
      check(translateXPathRegex('[^abc]')).equals('[^abc]');
      check(translateXPathRegex('[a-z]')).equals('[a-z]');
      check(translateXPathRegex(r'[^\P{IsBasicLatin}]'))
          .equals(r'[\u{0}-\u{7f}]');
      check(translateXPathRegex('[a-z-[aeiou]]'))
          .equals('(?:(?![aeiou])[a-z])');
      check(translateXPathRegex('[^a-z-[aeiou]]'))
          .equals('(?:(?![aeiou])[^a-z])');
      check(translateXPathRegex(r'[\C]')).equals(r'[^\p{L}\p{N}.\-_:\p{M}]');
      check(translateXPathRegex(r'[\I]')).equals(r'[^\p{L}_:]');
      check(translateXPathRegex(r'[\C\d]'))
          .equals(r'(?:[^\p{L}\p{N}.\-_:\p{M}]|\d)');
      check(translateXPathRegex(r'[\I_]')).equals(r'(?:[^\p{L}_:]|_)');
      check(translateXPathRegex(r'[\i\c\d\n\-]'))
          .equals(r'[\p{L}_:\p{L}\p{N}.\-_:\p{M}\d\n\-]');
      check(translateXPathRegex(r'[\-\[\]\n\r\t]')).equals(r'[\-\[\]\n\r\t]');
      check(translateXPathRegex(r'[\(\)\{\}\^\$\|\.\?\*\+]'))
          .equals(r'[\(\)\{\}\^\$\|\.\?\*\+]');
      check(translateXPathRegex(r'[\p{IsBasicLatin}]'))
          .equals(r'[\u{0}-\u{7f}]');
      check(translateXPathRegex(r'[\P{IsBasicLatin}]'))
          .equals(r'[^\u{0}-\u{7f}]');
      check(translateXPathRegex(r'[\p{L}]')).equals(r'[\p{L}]');
      check(() => translateXPathRegex(r'[\p{IsInvalidBlock}]'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex(r'[\p{InvalidCategory}]'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex(r'[\p{}]'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('translates with flag x', () {
      check(translateXPathRegex(' a ( b | c ) d ', isFlagX: true))
          .equals('a(b|c)d');
      check(translateXPathRegex('[ a b ]', isFlagX: true)).equals('[ a b ]');
      check(translateXPathRegex(r'\p{ IsBasicLatin }', isFlagX: true))
          .equals(r'[\u{0}-\u{7f}]');
      check(translateXPathRegex(r'[\p{ IsBasicLatin }]', isFlagX: true))
          .equals(r'[\u{0}-\u{7f}]');
    });

    test('fails on syntax errors', () {
      check(() => translateXPathRegex(r'abc\'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex('(abc'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
      check(() => translateXPathRegex('[abc'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });
  });

  group('parseRegexGroups', () {
    test('parses nested capturing groups', () {
      final root = parseRegexGroups('((a)(b))');
      check(root.nr).equals(0);
      check(root.parentNr).equals(-1);
      check(root.children).length.equals(1);
      check(root.children[0].nr).equals(1);
      check(root.children[0].parentNr).equals(0);
      check(root.children[0].children).length.equals(2);
      check(root.children[0].children[0].nr).equals(2);
      check(root.children[0].children[0].parentNr).equals(1);
      check(root.children[0].children[1].nr).equals(3);
      check(root.children[0].children[1].parentNr).equals(1);
    });

    test('ignores non-capturing groups and character classes', () {
      final root = parseRegexGroups('(?:[(])(a)');
      check(root.children).length.equals(1);
      check(root.children[0].nr).equals(1);
      check(root.children[0].children).isEmpty();
    });

    test('parses with flag x', () {
      final root = parseRegexGroups(' ( a ) | ( b ) ', isFlagX: true);
      check(root.children).length.equals(2);
      check(root.children[0].nr).equals(1);
      check(root.children[1].nr).equals(2);
    });

    test('returns empty root group on syntax error', () {
      final root = parseRegexGroups('(');
      check(root.children).isEmpty();
    });
  });

  group('applyXPathReplace', () {
    test('literal replacement', () {
      final reg = RegExp('a');
      check(applyXPathReplace('banana', reg, r'$1', isLiteral: true))
          .equals(r'b$1n$1n$1');
    });

    test('throws FORX0003 on zero-length match', () {
      final reg = RegExp('.*');
      check(() => applyXPathReplace('banana', reg, 'x'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0003),
          );
    });

    test('substitutes matched groups', () {
      final reg = RegExp('(b)(a)');
      check(applyXPathReplace('banana', reg, r'[$0-$1-$2]'))
          .equals('[ba-b-a]nana');
    });

    test('escapes dollar and backslash', () {
      final reg = RegExp('(a)');
      check(applyXPathReplace('banana', reg, r'\$$1')).equals(r'b$an$an$a');
      check(applyXPathReplace('banana', reg, r'\\$1')).equals(r'b\an\an\a');
      check(applyXPathReplace('banana', reg, r'\$$1\\'))
          .equals(r'b$a\n$a\n$a\');
    });

    test('resolves multi-digit group resolution', () {
      final pattern =
          '${List.filled(15, '(').join()}a${List.filled(15, ')').join()}';
      final reg = RegExp(pattern);
      check(applyXPathReplace('abracadabra', reg, r'$1520'))
          .equals('a20bra20ca20da20bra20');
    });

    test('throws FORX0004 for invalid template syntax', () {
      final reg = RegExp('(a)');
      check(() => applyXPathReplace('banana', reg, r'\'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004),
          );
      check(() => applyXPathReplace('banana', reg, r'\x'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004),
          );
      check(() => applyXPathReplace('banana', reg, r'$'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004),
          );
      check(() => applyXPathReplace('banana', reg, r'$9'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004),
          );
    });
  });

  group('analyzeXPathString', () {
    test('handles empty input string', () {
      final node = analyzeXPathString('', 'abc');
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions"/>',
      );
    });

    test('handles non-matching string only', () {
      final node = analyzeXPathString('banana', 'xyz');
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:non-match>banana</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles matching string only', () {
      final node = analyzeXPathString('banana', '.+');
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match>banana</fn:match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles literal mode with q flag', () {
      final node = analyzeXPathString('((banana))', '(banana)', flags: 'q');
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:non-match>(</fn:non-match>'
        '<fn:match>(banana)</fn:match>'
        '<fn:non-match>)</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles flag x with whitespace', () {
      final node = analyzeXPathString(
        'how now brown cow',
        ' (how) | (now) ',
        flags: 'x',
      );
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match><fn:group nr="1">how</fn:group></fn:match>'
        '<fn:non-match> </fn:non-match>'
        '<fn:match><fn:group nr="2">now</fn:group></fn:match>'
        '<fn:non-match> brown cow</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles empty group inside match', () {
      final node = analyzeXPathString('banana', '(b(x?))');
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match><fn:group nr="1">b<fn:group nr="2"/></fn:group></fn:match>'
        '<fn:non-match>anana</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles surrounding text and multiple groups in match', () {
      final node = analyzeXPathString(
        'start-foo-mid-bar-end',
        'start-(foo)-mid-(bar)-end',
      );
      check(node.node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match>start-<fn:group nr="1">foo</fn:group>-mid-<fn:group nr="2">bar</fn:group>-end</fn:match>'
        '</fn:analyze-string-result>',
      );
    });

    test('throws FORX0001 for invalid flags', () {
      check(() => analyzeXPathString('abc', 'abc', flags: 'w'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0001),
          );
    });

    test('throws FORX0002 for invalid pattern', () {
      check(() => analyzeXPathString('abc', ')-('))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('throws FORX0003 for zero-length pattern match', () {
      check(() => analyzeXPathString('abc', 'a?'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0003),
          );
    });
  });
}
