part of xml;

/**
 * efficient large-text replacement for RegExp based _decodeXml
 * performance is somewhat ~-0.08 worse for small-xml-text 
 * and ~19x better for large-xml-text
 * small-xml-text
 * Benchmark XmlUnescape Parsing: 1.20-1.32
 * Benchmark _decodeXml Parsing: 1.16-1.22 ms
 * default is _decodeXml, switch if large-text is a problem.
 */
//final _XML_UNESCAPE = new XmlUnescape().convert;
final _XML_UNESCAPE = _decodeXml;

/**
 * XML grammar definition.
 */
abstract class XmlGrammar extends CompositeParser {

  // name patterns
  static const NAME_START_CHARS = ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001\uD7FF'
      '\uF900-\uFDCF\uFDF0-\uFFFD';
  static const NAME_CHARS = '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$NAME_START_CHARS';
  static const CHAR_DATA = '^<';

  // basic tokens
  static const DOUBLE_QUOTE = '"';
  static const SINGLE_QUOTE = "'";
  static const EQUALS = '=';
  static const WHITESPACE = ' ';
  static const OPEN_COMMENT = '<!--';
  static const CLOSE_COMMENT = '-->';
  static const OPEN_CDATA = '<![CDATA[';
  static const CLOSE_CDATA = ']]>';
  static const OPEN_ELEMENT = '<';
  static const CLOSE_ELEMENT = '>';
  static const OPEN_END_ELEMENT = '</';
  static const CLOSE_END_ELEMENT = '/>';
  static const OPEN_DOCTYPE = '<!DOCTYPE';
  static const CLOSE_DOCTYPE = '>';
  static const OPEN_DOCTYPE_BLOCK = '[';
  static const CLOSE_DOCTYPE_BLOCK = ']';
  static const OPEN_PROCESSING = '<?';
  static const CLOSE_PROCESSING = '?>';

  // parser callbacks
  createAttribute(name, value);
  createComment(value);
  createCDATA(value);
  createDoctype(value);
  createDocument(Iterable children);
  createElement(name, Iterable attributes, Iterable children);
  createProcessing(target, value);
  createQualified(name);
  createText(value);

  @override
  void initialize() {
    def('start', ref('document').end());

    def('attribute', ref('qualified')
      .seq(ref('whitespace').optional())
      .seq(char(EQUALS))
      .seq(ref('whitespace').optional())
      .seq(ref('attributeValue'))
      .map((each) => createAttribute(each[0], each[4])));
    def('attributeValue', ref('attributeValueDouble')
      .or(ref('attributeValueSingle'))
      .pick(1));
    def('attributeValueDouble', char(DOUBLE_QUOTE)
      .seq(any().starLazy(char(DOUBLE_QUOTE)).flatten().map(_XML_UNESCAPE))
      .seq(char(DOUBLE_QUOTE)));
    def('attributeValueSingle', char(SINGLE_QUOTE)
      .seq(any().starLazy(char(SINGLE_QUOTE)).flatten().map(_XML_UNESCAPE))
      .seq(char(SINGLE_QUOTE)));
    def('attributes', ref('whitespace')
      .seq(ref('attribute'))
      .pick(1)
      .star());
    def('comment', string(OPEN_COMMENT)
      .seq(any().starLazy(string(CLOSE_COMMENT)).flatten())
      .seq(string(CLOSE_COMMENT))
      .map((each) => createComment(each[1])));
    def('cdata', string(OPEN_CDATA)
      .seq(any().starLazy(string(CLOSE_CDATA)).flatten())
      .seq(string(CLOSE_CDATA))
      .map((each) => createCDATA(each[1])));
    def('content', ref('characterData')
      .or(ref('element'))
      .or(ref('processing'))
      .or(ref('comment'))
      .or(ref('cdata'))
      .star());
    def('doctype', string(OPEN_DOCTYPE)
      .seq(ref('whitespace'))
      .seq(ref('nameToken')
        .or(ref('attributeValue'))
        .or(any().starLazy(char(OPEN_DOCTYPE_BLOCK))
          .seq(char(OPEN_DOCTYPE_BLOCK))
          .seq(any().starLazy(char(CLOSE_DOCTYPE_BLOCK)))
          .seq(char(CLOSE_DOCTYPE_BLOCK)))
        .separatedBy(ref('whitespace'))
        .flatten())
      .seq(ref('whitespace').optional())
      .seq(char(CLOSE_DOCTYPE))
      .map((each) => createDoctype(each[2])));
    def('document', ref('processing').optional()
      .seq(ref('misc'))
      .seq(ref('doctype').optional())
      .seq(ref('misc'))
      .seq(ref('element'))
      .seq(ref('misc'))
      .map((each) => createDocument([each[0], each[2], each[4]].where((each) => each != null))));
    def('element', char(OPEN_ELEMENT)
      .seq(ref('qualified'))
      .seq(ref('attributes'))
      .seq(ref('whitespace').optional())
      .seq(string(CLOSE_END_ELEMENT)
        .or(char(CLOSE_ELEMENT)
          .seq(ref('content'))
          .seq(string(OPEN_END_ELEMENT))
          .seq(ref('qualified'))
          .seq(ref('whitespace').optional())
          .seq(char(CLOSE_ELEMENT))))
      .map((list) {
        if (list[4] == CLOSE_END_ELEMENT) {
          return createElement(list[1], list[2], []);
        } else {
          if (list[1] == list[4][3]) {
            return createElement(list[1], list[2], list[4][1]);
          } else {
            throw new ArgumentError('Expected </${list[1]}>, but found </${list[4][3]}>');
          }
        }
      }));
    def('processing', string(OPEN_PROCESSING)
      .seq(ref('nameToken'))
      .seq(ref('whitespace')
        .seq(any().starLazy(string(CLOSE_PROCESSING)).flatten())
        .pick(1).optional(''))
      .seq(string(CLOSE_PROCESSING))
      .map((each) => createProcessing(each[1], each[2])));
    def('qualified', ref('nameToken').map(createQualified));

    def('characterData', pattern(CHAR_DATA).plus().flatten().map(_XML_UNESCAPE).map(createText));
    def('misc', ref('whitespace')
      .or(ref('comment'))
      .or(ref('processing'))
      .star());
    def('whitespace', whitespace().plus());

    def('nameToken', ref('nameStartChar')
      .seq(ref('nameChar').star())
      .flatten());
    def('nameStartChar', pattern(NAME_START_CHARS, 'Expected name'));
    def('nameChar', pattern(NAME_CHARS));
  }

}
