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
        Loaded(book: book),
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

    blocTest(
      'buy succeed',
      build: () async {
        when(api.buyBook(any)).thenAnswer((_) => Future.value(true));

        return BookBloc(
          book: book,
          booksApi: api,
        );
      },
      act: (bloc) => bloc.add(Buy()),
      expect: [
        isA<Buying>(),
        isA<SucceedBuy>(),
      ],
    );

    blocTest(
      'buy throwed error',
      build: () async {
        when(api.buyBook(any)).thenThrow(Exception('network'));

        return BookBloc(
          book: book,
          booksApi: api,
        );
      },
      act: (bloc) => bloc.add(Buy()),
      expect: [
        isA<Buying>(),
        isA<Error>(),
      ],
    );
  });
}

extension on Book {
  Book copyWith({
    int id,
    String title,
    String author,
    String shortDescription,
    int price,
    String imageUrl,
  }) {
    return new Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
