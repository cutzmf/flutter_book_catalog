import 'package:bookcatalog/book/src/model.dart';
import 'package:meta/meta.dart';

class BooksPage {
  final bool hasNext;
  final List<Book> books;

  const BooksPage({
    @required this.hasNext,
    @required this.books,
  });
}

class BooksApi {
  final List<Book> _mock = List.generate(
    60,
    (index) {
      return Book(
        id: index,
        title: index.toString(),
        shortDescription: index.toString(),
        price: index,
        imageUrl: 'https://picsum.photos/seed/$index/200/300',
      );
    },
  );

  static const pageSize = 20;

  /// page starts with 0
  Future<BooksPage> getBooksPage(int page) => Future.delayed(
        Duration(milliseconds: 2800),
        () => BooksPage(
          hasNext: page * pageSize < _mock.length,
          books: _mock
              .getRange(page * pageSize, page * pageSize + pageSize)
              .toList(),
        ),
      );

  Future<Book> getBookById(int id) => Future.delayed(
        Duration(milliseconds: 800),
        () => _mock.firstWhere((it) => it.id == id),
      );
}
