import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void verifyIterator<T>(Iterable<T> iterable) {
  final iterator = iterable.iterator;
  while (iterator.moveNext()) {
    check(iterator.current).isNotNull();
  }
  check(iterator.moveNext()).isFalse();
}

void main() {
  const bookXml =
      '<book>'
      '<title lang="en" price="12.00">XML</title>'
      '<description/>'
      '</book>';
  final book = XmlDocument.parse(bookXml);
  test('ancestors', () {
    check(book.ancestors).isEmpty();
    check(book.children[0].ancestors).deepEquals([book]);
    check(book.children[0].children[0].ancestors)
        .deepEquals([book.children[0], book]);
    check(book.children[0].children[0].attributes[0].ancestors)
        .deepEquals([book.children[0].children[0], book.children[0], book]);
    check(book.children[0].children[0].attributes[1].ancestors)
        .deepEquals([book.children[0].children[0], book.children[0], book]);
    check(book.children[0].children[0].children[0].ancestors)
        .deepEquals([book.children[0].children[0], book.children[0], book]);
    check(book.children[0].children[1].ancestors)
        .deepEquals([book.children[0], book]);
    verifyIterator(book.children[0].children[1].ancestors);
  });
  test('ancestorElements', () {
    check(book.ancestorElements).isEmpty();
    check(book.children[0].ancestorElements).isEmpty();
    check(book.children[0].children[0].ancestorElements)
        .deepEquals([book.children[0]]);
    check(book.children[0].children[0].attributes[0].ancestorElements)
        .deepEquals([book.children[0].children[0], book.children[0]]);
    check(book.children[0].children[0].attributes[1].ancestorElements)
        .deepEquals([book.children[0].children[0], book.children[0]]);
    check(book.children[0].children[0].children[0].ancestorElements)
        .deepEquals([book.children[0].children[0], book.children[0]]);
    check(book.children[0].children[1].ancestorElements)
        .deepEquals([book.children[0]]);
    verifyIterator(book.children[0].children[1].ancestorElements);
  });
  test('preceding', () {
    check(book.preceding).isEmpty();
    check(book.children[0].preceding).deepEquals([book]);
    check(book.children[0].children[0].preceding)
        .deepEquals([book, book.children[0]]);
    check(book.children[0].children[0].attributes[0].preceding)
        .deepEquals([book, book.children[0], book.children[0].children[0]]);
    check(book.children[0].children[0].attributes[1].preceding).deepEquals([
      book,
      book.children[0],
      book.children[0].children[0],
      book.children[0].children[0].attributes[0],
    ]);
    check(book.children[0].children[0].children[0].preceding).deepEquals([
      book,
      book.children[0],
      book.children[0].children[0],
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
    ]);
    check(book.children[0].children[1].preceding).deepEquals([
      book,
      book.children[0],
      book.children[0].children[0],
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
    ]);
    verifyIterator(book.children[0].children[1].preceding);
  });
  test('precedingElements', () {
    check(book.precedingElements).isEmpty();
    check(book.children[0].precedingElements).isEmpty();
    check(book.children[0].children[0].precedingElements)
        .deepEquals([book.children[0]]);
    check(book.children[0].children[0].attributes[0].precedingElements)
        .deepEquals([book.children[0], book.children[0].children[0]]);
    check(book.children[0].children[0].attributes[1].precedingElements)
        .deepEquals([book.children[0], book.children[0].children[0]]);
    check(book.children[0].children[0].children[0].precedingElements)
        .deepEquals([book.children[0], book.children[0].children[0]]);
    check(book.children[0].children[1].precedingElements)
        .deepEquals([book.children[0], book.children[0].children[0]]);
    verifyIterator(book.children[0].children[1].precedingElements);
  });
  test('descendants', () {
    check(book.descendants).deepEquals([
      book.children[0],
      book.children[0].children[0],
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
      book.children[0].children[1],
    ]);
    check(book.children[0].descendants).deepEquals([
      book.children[0].children[0],
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
      book.children[0].children[1],
    ]);
    check(book.children[0].children[0].descendants).deepEquals([
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
    ]);
    check(book.children[0].children[0].attributes[0].descendants).isEmpty();
    check(book.children[0].children[0].attributes[1].descendants).isEmpty();
    check(book.children[0].children[0].children[0].descendants).isEmpty();
    check(book.children[0].children[1].descendants).isEmpty();
    verifyIterator(book.descendants);
  });
  test('descendantElements', () {
    check(book.descendantElements).deepEquals([
      book.children[0],
      book.children[0].children[0],
      book.children[0].children[1],
    ]);
    check(
      book.children[0].descendantElements,
    ).deepEquals([book.children[0].children[0], book.children[0].children[1]]);
    check(book.children[0].children[0].descendantElements).isEmpty();
    check(book.children[0].children[0].attributes[0].descendantElements)
        .isEmpty();
    check(book.children[0].children[0].attributes[1].descendantElements)
        .isEmpty();
    check(book.children[0].children[0].children[0].descendantElements)
        .isEmpty();
    check(book.children[0].children[1].descendantElements).isEmpty();
    verifyIterator(book.descendantElements);
  });
  test('following', () {
    check(book.following).isEmpty();
    check(book.children[0].following).isEmpty();
    check(book.children[0].children[0].following)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[0].attributes[0].following).deepEquals([
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
      book.children[0].children[1],
    ]);
    check(book.children[0].children[0].attributes[1].following).deepEquals([
      book.children[0].children[0].children[0],
      book.children[0].children[1],
    ]);
    check(book.children[0].children[0].children[0].following)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[1].following).isEmpty();
    verifyIterator(book.following);
  });
  test('followingElements', () {
    check(book.followingElements).isEmpty();
    check(book.children[0].followingElements).isEmpty();
    check(book.children[0].children[0].followingElements)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[0].attributes[0].followingElements)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[0].attributes[1].followingElements)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[0].children[0].followingElements)
        .deepEquals([book.children[0].children[1]]);
    check(book.children[0].children[1].followingElements).isEmpty();
    verifyIterator(book.followingElements);
  });
  test('nodes', () {
    check(book.nodes).deepEquals([book.children[0]]);
    check(
      book.children[0].nodes,
    ).deepEquals([book.children[0].children[0], book.children[0].children[1]]);
    check(book.children[0].children[0].nodes).deepEquals([
      book.children[0].children[0].attributes[0],
      book.children[0].children[0].attributes[1],
      book.children[0].children[0].children[0],
    ]);
    check(book.children[0].children[0].attributes[0].nodes).isEmpty();
    check(book.children[0].children[0].attributes[1].nodes).isEmpty();
    check(book.children[0].children[0].children[0].nodes).isEmpty();
    check(book.children[0].children[1].nodes).isEmpty();
    verifyIterator(book.nodes);
  });
}
