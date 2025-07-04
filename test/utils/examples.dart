const Map<String, String> allXml = {
  'atom.xml': atomXml,
  'books.xml': booksXml,
  'bookstore.xml': bookstoreXml,
  'complicated.xml': complicatedXml,
  'control_characters.xml': controlCharactersXml,
  'shiporder.xsd': shiporderXsd,
  'unicode.xml': unicodeXml,
  'wikimedia.xml': wikimediaXml,
};

const String atomXml =
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<app:service>'
    '  <app:workspace>'
    '    <cmisra:repositoryInfo xmlns:ns3="http://docs.oasis-open.org/ns/cmis/messaging/200908/">'
    '    </cmisra:repositoryInfo>'
    '  </app:workspace>'
    '</app:service>';

const String booksXml =
    '<?xml version="1.0"?>'
    '<catalog>'
    '   <book id="bk101">'
    '      <author>Gambardella, Matthew</author>'
    '      <title>XML Developer\'s Guide</title>'
    '      <genre>Computer</genre>'
    '      <price>44.95</price>'
    '      <publish_date>2000-10-01</publish_date>'
    '      <description>An in-depth look at creating applications '
    '      with XML.</description>'
    '   </book>'
    '   <book id="bk102">'
    '      <author>Ralls, Kim</author>'
    '      <title>Midnight Rain</title>'
    '      <genre>Fantasy</genre>'
    '      <price>5.95</price>'
    '      <publish_date>2000-12-16</publish_date>'
    '      <description>A former architect battles corporate zombies, '
    '      an evil sorceress, and her own childhood to become queen '
    '      of the world.</description>'
    '   </book>'
    '   <book id="bk103">'
    '      <author>Corets, Eva</author>'
    '      <title>Maeve Ascendant</title>'
    '      <genre>Fantasy</genre>'
    '      <price>5.95</price>'
    '      <publish_date>2000-11-17</publish_date>'
    '      <description>After the collapse of a nanotechnology '
    '      society in England, the young survivors lay the '
    '      foundation for a new society.</description>'
    '   </book>'
    '   <book id="bk104">'
    '      <author>Corets, Eva</author>'
    '      <title>Oberon\'s Legacy</title>'
    '      <genre>Fantasy</genre>'
    '      <price>5.95</price>'
    '      <publish_date>2001-03-10</publish_date>'
    '      <description>In post-apocalypse England, the mysterious '
    '      agent known only as Oberon helps to create a new life '
    '      for the inhabitants of London. Sequel to Maeve '
    '      Ascendant.</description>'
    '   </book>'
    '   <book id="bk105">'
    '      <author>Corets, Eva</author>'
    '      <title>The Sundered Grail</title>'
    '      <genre>Fantasy</genre>'
    '      <price>5.95</price>'
    '      <publish_date>2001-09-10</publish_date>'
    '      <description>The two daughters of Maeve, half-sisters, '
    '      battle one another for control of England. Sequel to '
    '      Oberon\'s Legacy.</description>'
    '   </book>'
    '   <book id="bk106">'
    '      <author>Randall, Cynthia</author>'
    '      <title>Lover Birds</title>'
    '      <genre>Romance</genre>'
    '      <price>4.95</price>'
    '      <publish_date>2000-09-02</publish_date>'
    '      <description>When Carla meets Paul at an ornithology '
    '      conference, tempers fly as feathers get ruffled.</description>'
    '   </book>'
    '   <book id="bk107">'
    '      <author>Thurman, Paula</author>'
    '      <title>Splish Splash</title>'
    '      <genre>Romance</genre>'
    '      <price>4.95</price>'
    '      <publish_date>2000-11-02</publish_date>'
    '      <description>A deep sea diver finds true love twenty '
    '      thousand leagues beneath the sea.</description>'
    '   </book>'
    '   <book id="bk108">'
    '      <author>Knorr, Stefan</author>'
    '      <title>Creepy Crawlies</title>'
    '      <genre>Horror</genre>'
    '      <price>4.95</price>'
    '      <publish_date>2000-12-06</publish_date>'
    '      <description>An anthology of horror stories about roaches,'
    '      centipedes, scorpions  and other insects.</description>'
    '   </book>'
    '   <book id="bk109">'
    '      <author>Kress, Peter</author>'
    '      <title>Paradox Lost</title>'
    '      <genre>Science Fiction</genre>'
    '      <price>6.95</price>'
    '      <publish_date>2000-11-02</publish_date>'
    '      <description>After an inadvertant trip through a Heisenberg'
    '      Uncertainty Device, James Salway discovers the problems '
    '      of being quantum.</description>'
    '   </book>'
    '   <book id="bk110">'
    '      <author>O\'Brien, Tim</author>'
    '      <title>Microsoft .NET: The Programming Bible</title>'
    '      <genre>Computer</genre>'
    '      <price>36.95</price>'
    '      <publish_date>2000-12-09</publish_date>'
    '      <description>Microsoft\'s .NET initiative is explored in '
    '      detail in this deep programmer\'s reference.</description>'
    '   </book>'
    '   <book id="bk111">'
    '      <author>O\'Brien, Tim</author>'
    '      <title>MSXML3: A Comprehensive Guide</title>'
    '      <genre>Computer</genre>'
    '      <price>36.95</price>'
    '      <publish_date>2000-12-01</publish_date>'
    '      <description>The Microsoft MSXML3 parser is covered in '
    '      detail, with attention to XML DOM interfaces, XSLT processing, '
    '      SAX and more.</description>'
    '   </book>'
    '   <book id="bk112">'
    '      <author>Galos, Mike</author>'
    '      <title>Visual Studio 7: A Comprehensive Guide</title>'
    '      <genre>Computer</genre>'
    '      <price>49.95</price>'
    '      <publish_date>2001-04-16</publish_date>'
    '      <description>Microsoft Visual Studio 7 is explored in depth,'
    '      looking at how Visual Basic, Visual C++, C#, and ASP+ are '
    '      integrated into a comprehensive development '
    '      environment.</description>'
    '   </book>'
    '</catalog>';

