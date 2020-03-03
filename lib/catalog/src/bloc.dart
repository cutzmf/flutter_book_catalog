import 'package:bloc/bloc.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class CatalogEvent {}

class Refresh implements CatalogEvent {}

class LoadMore implements CatalogEvent {}

abstract class CatalogState {}

class Loading implements CatalogState {}

class Error implements CatalogState {}

class Loaded implements CatalogState {
  final int _pageNumber;
  final List<Book> _cache;
  final List<Book> books;

  Loaded copyWith({
    int pageNumber,
    List<Book> cache,
    Iterable<Book> books,
  }) {
    return new Loaded(
      pageNumber: pageNumber ?? this._pageNumber,
      cache: cache ?? this._cache,
      books: books ?? this.books,
    );
  }

  const Loaded({
    @required this.books,
    @required int pageNumber,
    @required List<Book> cache,
  })  : _pageNumber = pageNumber,
        _cache = cache;
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  /// for sake of simplicity of memory cache
  final List<Book> _cache = [];
  final BooksApi booksApi;

  @override
  CatalogState get initialState => Loaded(pageNumber: 0, books: [], cache: []);

  @override
  Stream<CatalogState> mapEventToState(CatalogEvent event) async* {
    if (event is Refresh)
      yield* _mapRefresh(event);
    else if (event is LoadMore) yield* _mapLoadMore(event);
  }

  Stream<CatalogState> _mapRefresh(Refresh event) async* {
    final s = state;

    if (s is Loaded) {
      try {
        final BooksPage page = await booksApi.getBooksPage(s._pageNumber);
        yield s.copyWith(books: page.books);
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
        final BooksPage page = await booksApi.getBooksPage(s._pageNumber);
        _cache.addAll(page.books);
        yield s.copyWith(books: _cache);
      } catch (e) {
        yield Error();
        yield s.copyWith();
      }
    }
  }

  CatalogBloc({
    @required this.booksApi,
  }) {
    add(LoadMore());
  }
}
