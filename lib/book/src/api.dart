import 'dart:math';

import 'package:bookcatalog/book/src/model.dart';
import 'package:lorem_cutesum/lorem_cutesum.dart';
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
  static const _mockSize = 60;
  static final _random = Random();
  final List<Book> _mock = List.generate(
    _mockSize,
    (index) {
      return Book(
        id: index,
        title: Cutesum.loremCutesum(words: 3),
        shortDescription: Cutesum.loremCutesum(),
        price: _random.nextInt(3) * 1000 +
            _random.nextInt(10) * 100 +
            _random.nextInt(10) * 10,
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