const String bookstoreXml =
    '<?xml version="1.0" encoding="ISO-8859-1"?>\n'
    '<bookstore>\n'
    '  <book>\n'
    '    <title lang="eng">Harry Potter</title>\n'
    '    <price>29.99</price>\n'
    '  </book>\n'
    '  <book>\n'
    '    <title lang="eng">Learning XML</title>\n'
    '    <price>39.95</price>\n'
    '  </book>\n'
    '</bookstore>';

const String complicatedXml =
    '<?xml version="1.0"?>\n'
    '<!DOCTYPE name SYSTEM "complicated.dtd" [ <!ELEMENT html (head, body)> ]>\n'
    '<ns:foo attr="not namespaced" n1:ans="namespaced 1" '
    '        n2:ans="namespace 2" >\n'
    '  Plain text contents!'
    '  <element/>\n'
    '  <ns:element/>\n'
    '  <!-- comment -->\n'
    '  <![CDATA[cdata]]>\n'
    '  <?processing instruction?>\n'
    '</ns:foo>';

const String controlCharactersXml =
    '<?xml version="1.0"?>\n'
    '<name attr="bell\u0007">del\u007fbackspace\u0008null\u0000</name>';

const String shiporderXsd =
    '<?xml version="1.0"?>'
    '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
    '  <xsd:annotation>'
    '    <xsd:documentation xml:lang="en">'
    '     Purchase order schema for Example.com.'
    '     Copyright 2000 Example.com. All rights reserved.'
    '    </xsd:documentation>'
    '  </xsd:annotation>'
    '  <xsd:element name="purchaseOrder" type="PurchaseOrderType"/>'
    '  <xsd:element name="comment" type="xsd:string"/>'
    '  <xsd:complexType name="PurchaseOrderType">'
    '    <xsd:sequence>'
    '      <xsd:element name="shipTo" type="USAddress"/>'
    '      <xsd:element name="billTo" type="USAddress"/>'
    '      <xsd:element ref="comment" minOccurs="0"/>'
    '      <xsd:element name="items"  type="Items"/>'
    '    </xsd:sequence>'
    '    <xsd:attribute name="orderDate" type="xsd:date"/>'
    '  </xsd:complexType>'
    '  <xsd:complexType name="USAddress">'
    '    <xsd:sequence>'
    '      <xsd:element name="name"   type="xsd:string"/>'
    '      <xsd:element name="street" type="xsd:string"/>'
    '      <xsd:element name="city"   type="xsd:string"/>'
    '      <xsd:element name="state"  type="xsd:string"/>'
    '      <xsd:element name="zip"    type="xsd:decimal"/>'
    '    </xsd:sequence>'
    '    <xsd:attribute name="country" type="xsd:NMTOKEN" fixed="US"/>'
    '  </xsd:complexType>'
    '  <xsd:complexType name="Items">'
    '    <xsd:sequence>'
    '      <xsd:element name="item" minOccurs="0" maxOccurs="unbounded">'
    '        <xsd:complexType>'
    '          <xsd:sequence>'
    '            <xsd:element name="productName" type="xsd:string"/>'
    '            <xsd:element name="quantity">'
    '              <xsd:simpleType>'
    '                <xsd:restriction base="xsd:positiveInteger">'
    '                  <xsd:maxExclusive value="100"/>'
    '                </xsd:restriction>'
    '              </xsd:simpleType>'
    '            </xsd:element>'
    '            <xsd:element name="USPrice"  type="xsd:decimal"/>'
    '            <xsd:element ref="comment"   minOccurs="0"/>'
    '            <xsd:element name="shipDate" type="xsd:date" minOccurs="0"/>'
    '          </xsd:sequence>'
    '          <xsd:attribute name="partNum" type="SKU" use="required"/>'
    '        </xsd:complexType>'
    '      </xsd:element>'
    '    </xsd:sequence>'
    '  </xsd:complexType>'
    '  <!-- Stock Keeping Unit, a code for identifying products -->'
    '  <xsd:simpleType name="SKU">'
    '    <xsd:restriction base="xsd:string">'
    '      <xsd:pattern value="\\d{3}-[A-Z]{2}"/>'
    '    </xsd:restriction>'
    '  </xsd:simpleType>'
    '</xsd:schema>';

