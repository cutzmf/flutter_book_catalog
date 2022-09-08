import 'dart:math';

import 'package:bookcatalog/book/src/model.dart';
import 'package:faker/faker.dart';

class BooksPage {
  final bool hasNext;
  final List<Book> books;

  const BooksPage({
    required this.hasNext,
    required this.books,
  });
}

class BooksApi {
  static const _mockSize = 60;
  static final _random = Random();
  static final faker =  Faker();
  final List<Book> _mock = List.generate(
    _mockSize,
    (index) {
      return Book(
        id: index,
        title: '${faker.person.name()} ${faker.randomGenerator.numberOfLength(10)}',
        author: faker.person.name().replaceAllMapped('.', (_) => ''),
        shortDescription: faker.lorem.sentence(),
        price: _random.nextInt(3) * 1000 + _random.nextInt(10) * 100 + _random.nextInt(10) * 10,
        imageUrl: 'https://picsum.photos/seed/$index/200/300',
      );
    },
  );

  static const pageSize = 20;

  int _failCounter = 0;

  static final _netException = Exception('dummy network exception');

  /// fails every even call
  Future<List<Book>> getBooks() {
    return Future.delayed(
      Duration(milliseconds: 1500),
      () {
        if ((++_failCounter).isEven) {
          throw _netException;
        }
        return _mock;
      },
    );
  }

  /// fails every even call
  Future<Book> getBookById(int id) => Future.delayed(
        Duration(milliseconds: 1000),
        () {
          if ((++_failCounter).isEven) {
            throw _netException;
          }
          return _mock.firstWhere((it) => it.id == id);
        },
      );

  /// fails every even call
  Future<bool> buyBook(Book book) => Future.delayed(
        Duration(milliseconds: 1500),
        () {
          if ((++_failCounter).isEven) {
            throw _netException;
          }
          return true;
        },
      );
}
