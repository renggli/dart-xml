import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/error_code.dart';
import 'package:xml/src/xpath/functions/regex.dart';

import '../../utils/matchers.dart';

void main() {
  group('validateXPathRegexFlags', () {
    test('valid flags', () {
      expect(() => validateXPathRegexFlags(null), returnsNormally);
      expect(() => validateXPathRegexFlags(''), returnsNormally);
      expect(() => validateXPathRegexFlags('smixq'), returnsNormally);
      expect(() => validateXPathRegexFlags('i'), returnsNormally);
    });

    test('invalid flag', () {
      expect(
        () => validateXPathRegexFlags('z'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.FORX0001,
            message: 'Invalid regex flag: z',
          ),
        ),
      );
    });

    test('duplicate flag', () {
      expect(
        () => validateXPathRegexFlags('ii'),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.FORX0001,
            message: 'Duplicate regular expression flag: i',
          ),
        ),
      );
    });
  });

  group('compileXPathRegex', () {
    test('compiles with all flags', () {
      expect(compileXPathRegex('abc', 'i').isCaseSensitive, isFalse);
      expect(compileXPathRegex('^abc', 'm').isMultiLine, isTrue);
      expect(compileXPathRegex('.*', 's').isDotAll, isTrue);
      expect(compileXPathRegex('a.b', 'q').pattern, 'a\\.b');
      expect(compileXPathRegex(' a b ', 'x').pattern, 'ab');
    });

    test('cached regex returns same instance', () {
      final reg1 = getCachedXPathRegex('abc', 'i');
      final reg2 = getCachedXPathRegex('abc', 'i');
      expect(identical(reg1, reg2), isTrue);
    });

    test('throws for invalid pattern syntax', () {
      expect(
        () => compileXPathRegex(')-(', null),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });

    test('throws for invalid range quantifier order', () {
      expect(
        () => compileXPathRegex('a{5,2}', null),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });
  });

  group('translateXPathRegex', () {
    test('translates branches and pieces', () {
      expect(translateXPathRegex('a|b|c'), 'a|b|c');
      expect(translateXPathRegex('ab+c*d?'), 'ab+c*d?');
      expect(translateXPathRegex('a*?b+?c??'), 'a*?b+?c??');
      expect(
        translateXPathRegex('a{2}b{2,}c{2,4}d{2}?e{2,}?f{2,4}?'),
        'a{2}b{2,}c{2,4}d{2}?e{2,}?f{2,4}?',
      );
    });

    test('translates quantified anchors', () {
      expect(translateXPathRegex('^?'), '(?:^)?');
      expect(translateXPathRegex(r'$+'), r'(?:$)+');
    });

    test('translates wildcard and anchors', () {
      expect(translateXPathRegex(r'^.+$'), r'^.+$');
    });

    test('translates groups', () {
      expect(translateXPathRegex('(abc)'), '(abc)');
      expect(translateXPathRegex('(?:abc)'), '(?:abc)');
      expect(translateXPathRegex('(a(b(c)))'), '(a(b(c)))');
    });

    test('translates escapes', () {
      expect(translateXPathRegex(r'\ '), r'\x20');
      expect(translateXPathRegex(r'\-'), r'\x2D');
      expect(translateXPathRegex(r'\:'), ':');
      expect(translateXPathRegex(r'\#'), '#');
      expect(translateXPathRegex(r'\n\r\t'), r'\n\r\t');
      expect(translateXPathRegex(r'\i'), r'[\p{L}_:]');
      expect(translateXPathRegex(r'\I'), r'[^\p{L}_:]');
      expect(translateXPathRegex(r'\c'), r'[\p{L}\p{N}.\-_:\p{M}]');
      expect(translateXPathRegex(r'\C'), r'[^\p{L}\p{N}.\-_:\p{M}]');
      expect(translateXPathRegex(r'\d\D\s\S\w\W'), r'\d\D\s\S\w\W');
      expect(translateXPathRegex(r'\\'), r'\\');
      expect(
        translateXPathRegex(r'\(\)\[\]\{\}\^\$\|\.\?\*\+'),
        r'\(\)\[\]\{\}\^\$\|\.\?\*\+',
      );
    });

    test('translates backreferences', () {
      expect(translateXPathRegex(r'\1'), r'\1');
      expect(translateXPathRegex(r'\19'), r'\1(?:)9');
    });

    test('translates unicode property escapes', () {
      expect(translateXPathRegex(r'\p{IsBasicLatin}'), r'[\u{0}-\u{7f}]');
      expect(translateXPathRegex(r'\P{IsBasicLatin}'), r'[^\u{0}-\u{7f}]');
      expect(translateXPathRegex(r'\p{L}'), r'\p{L}');
      expect(translateXPathRegex(r'\P{Nd}'), r'\P{Nd}');
      expect(
        () => translateXPathRegex(r'\p{IsInvalidBlock}'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex(r'\p{InvalidCategory}'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex(r'\p{}'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });

    test('translates character classes', () {
      expect(translateXPathRegex('[abc]'), '[abc]');
      expect(translateXPathRegex('[^abc]'), '[^abc]');
      expect(translateXPathRegex('[a-z]'), '[a-z]');
      expect(translateXPathRegex(r'[^\P{IsBasicLatin}]'), r'[\u{0}-\u{7f}]');
      expect(translateXPathRegex('[a-z-[aeiou]]'), '(?:(?![aeiou])[a-z])');
      expect(translateXPathRegex('[^a-z-[aeiou]]'), '(?:(?![aeiou])[^a-z])');
      expect(translateXPathRegex(r'[\C]'), r'[^\p{L}\p{N}.\-_:\p{M}]');
      expect(translateXPathRegex(r'[\I]'), r'[^\p{L}_:]');
      expect(translateXPathRegex(r'[\C\d]'), r'(?:[^\p{L}\p{N}.\-_:\p{M}]|\d)');
      expect(translateXPathRegex(r'[\I_]'), r'(?:[^\p{L}_:]|_)');
      expect(
        translateXPathRegex(r'[\i\c\d\n\-]'),
        r'[\p{L}_:\p{L}\p{N}.\-_:\p{M}\d\n\-]',
      );
      expect(translateXPathRegex(r'[\-\[\]\n\r\t]'), r'[\-\[\]\n\r\t]');
      expect(
        translateXPathRegex(r'[\(\)\{\}\^\$\|\.\?\*\+]'),
        r'[\(\)\{\}\^\$\|\.\?\*\+]',
      );
      expect(translateXPathRegex(r'[\p{IsBasicLatin}]'), r'[\u{0}-\u{7f}]');
      expect(translateXPathRegex(r'[\P{IsBasicLatin}]'), r'[^\u{0}-\u{7f}]');
      expect(translateXPathRegex(r'[\p{L}]'), r'[\p{L}]');
      expect(
        () => translateXPathRegex(r'[\p{IsInvalidBlock}]'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex(r'[\p{InvalidCategory}]'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex(r'[\p{}]'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });

    test('translates with flag x', () {
      expect(translateXPathRegex(' a ( b | c ) d ', isFlagX: true), 'a(b|c)d');
      expect(translateXPathRegex('[ a b ]', isFlagX: true), '[ a b ]');
      expect(
        translateXPathRegex(r'\p{ IsBasicLatin }', isFlagX: true),
        r'[\u{0}-\u{7f}]',
      );
      expect(
        translateXPathRegex(r'[\p{ IsBasicLatin }]', isFlagX: true),
        r'[\u{0}-\u{7f}]',
      );
    });

    test('fails on syntax errors', () {
      expect(
        () => translateXPathRegex(r'abc\'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex('(abc'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
      expect(
        () => translateXPathRegex('[abc'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });
  });

  group('parseRegexGroups', () {
    test('parses nested capturing groups', () {
      final root = parseRegexGroups('((a)(b))');
      expect(root.nr, 0);
      expect(root.parentNr, -1);
      expect(root.children, hasLength(1));
      expect(root.children[0].nr, 1);
      expect(root.children[0].parentNr, 0);
      expect(root.children[0].children, hasLength(2));
      expect(root.children[0].children[0].nr, 2);
      expect(root.children[0].children[0].parentNr, 1);
      expect(root.children[0].children[1].nr, 3);
      expect(root.children[0].children[1].parentNr, 1);
    });

    test('ignores non-capturing groups and character classes', () {
      final root = parseRegexGroups('(?:[(])(a)');
      expect(root.children, hasLength(1));
      expect(root.children[0].nr, 1);
      expect(root.children[0].children, isEmpty);
    });

    test('parses with flag x', () {
      final root = parseRegexGroups(' ( a ) | ( b ) ', isFlagX: true);
      expect(root.children, hasLength(2));
      expect(root.children[0].nr, 1);
      expect(root.children[1].nr, 2);
    });

    test('returns empty root group on syntax error', () {
      final root = parseRegexGroups('(');
      expect(root.children, isEmpty);
    });
  });

  group('applyXPathReplace', () {
    test('literal replacement', () {
      final reg = RegExp('a');
      expect(
        applyXPathReplace('banana', reg, r'$1', isLiteral: true),
        r'b$1n$1n$1',
      );
    });

    test('throws FORX0003 on zero-length match', () {
      final reg = RegExp('.*');
      expect(
        () => applyXPathReplace('banana', reg, 'x'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0003)),
      );
    });

    test('substitutes matched groups', () {
      final reg = RegExp('(b)(a)');
      expect(applyXPathReplace('banana', reg, r'[$0-$1-$2]'), '[ba-b-a]nana');
    });

    test('escapes dollar and backslash', () {
      final reg = RegExp('(a)');
      expect(applyXPathReplace('banana', reg, r'\$$1'), r'b$an$an$a');
      expect(applyXPathReplace('banana', reg, r'\\$1'), r'b\an\an\a');
      expect(applyXPathReplace('banana', reg, r'\$$1\\'), r'b$a\n$a\n$a\');
    });

    test('resolves multi-digit group resolution', () {
      final pattern =
          '${List.filled(15, '(').join()}a${List.filled(15, ')').join()}';
      final reg = RegExp(pattern);
      expect(
        applyXPathReplace('abracadabra', reg, r'$1520'),
        'a20bra20ca20da20bra20',
      );
    });

    test('throws FORX0004 for invalid template syntax', () {
      final reg = RegExp('(a)');
      expect(
        () => applyXPathReplace('banana', reg, r'\'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004)),
      );
      expect(
        () => applyXPathReplace('banana', reg, r'\x'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004)),
      );
      expect(
        () => applyXPathReplace('banana', reg, r'$'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004)),
      );
      expect(
        () => applyXPathReplace('banana', reg, r'$9'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0004)),
      );
    });
  });

  group('analyzeXPathString', () {
    test('handles empty input string', () {
      final node = analyzeXPathString('', 'abc');
      expect(
        node.node.toXmlString(),
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions"/>',
      );
    });

    test('handles non-matching string only', () {
      final node = analyzeXPathString('banana', 'xyz');
      expect(
        node.node.toXmlString(),
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:non-match>banana</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles matching string only', () {
      final node = analyzeXPathString('banana', '.+');
      expect(
        node.node.toXmlString(),
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match>banana</fn:match>'
        '</fn:analyze-string-result>',
      );
    });

    test('handles literal mode with q flag', () {
      final node = analyzeXPathString('((banana))', '(banana)', flags: 'q');
      expect(
        node.node.toXmlString(),
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
      expect(
        node.node.toXmlString(),
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
      expect(
        node.node.toXmlString(),
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
      expect(
        node.node.toXmlString(),
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:match>start-<fn:group nr="1">foo</fn:group>-mid-<fn:group nr="2">bar</fn:group>-end</fn:match>'
        '</fn:analyze-string-result>',
      );
    });

    test('throws FORX0001 for invalid flags', () {
      expect(
        () => analyzeXPathString('abc', 'abc', flags: 'w'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0001)),
      );
    });

    test('throws FORX0002 for invalid pattern', () {
      expect(
        () => analyzeXPathString('abc', ')-('),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002)),
      );
    });

    test('throws FORX0003 for zero-length pattern match', () {
      expect(
        () => analyzeXPathString('abc', 'a?'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORX0003)),
      );
    });
  });
}
