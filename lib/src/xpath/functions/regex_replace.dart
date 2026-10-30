import 'package:petitparser/petitparser.dart';

import '../../xml/builder/builder.dart';
import '../../xml/utils/cache.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';
import 'regex.dart';

sealed class _ReplacePart {
  const new();
  String evaluate(RegExpMatch match);
}

class _LiteralPart extends _ReplacePart {
  const new(this.value);
  final String value;
  @override
  String evaluate(RegExpMatch match) => value;
}

class _GroupPart extends _ReplacePart {
  const new(this.digits);
  final String digits;

  @override
  String evaluate(RegExpMatch match) {
    var len = digits.length;
    while (len > 0) {
      final sub = digits.substring(0, len);
      final nr = int.parse(sub);
      if (nr <= match.groupCount) {
        final replacement = match.group(nr) ?? '';
        final rest = digits.substring(len);
        return '$replacement$rest';
      }
      len--;
    }
    throw XPathEvaluationException(
      XPathErrorCode.FORX0004,
      'Group index \$$digits exceeds capturing group count ${match.groupCount}',
    );
  }
}

final _replaceTemplateParser = [
  seq2(char(r'\'), anyOf(r'\$')).map2((_, c) => _LiteralPart(c)),
  seq2(
    char(r'$'),
    digit().plusString(),
  ).map2((_, digits) => _GroupPart(digits)),
  anyOf(r'\$').neg().plusString().map(_LiteralPart.new),
].toChoiceParser().star().end();

/// Applies XPath 3.1 fn:replace semantics including replacement template validation and group substitution.
String applyXPathReplace(
  String input,
  RegExp regex,
  String replacement, {
  bool isLiteral = false,
}) {
  if (regex.hasMatch('')) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0003,
      'Regular expression matches zero-length string',
    );
  }

  if (isLiteral) {
    return input.replaceAll(regex, replacement);
  }

  final parsed = _replaceTemplateParser.parse(replacement);
  if (parsed is Failure) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0004,
      'Invalid replacement string: ${parsed.message}',
    );
  }
  final parts = parsed.value;

  return input.replaceAllMapped(regex, (match) {
    final regMatch = match as RegExpMatch;
    final buffer = StringBuffer();
    for (final part in parts) {
      buffer.write(part.evaluate(regMatch));
    }
    return buffer.toString();
  });
}

final _xpathRegexGroupsCache =
    XmlCache<({String pattern, bool isFlagX}), XPathRegexGroup>(
      (args) => parseRegexGroups(args.pattern, isFlagX: args.isFlagX),
      50,
    );

/// Evaluates XPath 3.1 `fn:analyze-string` returning an [XPathNode] wrapping the `<fn:analyze-string-result>` element.
XPathNode analyzeXPathString(String text, String pattern, {String? flags}) {
  validateXPathRegexFlags(flags);
  final hasFlags = flags != null;
  final isLiteral = hasFlags && flags.contains('q');
  final isFlagX = hasFlags && flags.contains('x');
  final XPathRegexGroup rootGroup;
  if (isLiteral) {
    rootGroup = XPathRegexGroup(nr: 0, parentNr: -1, children: []);
  } else {
    rootGroup = _xpathRegexGroupsCache[(pattern: pattern, isFlagX: isFlagX)];
  }
  final regex = getCachedXPathRegex(pattern, flags);
  if (regex.hasMatch('')) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0003,
      'Regular expression matches zero-length string',
    );
  }

  final builder = XmlBuilder();
  builder.element(
    'analyze-string-result',
    namespace: 'http://www.w3.org/2005/xpath-functions',
    namespaces: {'http://www.w3.org/2005/xpath-functions': 'fn'},
    nest: () {
      if (text.isEmpty) return;
      var lastIndex = 0;
      for (final match in regex.allMatches(text)) {
        if (match.start > lastIndex) {
          builder.element(
            'non-match',
            namespace: 'http://www.w3.org/2005/xpath-functions',
            nest: () {
              builder.text(text.substring(lastIndex, match.start));
            },
          );
        }
        builder.element(
          'match',
          namespace: 'http://www.w3.org/2005/xpath-functions',
          nest: () {
            _buildMatchChildren(builder, match, rootGroup, match[0]!);
          },
        );
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        builder.element(
          'non-match',
          namespace: 'http://www.w3.org/2005/xpath-functions',
          nest: () {
            builder.text(text.substring(lastIndex));
          },
        );
      }
    },
  );
  return XPathNode(builder.buildDocument().rootElement);
}

void _buildMatchChildren(
  XmlBuilder builder,
  RegExpMatch match,
  XPathRegexGroup parentGroup,
  String parentText,
) {
  final activeChildren = parentGroup.children
      .where((child) => match.group(child.nr) != null)
      .toList();
  if (activeChildren.isEmpty) {
    if (parentText.isNotEmpty) {
      builder.text(parentText);
    }
    return;
  }
  var cursor = 0;
  for (var i = 0; i < activeChildren.length; i++) {
    final child = activeChildren[i];
    final childText = match.group(child.nr)!;
    var remainingMinLength = 0;
    for (var j = i + 1; j < activeChildren.length; j++) {
      remainingMinLength += match.group(activeChildren[j].nr)!.length;
    }
    final maxEnd = parentText.length - remainingMinLength;
    if (childText.isNotEmpty) {
      final searchLimit = maxEnd >= childText.length
          ? maxEnd - childText.length
          : cursor;
      var idx = parentText.lastIndexOf(childText, searchLimit);
      if (idx < cursor) {
        idx = parentText.indexOf(childText, cursor);
      }
      if (idx > cursor) {
        builder.text(parentText.substring(cursor, idx));
      }
      builder.element(
        'group',
        namespace: 'http://www.w3.org/2005/xpath-functions',
        attributes: {'nr': child.nr.toString()},
        nest: () {
          _buildMatchChildren(builder, match, child, childText);
        },
      );
      cursor = (idx >= cursor ? idx : cursor) + childText.length;
    } else {
      final idx = maxEnd < cursor ? cursor : maxEnd;
      if (idx > cursor) {
        builder.text(parentText.substring(cursor, idx));
        cursor = idx;
      }
      builder.element(
        'group',
        namespace: 'http://www.w3.org/2005/xpath-functions',
        attributes: {'nr': child.nr.toString()},
        nest: () {
          _buildMatchChildren(builder, match, child, childText);
        },
      );
    }
  }
  if (cursor < parentText.length) {
    builder.text(parentText.substring(cursor));
  }
}
