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

  int _failCounter = 0;

  /// fails every even call
  Future<List<Book>> getBooks() {
    return Future.delayed(
      Duration(milliseconds: 2500),
      () => (++_failCounter).isEven
          ? Exception('dummy network exception')
          : _mock,
    );
  }

  /// fails every even call
  Future<Book> getBookById(int id) => Future.delayed(
        Duration(milliseconds: 1000),
        () => (++_failCounter).isEven
            ? Exception('dummy network exception')
            : _mock.firstWhere((it) => it.id == id),
      );
}
