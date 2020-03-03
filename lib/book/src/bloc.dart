import 'package:bloc/bloc.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

abstract class BookEvent {}

class Refresh implements BookEvent {}

abstract class BookState {}

class Loading implements BookState {}

class Error implements BookState {}

class NoUpdates implements BookState {}

class Loaded implements BookState {
  final Book book;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loaded && runtimeType == other.runtimeType && book == other.book;

  @override
  int get hashCode => book.hashCode;

  const Loaded({
    @required this.book,
  });

  Loaded copyWith({
    Book book,
  }) {
    return new Loaded(
      book: book ?? this.book,
    );
  }
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final Book book;
  final BooksApi booksApi;

  @override
  BookState get initialState => Loaded(book: book);

  @override
  Stream<BookState> mapEventToState(BookEvent event) async* {
    final s = state;
    if (event is Refresh && s is Loaded) {
      yield Loading();
      try {
        final fetchedBook = await booksApi.getBookById(book.id);
        yield fetchedBook != book ? s.copyWith(book: fetchedBook) : NoUpdates();
      } catch (e) {
        yield Error();
      }
    }
  }

  BookBloc({
    @required this.book,
    @required this.booksApi,
  });
}
