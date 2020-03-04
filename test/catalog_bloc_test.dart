import 'package:bloc_test/bloc_test.dart';
import 'package:bookcatalog/book/book.dart' show Book, BooksApi;
import 'package:bookcatalog/catalog/src/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockBooksApi extends Mock implements BooksApi {}

void main() {
  final book1 = Book(
    id: 31337,
    title: 'title1',
    author: 'a1',
    shortDescription: 'desc',
    price: 42,
    imageUrl: 'url',
  );

  final book2 = Book(
    id: 31338,
    title: 'title2',
    author: 'a2',
    shortDescription: 'desc2',
    price: 142,
    imageUrl: 'url2',
  );

  final api = MockBooksApi();

  group('book catalog bloc', () {
    blocTest(
      'starts with loading',
      build: () async {
        when(api.getBooks()).thenAnswer((_) => Future.value([book1]));
        return CatalogBloc(booksApi: api);
      },
      expect: [
        isA<Loading>(),
        Loaded(books: [book1], search: ''),
      ],
    );

    blocTest(
      'initial load & refreshing',
      build: () async {
        when(api.getBooks()).thenAnswer((_) => Future.value([book1]));
        return CatalogBloc(booksApi: api);
      },
      act: (bloc) => bloc.add(Refresh()),
      expect: [
        isA<Loading>(),
        Loaded(books: [book1], search: ''),
        isA<Refreshing>(),
        Loaded(books: [book1], search: ''),
      ],
    );

    blocTest(
      'refreshing failed & new refresh',
      build: () async {
        final answers = [
          Future.value([book1]),
          Future.value(Exception('')),
          Future.value([book1, book2]),
        ];
        when(api.getBooks()).thenAnswer((_) => answers.removeAt(0));
        return CatalogBloc(booksApi: api);
      },
      act: (bloc) {
        bloc.add(Refresh());
        return bloc.add(Refresh());
      },
      expect: [
        isA<Loading>(),
        Loaded(books: [book1], search: ''),
        isA<Refreshing>(),
        isA<Error>(),
        Loaded(books: [book1], search: ''),
        isA<Refreshing>(),
        Loaded(books: [book1, book2], search: ''),
      ],
    );

    blocTest(
      'search when no updates',
      build: () async {
        when(api.getBooks()).thenAnswer((_) => Future.value([book1, book2]));
        return CatalogBloc(booksApi: api);
      },
      act: (bloc) {
        bloc.add(Search(book1.title));
        return bloc.add(ClearSearch());
      },
      expect: [
        isA<Loading>(),
        Loaded(books: [book1, book2], search: ''),
        Loaded(books: [book1], search: book1.title),
        Loaded(books: [book1, book2], search: ''),
      ],
    );
  });
}
