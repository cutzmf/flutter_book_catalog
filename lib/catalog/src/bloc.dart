import 'package:bloc/bloc.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class CatalogEvent {}

class Refresh implements CatalogEvent {}

class LoadMore implements CatalogEvent {}

class Search implements CatalogEvent {
  final String value;

  Search(this.value);
}

class ClearSearch implements CatalogEvent {}

abstract class CatalogState {}

class Loading implements CatalogState {}

class Refreshing implements CatalogState {}

class Error implements CatalogState {}

class Loaded implements CatalogState {
  final List<Book> books;
  final String search;

  const Loaded({
    @required this.books,
    @required this.search,
  });

  Loaded copyWith({
    List<Book> books,
    String search,
  }) {
    return new Loaded(
      books: books ?? this.books,
      search: search ?? this.search,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loaded &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(books, other.books) &&
          search == other.search;

  @override
  int get hashCode => books.hashCode ^ search.hashCode;
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  /// for sake of simplicity of memory cache
  List<Book> _cache = [];
  final BooksApi booksApi;

  @override
  CatalogState get initialState => Loaded(
        books: [],
        search: '',
      );

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    if (event is Refresh)
      yield* _mapRefresh(event);
    else if (event is LoadMore)
      yield* _mapLoadMore(event);
    else if (event is Search)
      yield* _mapSearch(event);
    else if (event is ClearSearch) yield* _mapClearSearch();
  }

  Stream<CatalogState> _mapClearSearch() async* {
    final s = state;
    if (s is Loaded) {
      yield s.copyWith(books: _cache, search: '');
    }
  }

  Stream<CatalogState> _mapSearch(Search event) async* {
    final s = state;
    if (s is Loaded) {
      yield event.value.isNotEmpty
          ? s.copyWith(
              search: event.value,
              books: s.books
                  .where((it) => it.title.contains(event.value))
                  .toList(),
            )
          : s.copyWith(books: _cache);
    }
  }

  Stream<CatalogState> _mapRefresh(Refresh event) async* {
    final s = state;

    if (s is Loaded) {
      yield Refreshing();

      try {
        final List<Book> fetchedBooks = await booksApi.getBooks();
        _cache = fetchedBooks;
        yield s.copyWith(books: fetchedBooks);
      } catch (e) {
        yield Error();
      }
    }
  }

  Stream<CatalogState> _mapLoadMore(LoadMore event) async* {
    final s = state;
    if (state is! Loading) yield Loading();

    if (s is Loaded) {
      try {
        final List<Book> fetchedBooks = await booksApi.getBooks();
        _cache = fetchedBooks;
        yield s.copyWith(books: fetchedBooks);
      } catch (e) {
        yield Error();
      }
    }
  }

  CatalogBloc({
    @required this.booksApi,
  }) {
    add(LoadMore());
  }
}