const String unicodeXml =
    '<?xml version="1.1" encoding="UTF-8"?>\n'
    '<電文情報 version="5.0">\n'
    '<生年月日>昭和２８年２月１日</生年月日>\n'
    '<性別>男</性別>\n'
    '</電文情報>\n';

const String wikimediaXml =
    '<?xml version="1.0" encoding="utf-8"?>'
    '<Wikimedia>'
    '  <projects>'
    '    <project name="Wikipedia" launch="2001-01-05">'
    '      <editions>'
    '        <edition language="English">en.wikipedia.org</edition>'
    '        <edition language="German">de.wikipedia.org</edition>'
    '        <edition language="French">fr.wikipedia.org</edition>'
    '        <edition language="Polish">pl.wikipedia.org</edition>'
    '        <edition language="Spanish">es.wikipedia.org</edition>'
    '      </editions>'
    '    </project>'
    '    <project name="Wiktionary" launch="2002-12-12">'
    '      <editions>'
    '        <edition language="English">en.wiktionary.org</edition>'
    '        <edition language="French">fr.wiktionary.org</edition>'
    '        <edition language="Vietnamese">vi.wiktionary.org</edition>'
    '        <edition language="Turkish">tr.wiktionary.org</edition>'
    '        <edition language="Spanish">es.wiktionary.org</edition>'
    '      </editions>'
    '    </project>'
    '  </projects>'
    '</Wikimedia>';
