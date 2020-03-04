import 'package:bloc_test/bloc_test.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:bookcatalog/book/src/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockBooksApi extends Mock implements BooksApi {}

void main() {
  final book = Book(
    id: 31337,
    title: 'title',
    author: 'a1',
    shortDescription: 'desc',
    price: 42,
    imageUrl: 'url',
  );
  final updatedBook = book.copyWith(price: 777);
  final api = MockBooksApi();

  group('book details bloc', () {
    blocTest(
      'starts with initial book',
      build: () async => BookBloc(
        book: book,
        booksApi: api,
      ),
      expect: [Loaded(book: book)],
      skip: 0,
    );

    blocTest(
      'refresh with no book updates',
      build: () async {
        when(api.getBookById(any)).thenAnswer((_) => Future.value(book));

        return BookBloc(
          book: book,
          booksApi: api,
        );
      },
      act: (bloc) => bloc.add(Refresh()),
      expect: [
        isA<Loading>(),
        isA<NoUpdates>(),
      ],
    );

    blocTest(
      'refresh and book updated',
      build: () async {
        when(api.getBookById(any)).thenAnswer((_) => Future.value(updatedBook));

        return BookBloc(
          book: book,
          booksApi: api,
        );
      },
      act: (bloc) => bloc.add(Refresh()),
      expect: [
        isA<Loading>(),
        Loaded(book: updatedBook),
      ],
    );

    blocTest(
      'error on refresh',
      build: () async {
        when(api.getBookById(any)).thenThrow(Exception('network'));

        return BookBloc(
          book: book,
          booksApi: api,
        );
      },
      act: (bloc) => bloc.add(Refresh()),
      expect: [
        isA<Loading>(),
        isA<Error>(),
      ],
    );
  });
}

extension on Book {
  Book copyWith({
    int id,
    String title,
    String shortDescription,
    int price,
    String imageUrl,
  }) {
    return new Book(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
